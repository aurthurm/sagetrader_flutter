import 'package:flutter/material.dart';
import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/auth/auth_redirect.dart';
import 'package:msagetrader/providers/attributes.dart';
import 'package:msagetrader/providers/files.dart';
import 'package:msagetrader/providers/studies.dart';
import 'package:msagetrader/providers/study_items.dart';
import 'package:msagetrader/providers/tasks.dart';
import 'package:msagetrader/providers/trading_plans.dart';
import 'package:msagetrader/styles.dart';
import 'package:provider/provider.dart';
import 'package:msagetrader/providers/trades.dart';
import 'package:msagetrader/providers/strategies.dart';
import 'package:msagetrader/providers/instruments.dart';
import 'package:msagetrader/providers/styles.dart';

void main() => runApp(MSPTApp()); // MSPT: Meticulous Sage Precision Trading Journaling App

class MSPTApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MSPTAuth(),
        ),
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
        ChangeNotifierProvider(
          create: (context) => Studies(),
        ),
        ChangeNotifierProvider(
          create: (context) => StudyItems(),
        ),
        ChangeNotifierProvider(
          create: (context) => Attributes(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: true,
        theme: MSPTTheme.lightTheme,
        home: AuthCheckRedirect(),
      ),
    );
  }
}