import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/providers/strategies.dart';
import 'package:flutter/material.dart';
import 'package:msagetrader/screens/strategy_detail.dart';
import 'package:msagetrader/utils/snacks.dart';
import 'package:msagetrader/utils/utils.dart';
import 'package:msagetrader/models/strategy.dart';
import 'package:provider/provider.dart';

class StrategiesTab extends StatefulWidget {
  @override
  _StrategiesTabState createState() => _StrategiesTabState();
}

class _StrategiesTabState extends State<StrategiesTab> {

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent) {
        final _st = Provider.of<Strategies>(context, listen: false);
        if(_st.hasMoreData()) {
          cpiMsgSnackBar(context, "fetching ---", Theme.of(context).primaryColor, 1);
          _st.fetchStrategies(shared: false, loadMore:true);
        } else {
          doneMsgSnackBar(context, "No more data to load", Colors.orange, 1);
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final _strategies = Provider.of<Strategies>(context);
    final me = Provider.of<MSPTAuth>(context);
    List<Strategy> strategies = _strategies.getForUser(me.user.uid);

    return Container(
      child: _strategies.loading ? 
      Center(
        child: CircularProgressIndicator(
          backgroundColor: Theme.of(context).primaryColor,
        ),
      )  : RefreshIndicator(
        onRefresh: () => Provider.of<Strategies>(context, listen: false).fetchStrategies(),
        child: strategies.length > 0 ? ListView.builder(
          controller: scrollController,
          itemCount: strategies.length,
          scrollDirection: Axis.vertical,
          // shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            Strategy strategy = strategies[index];
            return GestureDetector(
              child: StrategyCard(strategy: strategy),
              onTap: () => navigateToPage(
                context,
                StrategyDetail(strategyId: strategy.uid),
              ),
            );
          },
        )
      : ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return Column(
              children: [
                SizedBox(height: 50),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 40),
                    child: Text(
                      "Strategies are required before you start journaling your trades. \n\nClick the button to add your first Strategy.",
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: Theme.of(context).primaryColor,
                      )
                    ),
                  ),
                ),
              ],
            );
          },
          scrollDirection: Axis.vertical,
        ),
      ),
    );
  }
}

class StrategyCard extends StatelessWidget {
  final Strategy strategy;
  StrategyCard({this.strategy});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<MSPTAuth>(context);

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
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Colors.green,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 5),
                      child: Text(
                        strategy.winRate(),
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                    Text(
                      strategy.lost.toString(),
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Colors.red,
                      ),
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
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    auth.user.uid != strategy.owner.uid ? SizedBox(height: 2) : SizedBox(height: 0),
                    auth.user.uid != strategy.owner.uid ? Text(
                      "By " + strategy.owner.getFullName(),
                      style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Theme.of(context).primaryColor.withOpacity(0.6),
                      ),
                    ): Container(),
                    SizedBox(height: 4),
                    Text(
                      getExerpt(strategy.description, 45),
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
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
