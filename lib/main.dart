import 'package:flutter/material.dart';
import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/providers/files.dart';
import 'package:msagetrader/providers/tasks.dart';
import 'package:msagetrader/providers/trading_plans.dart';
import 'package:msagetrader/screens/instruments.dart';
import 'package:provider/provider.dart';
import 'package:msagetrader/forms/strategy_form.dart';

import 'package:msagetrader/tabs/calculators.dart';
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

import 'forms/trading_plan_form.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Trades(),
        ),
        ChangeNotifierProvider(
          create: (context) => Strategies(),
        ),
        ChangeNotifierProvider(
          create: (context) => Instruments(),
        ),
        ChangeNotifierProvider(
          create: (context) => Styles(),
        ),
        ChangeNotifierProvider(
          create: (context) => Files(),
        ),
        ChangeNotifierProvider(
          create: (context) => TradingPlans(),
        ),
        ChangeNotifierProvider(
          create: (context) => Tasks(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Home(),
      ),
    );
  }
}

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
    //     print("Inside initState fetching instruments $_isInit");
    //     Provider.of<Instruments>(context).fetchInstruments();
    //   },
    // );

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      MSPTAuth().authenticate().then(
            (_) => {
              Provider.of<Instruments>(context, listen: false)
                  .fetchInstruments(),
              Provider.of<Strategies>(context, listen: false).fetchStrategies(),
              Provider.of<Styles>(context, listen: false).fetchStyles(),
              Provider.of<Trades>(context, listen: false).fetchTrades(),
            },
          );
    }
    setState(() {
      _isInit = false;
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              padding: EdgeInsets.zero,
              height: 130,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Aurthur Musendame",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    Divider(
                      color: Colors.grey,
                    ),
                    Text(
                      "Being a One Shot One Kill Trader is an art.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
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
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              onTap: () => {
                navigateToPage(context, InstrumentsPage()),
              },
            ),
            ListTile(
              leading: Icon(Icons.edit_attributes),
              title: Text(
                "Trade Attributes",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
            Divider(color: Colors.grey),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text(
                "Account",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text(
                "Notifications",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
            Divider(color: Colors.grey),
            ListTile(
              leading: Icon(Icons.web),
              title: Text(
                "MSPT Web",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
            Divider(color: Colors.grey),
            ListTile(
              leading: Icon(Icons.watch_later),
              title: Text(
                "Watch List",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text(
                "Studies",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
            Divider(color: Colors.grey),
            ListTile(
              leading: Icon(Icons.new_releases),
              title: Text(
                "Fundamentals Notes",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Meticulous Sage Precision Trading"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: menuItems.map<Widget>((MenuItem item) {
            return Tab(text: item.title, icon: Icon(item.icon));
          }).toList(),
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
  TradingPlanTab(),
  TasksTab(),
  CalculatorsTab(),
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
      );
    case 2:
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
      );
    case 3:
      return FloatingActionButton(
        onPressed: null,
        child: FABStack(icon: Icons.speaker_notes),
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
