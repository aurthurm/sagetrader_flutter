import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:msagetrader/utils/exceptions.dart';


class APIManager {
  Duration timeLimit = Duration(seconds: 10);

  // POST REQUEST
  Future<dynamic> post(String url, Map params) async {
    var responseJson;
    try {
      final response = await http.post(url, body: params).timeout(timeLimit);
      responseJson = responseHandler(response);
    } catch (e) {
      // Defined other Excptions above here
      handleCommonExceptions(e);
    }
    return responseJson;
  }

  // GET REQUEST
  Future<dynamic> get(String url, Map params) async {
    var responseJson;
    try {
      final response = await http.get(url).timeout(timeLimit);
      responseJson = responseHandler(response);
    } catch (e) {
      // Defined other Excptions above here
      handleCommonExceptions(e);
    }
    return responseJson;
  }

}


dynamic responseHandler(http.Response res) {  
  var responseJson = json.decode(res.body.toString()); // res.body ??
  switch(res.statusCode) {
    case 200:      
      return responseJson;
    case 400:
      throw BadRequestException(responseJson['detail']);
    case 401:
    case 403:
      throw UnauthorisedException(res.body.toString());
    case 500:

    default:
      throw UnknownException("(${res.statusCode}) - An Unknown Error Encountered");
  }
}

