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

    return ListView.builder(
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
                navigateToPage(context, TradingPlanDetail(planID: plan.id)),
              },
            ),
            Divider(),
          ],
        );
      },
    );
  }
}
