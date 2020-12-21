import 'package:flutter/material.dart';
import 'package:msagetrader/models/trading_plan.dart';
import 'package:msagetrader/providers/trading_plans.dart';
import 'package:msagetrader/screens/trading_plan_detail.dart';
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
  Widget build(BuildContext context) {
    final _plans = Provider.of<TradingPlans>(context);
    List<TradingPlan> plans = _plans.plans;

    return Container(
      child: plans.length > 0 ?
      ListView.builder(
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
      )
      : Center(
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
    );
  }
}
