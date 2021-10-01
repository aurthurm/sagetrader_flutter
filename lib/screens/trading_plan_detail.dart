import 'package:flutter/material.dart';
import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/forms/trading_plan_form.dart';
import 'package:msagetrader/models/trading_plan.dart';
import 'package:msagetrader/providers/trading_plans.dart';
import 'package:msagetrader/utils/utils.dart';
import 'package:provider/provider.dart';

class TradingPlanDetail extends StatelessWidget {
  final String planID;
  TradingPlanDetail({Key key, this.planID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<MSPTAuth>(context);
    final _plans = Provider.of<TradingPlans>(context);
    TradingPlan plan = _plans.findById(planID);

    return Scaffold(
      appBar: AppBar(
        title: Text(plan.title,
            style: Theme.of(context).textTheme.headline2.copyWith(
                  color: Colors.white,
                )),
        actions: auth.user.uid == plan.owner.uid
            ? <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  color: Colors.white,
                  onPressed: () {
                    navigateToPage(context,
                        TradingPlanForm(newPlan: false, planID: plan.uid));
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_forever),
                  color: Colors.red,
                  onPressed: () => showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          "Warning",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          "You are about to delete this Tradin Plan. Note that this action is irrevesibe. Are you sure about this?",
                        ),
                        actions: [
                          TextButton(
                            child: Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                              _plans.deleteById(plan.uid);
                            },
                          ),
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ]
            : [],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Plan Detail",
                style: Theme.of(context).textTheme.headline2,
              ),
              Divider(),
              Text(plan.description,
                  style: Theme.of(context).textTheme.bodyText1)
            ],
          ),
        ),
      ),
    );
  }
}
