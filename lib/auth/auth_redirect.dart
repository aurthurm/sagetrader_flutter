import 'package:flutter/material.dart';
import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/auth/log_in_sign_up.dart';
import 'package:msagetrader/screens/home.dart';
import 'package:provider/provider.dart';

class AuthCheckRedirect extends StatefulWidget {
  const AuthCheckRedirect({Key key}) : super(key: key);

  @override
  _AuthCheckRedirectState createState() => _AuthCheckRedirectState();
}

class _AuthCheckRedirectState extends State<AuthCheckRedirect> {
 Widget welcomeOrHome;

  @override
  Widget build(BuildContext context) {
    final _authService = Provider.of<MSPTAuth>(context, listen: true);

    if (_authService.user == null) {
      setState(() {
        welcomeOrHome = WelcomePage();
      });
    } else {
      setState(() {
        welcomeOrHome = Home();
      });      
    }
   
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      switchInCurve: Curves.elasticIn,
      switchOutCurve: Curves.bounceInOut,
      child: welcomeOrHome,
    );// _user == null ? WelcomePage() : Home();
  }
}

