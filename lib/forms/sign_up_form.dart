import 'dart:convert';
import 'package:msagetrader/auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    Key key,
  }) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  String email, firstname, lastname, password1, password2;
  @override
  void initState() {
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

  //Focus Nodes
  FocusNode _lastNameFocus = FocusNode();
  FocusNode _emailFocus = FocusNode();
  FocusNode _password1Focus = FocusNode();
  FocusNode _password2Focus = FocusNode();

  //Validations
  String _validateLength(v, chars, msg) {
    if (v.toString().length < chars) {
      return msg;
    }
    return null;
  }

  String _validatePasswordMatch(v, msg) {
    if (v.toString() != password1.toString()) {
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
      final payload = json.encode({
        "email": email,
        "first_name": firstname,
        "last_name": lastname,
        "password": password1,
      });
      await _auth.createUser(payload);
    } else {
      return;
    }
  }

  InputDecoration _buildInputHintDecoration(String hintText) {
    return InputDecoration(
      isDense: true,
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
      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }



  @override
  Widget build(BuildContext context) {
    final _auth = Provider.of<MSPTAuth>(context, listen: false);

    return Builder(
      builder: (context) => Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              style: TextStyle(color: Colors.white,),
              decoration: _buildInputHintDecoration("Enter your First Name ..."),   
              initialValue: firstname,
              onChanged: (String value) {
                setState(() {
                  firstname = value;
                });
              },
              validator: (value) => _validateLength(
                value,
                1,
                "Provide your First Name",
              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context)
                    .requestFocus(_lastNameFocus);
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              style: TextStyle(color: Colors.white,),
              decoration: _buildInputHintDecoration("Enter your Last Name ..."),
              initialValue: lastname,
              onChanged: (String value) {
                setState(() {
                  lastname = value;
                });
              },
              validator: (value) => _validateLength(
                value,
                1,
                "Provide your Last Name",
              ),
              textInputAction: TextInputAction.next,
              focusNode: _lastNameFocus,
              onFieldSubmitted: (_) {
                FocusScope.of(context)
                    .requestFocus(_emailFocus);
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              style: TextStyle(color: Colors.white,),
              decoration:  _buildInputHintDecoration("Enter your Email Adress ..."),
              initialValue: email,
              onChanged: (String value) {
                setState(() {
                  email = value;
                });
              },
              validator: (value) => _validateLength(
                value,
                1,
                "Provide a valid Email",
              ),
              textInputAction: TextInputAction.next,
              focusNode: _emailFocus,
              onFieldSubmitted: (_) {
                FocusScope.of(context)
                    .requestFocus(_password1Focus);
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              style: TextStyle(color: Colors.white,),
              obscureText: true,
              decoration:  _buildInputHintDecoration("Enter your password ..."),
              initialValue: password1,
              onChanged: (String value) {
                setState(() {
                  password1 = value;
                });
              },
              validator: (value) => _validateLength(
                value,
                5,
                "Password must not less than 5 characters",
              ),
              textInputAction: TextInputAction.next,
              focusNode: _password1Focus,
              onFieldSubmitted: (_) {
                FocusScope.of(context)
                    .requestFocus(_password2Focus);
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              style: TextStyle(color: Colors.white,),
              obscureText: true,
              decoration:  _buildInputHintDecoration("Confirm your Password"),
              initialValue: password2,
              onChanged: (String value) {
                setState(() {
                  password2 = value;
                });
              },
              validator: (value) => _validatePasswordMatch(
                value,
                "Passwords Dont Match",
              ),
              textInputAction: TextInputAction.none,
              focusNode: _password2Focus,
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                _auth.signUpMessage,
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: Colors.red,
                ),
              ),
            ),
            SizedBox(height: 15),
            _auth.loading ? 
            Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              )
            ) :
            RaisedButton(
              color: Colors.orange,
              child: Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              onPressed: _saveForm,
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
