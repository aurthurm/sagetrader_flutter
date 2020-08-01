import 'package:msagetrader/providers/strategies.dart';
import 'package:flutter/material.dart';
import 'package:msagetrader/screens/strategy_detail.dart';
import 'package:msagetrader/utils/utils.dart';
import 'package:msagetrader/models/strategy.dart';
import 'package:provider/provider.dart';

class StrategiesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _strategies = Provider.of<Strategies>(context);
    List<Strategy> strategies = _strategies.strategies;

    return Container(
      child: ListView.builder(
        itemCount: strategies.length,
        itemBuilder: (context, index) {
          Strategy strategy = strategies[index];
          return GestureDetector(
            child: StrategyCard(strategy: strategy),
            onTap: () => navigateToPage(
              context,
              StrategyDetail(strategyId: strategy.id),
            ),
          );
        },
      ),
    );
  }
}

class StrategyCard extends StatelessWidget {
  final Strategy strategy;
  StrategyCard({this.strategy});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          child: Row(
            children: <Widget>[
              Container(
                width: 60,
                child: Column(
                  children: <Widget>[
                    Text(
                      "" + strategy.won.toString() + "",
                      style: TextStyle(color: Colors.green),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 5),
                      child: Text(
                        strategy.winRate(),
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      strategy.lost.toString(),
                      style: TextStyle(color: Colors.red),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      strategy.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      getExerpt(strategy.description, 45),
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
