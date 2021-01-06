import 'package:flutter/material.dart';
import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/models/trading_plan.dart';
import 'package:msagetrader/providers/trading_plans.dart';
import 'package:msagetrader/screens/trading_plan_detail.dart';
import 'package:msagetrader/utils/snacks.dart';
import 'package:msagetrader/utils/utils.dart';
import 'package:provider/provider.dart';

class TradingPlanTab extends StatefulWidget {
  const TradingPlanTab({
    Key key,
  }) : super(key: key);

  @override
  _TradingPlanTabState createState() => _TradingPlanTabState();
}

class _TradingPlanTabState extends State<TradingPlanTab> {
  bool _isInit = true;
  
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent) {
        final _pl = Provider.of<TradingPlans>(context, listen: false);
        if(_pl.hasMoreData()) {
          cpiMsgSnackBar(context, "fetching ---", Theme.of(context).primaryColor, 1);
          _pl..fetchPlans(shared: false, loadMore:true);
        } else {
          doneMsgSnackBar(context, "No more data to load", Colors.orange, 1);
        }
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<TradingPlans>(context, listen: false).fetchPlans();
    }
    setState(() {
      _isInit = false;
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _plans = Provider.of<TradingPlans>(context);
    final me = Provider.of<MSPTAuth>(context);
    List<TradingPlan> plans = _plans.getForUser(me.user.uid);

    return Container(
      child:  _plans.loading ? 
      Center(
        child: CircularProgressIndicator(
          backgroundColor: Theme.of(context).primaryColor,
        ),
      )  : RefreshIndicator(
        onRefresh: () => Provider.of<TradingPlans>(context, listen: false).fetchPlans(),
          child: plans.length > 0 ? ListView.builder(
          controller: scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            TradingPlan plan = plans[index];
            return Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(
                    Icons.center_focus_weak,
                  ),
                  title: Text(
                    plan.title,
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  onTap: () => {
                    navigateToPage(context, TradingPlanDetail(planID: plan.uid)),
                  },
                ),
                Divider(),
              ],
            );
          },
          scrollDirection: Axis.vertical,
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
                      "Plan your Trades and trade your Plan. \n\nTrade what you see, not what you think. \n\nTrading plans help you manage your emotions, they are the BluePrint to your trading career. \n\nTreat trading like a business and its profits will take care of you. \n\nAdd your plans here",
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                      textAlign: TextAlign.justify,
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
