import 'package:msagetrader/models/trade.dart';
import 'package:msagetrader/providers/instruments.dart';
import 'package:msagetrader/providers/strategies.dart';
import 'package:msagetrader/providers/styles.dart';
import 'package:msagetrader/providers/trades.dart';
import 'package:flutter/material.dart';
import 'package:msagetrader/screens/trade_detail.dart';
import 'package:msagetrader/utils/utils.dart';
import 'package:provider/provider.dart';

class TradesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _trades = Provider.of<Trades>(context);
    List<Trade> trades = _trades.trades;

    return Container(
      child: ListView.builder(
        itemCount: trades.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: TradeCard(trade: trades[index]),
            onTap: () => navigateToPage(
              context,
              TradeDetail(tradeId: trades[index].id),
            ),
          );
        },
        scrollDirection: Axis.vertical,
        // shrinkWrap: true,
      ),
    );
  }
}

class TradeCard extends StatelessWidget {
  final trade;
  const TradeCard({this.trade});
  @override
  Widget build(BuildContext context) {
    final _strategies = Provider.of<Strategies>(context, listen: false);
    final _instruments = Provider.of<Instruments>(context, listen: false);
    final _styles = Provider.of<Styles>(context, listen: false);
    final instrument = _instruments.findById(trade.instrument);
    final strategy = _strategies.findById(trade.strategy);
    final style = _styles.findById(trade.style);

    return Card(
      elevation: 0.2,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Colors.black,
              width: 3,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          child: Row(
            children: [
              Container(
                width: 85,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      instrument.name(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          trade.getPosition(),
                          Text(" | "),
                          Text(trade.statusAsText()),
                        ],
                      ),
                    ),
                    Tag(
                      text: strategy.name,
                      background: Colors.green,
                      fsize: 13,
                      fweight: FontWeight.w400,
                      fcolor: Colors.white,
                    )
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      humanizeDate(trade.date),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                    Divider(
                      color: Colors.grey,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                      child: Text(
                        getExerpt(trade.description, 40),
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    // Row(
                    //   children: [
                    //     Tag(
                    //       text: strategy.name,
                    //       background: Colors.grey,
                    //       fsize: 11,
                    //       fweight: FontWeight.w300,
                    //       fcolor: Colors.white,
                    //     ),
                    //     Tag(
                    //       text: strategy.name,
                    //       background: Colors.grey,
                    //       fsize: 11,
                    //       fweight: FontWeight.w300,
                    //       fcolor: Colors.white,
                    //     ),
                    //   ],
                    // )
                  ],
                ),
              ),
              SizedBox(width: 5),
              Container(
                width: 80,
                child: Column(
                  children: [
                    Text(
                      style.name(),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                      child: Text(
                        (trade.outcome ? "+ " : "- ") + trade.pips.toString(),
                        style: TextStyle(
                          color: trade.outcome ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                    Text("RR  1:" + trade.riskReward.toString()),
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

class Tag extends StatelessWidget {
  final String text;
  final Color background;
  final double fsize;
  final FontWeight fweight;
  final Color fcolor;
  const Tag(
      {this.text, this.background, this.fsize, this.fweight, this.fcolor});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 1,
        horizontal: 5,
      ),
      margin: EdgeInsets.only(right: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fcolor,
          fontWeight: fweight,
          fontSize: fsize,
        ),
      ),
    );
  }
}
