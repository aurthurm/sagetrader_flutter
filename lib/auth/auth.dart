import 'dart:convert';

import 'package:msagetrader/config/conf.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final String authURI = serverURI + "login/access-token";

// Create storage
final storage = FlutterSecureStorage();

Map<String, String> bearerAuthHeader(token) {
  return {"Authorization": "Bearer $token"};
}

class MSPTAuth {
  Future<String> token() async {
    final String _token = await storage.read(key: "access_token");
    // print("AuthToken SS: $_token");
    return _token;
  }

  Future<void> clearToken() async {
    await storage.delete(key: "access_token");
  }

  Future<void> resetToken(String token) async {
    await storage.write(key: "access_token", value: token);
    // print("AuthToken New: $token");
  }

  Future<void> authenticate() async {
    final _authData = Map<String, dynamic>();
    _authData['username'] = "admin@admin.com";
    _authData['password'] = "admin";
    final response = await http.post(
      authURI,
      body: _authData,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      resetToken(responseData['access_token']);
    } else {
      clearToken();
    }
    //
  }
}
