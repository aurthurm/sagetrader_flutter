import 'package:flutter/material.dart';
import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/models/trading_plan.dart';
import 'package:msagetrader/providers/trading_plans.dart';
import 'package:msagetrader/screens/trading_plan_detail.dart';
import 'package:msagetrader/utils/snacks.dart';
import 'package:msagetrader/utils/utils.dart';
import 'package:provider/provider.dart';

class SharedTradingPlans extends StatefulWidget {
  const SharedTradingPlans({Key key}) : super(key: key);

  @override
  _SharedTradingPlansState createState() => _SharedTradingPlansState();
}

class _SharedTradingPlansState extends State<SharedTradingPlans> {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Shared Tradig Plans"),
      ),
      body: _PageSharedplans(),
    );
  }
}



class _PageSharedplans extends StatefulWidget {
  @override
  __PageSharedplansState createState() => __PageSharedplansState();
}

class __PageSharedplansState extends State<_PageSharedplans> {
  bool _isInit = true;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent) {
        final _tp = Provider.of<TradingPlans>(context, listen: false);
        if(_tp.hasMoreData()) {
          cpiMsgSnackBar(context, "fetching ---", Theme.of(context).primaryColor, 1);
          _tp..fetchPlans(shared: true, loadMore:true);
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
      Provider.of<TradingPlans>(context, listen: false).fetchPlans(shared: true);
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
    final auth = Provider.of<MSPTAuth>(context);
    final _plans = Provider.of<TradingPlans>(context);
    List<TradingPlan> plans = _plans.getShared(excludeUid: auth.user.uid);

    return Container(
      child: _plans.loading ? 
      Center(
        child: CircularProgressIndicator(
          backgroundColor: Theme.of(context).primaryColor,
        ),
      ) : Padding(
        padding: const EdgeInsets.all(10.0),
        child: RefreshIndicator(
          onRefresh: () => Provider.of<TradingPlans>(context, listen: false).fetchPlans(shared: true),
          child: plans.length > 0 ? ListView.builder(
            controller: scrollController,
            itemCount: plans.length,
            itemBuilder: (context, index) {
              TradingPlan plan = plans[index];
              return Column(
                children: <Widget>[
                  ListTile(
                    visualDensity: VisualDensity.compact,
                    leading: Icon(
                      Icons.center_focus_weak,
                    ),
                    title: Text(
                      plan.title,
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    subtitle: auth.user.uid != plan.owner.uid ? Text(
                        "By " + plan.owner.getFullName(),
                        style: Theme.of(context).textTheme.headline5,
                    ): null,
                    onTap: () => {
                      navigateToPage(context, TradingPlanDetail(planID: plan.uid)),
                    },
                  ),
                  Divider(),
                ],
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
                        "--- There are currently no shared Trading Plans. Be the first to share ---",
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
      )
    );
  }
}