import 'package:flutter/material.dart';
import 'package:msagetrader/widgets/offline.dart';
import 'package:provider/provider.dart';

import 'package:msagetrader/auth/auth.dart';

class LogInForm extends StatefulWidget {
  const LogInForm({
    Key key,
  }) : super(key: key);

  @override
  _LogInFormState createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  String username, password, errorMsgs;
  bool showError = false;
  @override
  void initState() {
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

  //Focus Nodes
  FocusNode _passwordFocus = FocusNode();

  //Validations
  String _validateLength(v, chars, msg) {
    if (v.toString().length < chars) {
      return msg;
    }
    return null;
  }

  void _saveForm() async {
    final _auth = Provider.of<MSPTAuth>(context, listen: false);
    _auth.clearMessages();
    bool formIsValid = _formKey.currentState.validate();
    if (formIsValid) {
      _formKey.currentState.save();
      await _auth.authenticate(username, password).catchError((onError) {
        setState(() {
          showError = true;
          errorMsgs = onError.toString();
        });
      });
    } else {
      return;
    }
  }

  InputDecoration _buildInputHintDecoration(String hintText, Icon icon) {
    return InputDecoration(
      isDense: true,
      prefixIcon: icon,
      // labelStyle: TextStyle(
      //   color: Colors.white,
      // ),
      // labelText: "Email",
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.white,
      ),
      filled: true,
      fillColor: Colors.blueGrey.withOpacity(0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(40.0)),
        borderSide: BorderSide(
          width: 0,
          style: BorderStyle.none,
        ),
      ),
    );
  }

  Widget _buildEmailFormField() {
    return Container(
      child: TextFormField(
        style: TextStyle(color: Colors.white),
        decoration: _buildInputHintDecoration(
            "Enter your Email ...",
            Icon(
              Icons.email,
              color: Colors.white,
            )),
        initialValue: username,
        onChanged: (String value) {
          setState(() {
            username = value;
          });
        },
        validator: (value) => _validateLength(
          value,
          1,
          "Email Required",
        ),
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(_passwordFocus);
        },
      ),
    );
  }

  Widget _buildPasswordFormField() {
    return Container(
        child: ClipRect(
      // clipper: ,
      child: TextFormField(
        style: TextStyle(color: Colors.white),
        decoration: _buildInputHintDecoration(
            "Enter your Password ...",
            Icon(
              Icons.lock,
              color: Colors.white,
            )),
        initialValue: password,
        obscureText: true,
        onChanged: (String value) {
          setState(() {
            password = value;
          });
        },
        validator: (value) => _validateLength(
          value,
          1,
          "Password Required",
        ),
        textInputAction: TextInputAction.next,
        focusNode: _passwordFocus,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final _auth = Provider.of<MSPTAuth>(context);

    return Builder(
      builder: (context) => Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildEmailFormField(),
            SizedBox(height: 10),
            _buildPasswordFormField(),
            SizedBox(height: 15),
            Center(
              child: Text(
                _auth.signInMessage,
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      color: Colors.red,
                    ),
              ),
            ),
            SizedBox(height: 15),
            _auth.loading
                ? Center(
                    child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ))
                : ElevatedButton(
                    // color: Colors.orange,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.login,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 20),
                        Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                    onPressed: _saveForm,
                  ),
            showError ? offlineMessageCard(context, errorMsgs) : Text(""),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
