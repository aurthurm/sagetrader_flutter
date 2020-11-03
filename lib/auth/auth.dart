import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:msagetrader/config/conf.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final String loginURI = serverURI + "login/access-token";
final String usersURI = serverURI + "users/";

// Create storage
final storage = FlutterSecureStorage();

Map<String, String> bearerAuthHeader(token) {
  return {"Authorization": "Bearer $token"};
}

// User Model
class MSPTUser {
  String firstname;
  String lastname;
  String token;

  MSPTUser({this.token, this.firstname, this.lastname});

  factory MSPTUser.fromJson(Map<String, dynamic> json) {
    return MSPTUser(
      firstname: json['first_name'],
      lastname: json['last_name'],
      token: json['access_token'],
    );
  }

}

class MSPTAuth with ChangeNotifier {
  MSPTUser _user;
  bool _loading = false;
  String _signInMessage = "";
  String _signUpMessage = "";

  MSPTUser get user => _user;
  String get signInMessage => _signInMessage;
  String get signUpMessage => _signUpMessage;
  bool get loading => _loading;

  void toggleLoading() => {
    _loading = !_loading,
    notifyListeners()
  };

  Future<String> getToken() async {
    final String _token = await storage.read(key: "access_token");
    return _token;
  }

  void clearMessages() {
    _signInMessage = "";
    _signUpMessage = "";
    notifyListeners();
  }

  Future<void> clearToken() async {
      await storage.delete(key: "access_token");
      clearMessages();
    }

    Future<void> resetToken(String token) async {
      await storage.write(key: "access_token", value: token);
      clearMessages();
    }

    Future<MSPTUser> authenticate(String username, String password) async {
      toggleLoading();
      clearMessages();
      final _authData = Map<String, dynamic>();
      _authData['username'] = username;
      _authData['password'] = password;

      final response = await http.post(
        loginURI,
        body: _authData,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> payload = json.decode(response.body);
        _user = MSPTUser.fromJson(payload);
        resetToken(_user.token);
        // _signInMessage = "You were successfully logged in ...";
        toggleLoading();
        notifyListeners();

      } else if (response.statusCode == 400){
        Map<String, dynamic> payload = json.decode(response.body);
        _signInMessage = payload['detail'];
        toggleLoading(); 
        notifyListeners();     
      } else {
        clearToken();
        _user = null;
        toggleLoading();
        notifyListeners();
        Exception("(${response.statusCode}): ${response.body}");
      }
      return user;
    }

    Future createUser(dynamic payload) async {
      toggleLoading();
      clearMessages();
      final response = await http.post(
        usersURI,
        body: payload,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> payload = json.decode(response.body);
        _user = MSPTUser.fromJson(payload);
        resetToken(_user.token);
        _signUpMessage = "Welcome ${_user.firstname}. Your Account is ready - we wish you Good Luck and Good Trading";
        toggleLoading();
        notifyListeners();      
      } else if (response.statusCode == 400) {
        _signUpMessage = json.decode(response.body)['detail'];
        notifyListeners();
      } else {
        _signUpMessage = "Error in creating your account: try again in a few minutes";
        notifyListeners(); 
        Exception("Error encountered, try again");
      }
    }

    void logout() {
      _user = null;
      clearMessages();
      clearToken();
      notifyListeners();
    }
}
