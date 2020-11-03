import 'package:flutter/material.dart';
import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/forms/log_in_form.dart';
import 'package:msagetrader/forms/sign_up_form.dart';
import 'package:provider/provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  bool isWelcomePage = true;
  bool loginAction = true;
  List<String> fxImages = ["fx0.jpg"]; // , "fx1.jpg", "fx4.png"
  String welcomeText = "";
  List<Widget> welcomeLogin;
  Widget loginSignUP = LogInForm();
  String loginSignUPText = "Sign In to MSPT";
  String hasAccount = "No Account? Sign Up Now.";

  void toggleUserAction(bool val) => {

    if(val == null) {
      setState(() {
        loginAction = !loginAction;
      })
    } else {
      setState(() {
        loginAction = val;
      })      
    }
  };

  void toggleWelcome(bool val) => {
    setState(() {
      if (loginAction != val) loginAction = val;      
      isWelcomePage = !isWelcomePage;
    }),
  };

  List<Widget> _buildLoginSignUP() {
    return [
      Text(
        loginSignUPText,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 28,                        
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 25),
      Container(
        child: Card(
          color: Colors.transparent,
          elevation: 1,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20), 
            child: AnimatedSize(
              vsync: this,
              curve: Curves.slowMiddle,
              duration: Duration(milliseconds: 310),
              child: Container(
                child: loginSignUP, // _login_or_signup
              )
            )
          ), 
        ),
      ),     
      SizedBox(height: 25),      
      Center(
        child: FlatButton.icon(
          onPressed: () => toggleUserAction(null), 
          icon: Icon(Icons.login, color: Colors.transparent, size: 0,), 
          label:  AnimatedSwitcher(
            duration: Duration(milliseconds: 310),
            child: Text(
              hasAccount,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 16,                        
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),                         
      Center(
        child: FlatButton.icon(
          onPressed: () => toggleWelcome(true), 
          icon: Icon(Icons.chevron_left, color: Colors.white, size: 14,), 
          label:  AnimatedSwitcher(
            duration: Duration(milliseconds: 310),
            child: Text(
              "back home",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 16,  
                fontStyle: FontStyle.italic,                      
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      )
    ];
  }

  List<Widget> _buildWelcome() {
    return [
      Center(
        child: Text(
          "Welcome to MSPT", 
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
          ),
        ),
      ),
      Center(
        child: Text(
          "Meticulous Sage Precision Trading", 
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      SizedBox(height: 50),
      Divider(color: Colors.grey,),
      SizedBox(height: 10),
      Center(
        child: Text(
          "Plan your trades and trade your plan", 
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      SizedBox(height: 10),
      Divider(color: Colors.grey,),
      SizedBox(height: 20),
      Center(
        child: Text(
          "To Get Started", 
          style: TextStyle(
            color: Colors.orange,
            fontSize: 24,
          ),
        ),
      ),
      SizedBox(height: 20),
      Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton.icon(
              onPressed: () => toggleWelcome(true), 
              icon: Icon(Icons.login, color: Colors.black, size: 15,), 
              color: Colors.orange,
              label:  AnimatedSwitcher(
                duration: Duration(milliseconds: 310),
                child: Text(
                  "Sign In",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,                        
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Text(
             " / ",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 32,                        
              ),
            ),
            RaisedButton.icon(
              onPressed: () => toggleWelcome(false),  
              icon: Icon(Icons.login, color: Colors.transparent, size: 0,), 
              color: Colors.green,
              label:  AnimatedSwitcher(
                duration: Duration(milliseconds: 310),
                child: Text(
                  "Join Our Family",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,                        
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ]
        )
      ),
      SizedBox(height: 10),
      Divider(color: Colors.grey,),
      SizedBox(height: 10),
      Center(
        child: Text(
          "An amazing trading journal always by your pocket", 
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
          textAlign: TextAlign.left,
        ),
      ),
      SizedBox(height: 20),
      Center(
        child: Text(
          "--- built by a trader for traders ---", 
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontStyle:  FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {

    if(loginAction) {   // loginAction ? LogInForm() : SignUpForm()
      setState(() {
        loginSignUP = LogInForm();
        loginSignUPText = "Sign In to MSPT";
        hasAccount = "No Account? Sign Up Now.";
      });
    } else {
      loginSignUP = SignUpForm();
      loginSignUPText = "Join the MSPT family";
      hasAccount = "Already have an Account? Sign In instead.";
    }

    if (isWelcomePage) {
      setState(() {
        welcomeLogin = _buildWelcome();
      });
    } else {
      setState(() {
        welcomeLogin = _buildLoginSignUP();
      });
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/" + (fxImages..shuffle()).first, 
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.7),
            colorBlendMode: BlendMode.darken,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: welcomeLogin,
                )
              ),
            ),
          ),
        ],
      ),
    );
  }
}
