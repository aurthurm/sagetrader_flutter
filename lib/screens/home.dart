import 'package:flutter/material.dart';
import 'package:msagetrader/auth/auth.dart';

import 'package:msagetrader/forms/study_form.dart';
import 'package:msagetrader/forms/task_form.dart';
import 'package:msagetrader/providers/studies.dart';
import 'package:msagetrader/screens/cot_biases.dart';
import 'package:msagetrader/screens/cot_data.dart';
import 'package:msagetrader/screens/instruments.dart';
import 'package:msagetrader/screens/shared_strategies.dart';
import 'package:msagetrader/screens/shared_studies.dart';
import 'package:msagetrader/screens/shared_trades.dart';
import 'package:msagetrader/screens/shared_trading_plans.dart';

import 'package:provider/provider.dart';
import 'package:msagetrader/forms/strategy_form.dart';

import 'package:msagetrader/tabs/studies.dart';
import 'package:msagetrader/tabs/statistics.dart';
import 'package:msagetrader/tabs/strategies.dart';
import 'package:msagetrader/tabs/tasks.dart';
import 'package:msagetrader/tabs/trading_plan.dart';
import 'package:msagetrader/tabs/trades.dart';

import 'package:msagetrader/forms/trade_form.dart';
import 'package:msagetrader/utils/utils.dart';

import 'package:msagetrader/widgets/fab_stack.dart';
import 'package:msagetrader/models/menu_item.dart';

import 'package:msagetrader/providers/trades.dart';
import 'package:msagetrader/providers/strategies.dart';
import 'package:msagetrader/providers/instruments.dart';
import 'package:msagetrader/providers/styles.dart';

import 'package:msagetrader/forms/trading_plan_form.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int index;
  TabController _tabController;
  bool _isInit = true;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: menuItemTabs.length);
    _tabController.addListener(() {
      setState(() {
        index = _tabController.index;
      });
    });

    // Using didChangeDependencies
    // Future.delayed(Duration.zero).then(
    //   (_) {
    //     Provider.of<Instruments>(context).fetchInstruments();
    //   },
    // );

    super.initState();
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isInit = false;
      });
      // Async await to enforce fetch order: Otherwise use .then((_) => next_here)
      await Provider.of<Instruments>(context, listen: false).fetchInstruments();
      await Provider.of<Strategies>(context, listen: false).fetchStrategies();
      await Provider.of<Styles>(context, listen: false).fetchStyles();
      await Provider.of<Trades>(context, listen: false).fetchTrades();
      await Provider.of<Studies>(context, listen: false).fetchStudies();
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _auth = Provider.of<MSPTAuth>(context, listen: true);
    final traderName =
        _auth.user?.firstname == null ? "Hello Trader" : _auth.user.firstname;

    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                padding: EdgeInsets.zero,
                height: 130,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        traderName,
                        style: Theme.of(context)
                            .textTheme
                            .headline1
                            .copyWith(color: Colors.white),
                      ),
                      Divider(
                        color: Colors.grey,
                      ),
                      Text(
                        "Plan your trades and trade your plan",
                        style: Theme.of(context).textTheme.headline4.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.assignment),
                title: Text(
                  "Instruments",
                  style: Theme.of(context).textTheme.headline2,
                ),
                onTap: () => {
                  navigateToPage(context, InstrumentsPage()),
                },
              ),
              Divider(color: Colors.grey),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Center(
                  child: Text(
                    " --- From the Community --- ",
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ),
              ),
              Divider(color: Colors.grey),
              ListTile(
                leading: Icon(Icons.edit_attributes),
                title: Text(
                  "Shared Trades",
                  style: Theme.of(context).textTheme.headline2,
                ),
                onTap: () => {
                  navigateToPage(context, SharedTrades()),
                },
              ),
              ListTile(
                leading: Icon(Icons.edit_attributes),
                title: Text(
                  "Shared Strategies",
                  style: Theme.of(context).textTheme.headline2,
                ),
                onTap: () => {
                  navigateToPage(context, SharedStrategies()),
                },
              ),
              ListTile(
                leading: Icon(Icons.edit_attributes),
                title: Text(
                  "Shared Studies",
                  style: Theme.of(context).textTheme.headline2,
                ),
                onTap: () => {
                  navigateToPage(context, SharedStudies()),
                },
              ),
              ListTile(
                leading: Icon(Icons.edit_attributes),
                title: Text(
                  "Shared Trading Plans",
                  style: Theme.of(context).textTheme.headline2,
                ),
                onTap: () => {
                  navigateToPage(context, SharedTradingPlans()),
                },
              ),
              Divider(color: Colors.grey),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Center(
                  child: Text(
                    " --- Other --- ",
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.edit_attributes),
                title: Text(
                  "COT Data",
                  style: Theme.of(context).textTheme.headline2,
                ),
                onTap: () => {
                  navigateToPage(context, COTData()),
                },
              ),
              ListTile(
                leading: Icon(Icons.edit_attributes),
                title: Text(
                  "COT Pair Biases",
                  style: Theme.of(context).textTheme.headline2,
                ),
                onTap: () => {
                  navigateToPage(context, COTPairBias()),
                },
              ),
              Divider(color: Colors.grey),
              Center(
                child: TextButton.icon(
                  onPressed: () => _auth.logout(),
                  icon: Icon(Icons.logout),
                  label: Text(
                    "Log Out",
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text("Meticulous Sage Precision Trading"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: menuItems.map<Widget>((MenuItem item) {
            return Tab(text: item.title, icon: Icon(item.icon));
          }).toList(),
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: menuItemTabs.map<Widget>((pageTab) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: pageTab,
          );
        }).toList(),
      ),
      floatingActionButton: menuItemFABs(context, _tabController.index),
    );
  }
}

/* 
 * A list of of Pages that correspond to the Menu Tabs.
 * The list maintains the order for Menu Tabs
 */
List<dynamic> menuItemTabs = <dynamic>[
  TradesTab(),
  StrategiesTab(),
  StudiesTab(),
  TradingPlanTab(),
  TasksTab(),
  StatisticsTab()
];

/* 
 * Floating Action Buttons.
 */
Widget menuItemFABs(BuildContext context, index) {
  switch (index) {
    case 0:
      return FloatingActionButton(
        onPressed: () {
          navigateToPage(
            context,
            TradeForm(newTrade: true, tradeID: null),
          );
        },
        child: FABStack(icon: Icons.assessment),
        backgroundColor: Theme.of(context).primaryColor,
      );
    case 1:
      return FloatingActionButton(
        onPressed: () {
          navigateToPage(
            context,
            StrategyForm(newStrategy: true, strategyID: null),
          );
        },
        child: FABStack(icon: Icons.adjust),
        backgroundColor: Theme.of(context).primaryColor,
      );
    case 2:
      return FloatingActionButton(
        onPressed: () {
          navigateToPage(
            context,
            StudyForm(
              newStudy: true,
              studyID: null,
            ),
          );
        },
        child: FABStack(icon: Icons.refresh),
        backgroundColor: Theme.of(context).primaryColor,
      );
    case 3:
      return FloatingActionButton(
        onPressed: () {
          navigateToPage(
            context,
            TradingPlanForm(
              newPlan: true,
              planID: null,
            ),
          );
        },
        child: FABStack(icon: Icons.work),
        backgroundColor: Theme.of(context).primaryColor,
      );
    case 4:
      return FloatingActionButton(
        onPressed: () {
          navigateToPage(
            context,
            TaskForm(
              newTask: true,
              taskID: null,
            ),
          );
        },
        child: FABStack(icon: Icons.speaker_notes),
        backgroundColor: Theme.of(context).primaryColor,
      );
      break;
    default:
      return Visibility(
        visible: false,
        child: FloatingActionButton(
          onPressed: null,
          child: Icon(Icons.error, size: 50),
          foregroundColor: Colors.red,
          backgroundColor: Colors.transparent,
        ),
      );
  }
}
