import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:msagetrader/config/conf.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:msagetrader/utils/api.dart';
import 'package:msagetrader/utils/connectivity.dart';
import 'package:msagetrader/utils/exceptions.dart';

final Uri loginURI = Uri.parse(serverURI + "login/access-token");
final Uri usersURI = Uri.parse(serverURI + "users/");

// Create storage
final storage = FlutterSecureStorage();

Map<String, String> bearerAuthHeader(token) {
  return {"Authorization": "Bearer $token"};
}

// User Model
class MSPTUser {
  String firstname;
  String lastname;
  int uid;
  bool isActive;
  bool isSuperuser;
  String token;

  String getFullName() {
    return firstname + " " + lastname;
  }

  MSPTUser(
      {this.token,
      this.uid,
      this.firstname,
      this.lastname,
      this.isSuperuser,
      this.isActive});

  factory MSPTUser.fromJson(Map<String, dynamic> json) {
    return MSPTUser(
      uid: json['uid'],
      firstname: json['first_name'],
      lastname: json['last_name'],
      isActive: json['is_active'],
      isSuperuser: json['is_superuser'],
      token: json['access_token'],
    );
  }
}

class MSPTAuth with ChangeNotifier {
  MSPTUser _user;
  bool _loading = false;
  String _signInMessage = "";
  String _signUpMessage = "";

  Duration timeout = Duration(seconds: 30);

  MSPTUser get user => _user;
  String get signInMessage => _signInMessage;
  String get signUpMessage => _signUpMessage;
  bool get loading => _loading;

  void toggleLoading() => {_loading = !_loading, notifyListeners()};

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

  Future<void> authenticate(String username, String password) async {
    if (checkForNetowk == true) {
      if (await hasInternetAccess() == false)
        throw NoConnectionException("You are offline");
    }
    toggleLoading();
    clearMessages();
    final _authData = Map<String, dynamic>();
    _authData['username'] = username.replaceAll(' ', '');
    _authData['password'] = password.replaceAll(' ', '');

    print(loginURI);
    try {
      var responseJson;
      final response =
          await http.post(loginURI, body: _authData); // .timeout(timeout);
      print(response);
      responseJson = responseHandler(response);
      _user = MSPTUser.fromJson(responseJson);
      resetToken(_user.token);
      toggleLoading();
      return user;
    } catch (err) {
      clearToken();
      _user = null;
      toggleLoading();
      // notifyListeners();
      if (err.toString().contains('Invalid Request')) {
        throw PersistException(err.toString());
      }
      handleCommonExceptions(err);
    }
  }

  Future createUser(dynamic payload) async {
    if (await hasInternetAccess() == false)
      throw NoConnectionException("You are offline");
    toggleLoading();
    clearMessages();

    try {
      var responseJson;
      final response =
          await http.post(usersURI, body: payload).timeout(timeout);
      responseJson = _createResponseHandler(response);
      _user = MSPTUser.fromJson(responseJson);
      resetToken(_user.token);
      toggleLoading();
      return user;
    } catch (err) {
      toggleLoading();
      if (err.toString().contains('Invalid Request')) {
        throw PersistException(err.toString());
      }
      handleCommonExceptions(err);
    }
  }

  _createResponseHandler(res) {
    var responseJson = json.decode(res.body.toString()); // res.body ??
    var message = responseJson['detail'];
    switch (res.statusCode) {
      case 200:
        return responseJson;
      case 400:
        _signUpMessage = message;
        notifyListeners();
        throw BadRequestException(message);
      case 401:
      case 403:
        throw UnauthorisedException(message);
      case 500:

      default:
        _signUpMessage =
            "Error in creating your account: try again in a few minutes";
        notifyListeners();
        throw UnknownException(
            "(${res.statusCode}) - An Unknown Error Encountered");
    }
  }

  Future<bool> logout() async {
    await Future.delayed(Duration(seconds: 1)).then((_) {
      _user = null;
      clearMessages();
      clearToken();
      notifyListeners();
    });
    return true;
  }
}
