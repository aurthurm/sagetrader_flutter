import 'package:flutter/material.dart';
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
    final _plans = Provider.of<TradingPlans>(context);
    TradingPlan plan = _plans.findById(planID);

    return Scaffold(
      appBar: AppBar(
        title: Text(plan.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            color: Colors.black,
            onPressed: () {
              navigateToPage(
                  context, TradingPlanForm(newPlan: false, planID: plan.id));
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
                    ),
                  ),
                  content: Text(
                    "You are about to delete this Tradin Plan. Note that this action is irrevesibe. Are you sure about this?",
                  ),
                  actions: [
                    FlatButton(
                      child: Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // pop alert dialog
                        Navigator.of(context).pop(); // pop from deleted trade
                        _plans.deleteById(plan.id);
                      },
                    ),
                    FlatButton(
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
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Plan Detail",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            Divider(),
            Text(plan.description)
          ],
        ),
      ),
    );
  }
}
