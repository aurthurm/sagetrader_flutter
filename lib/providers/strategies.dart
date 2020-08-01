import 'dart:convert';

import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/config/conf.dart';
import 'package:msagetrader/models/strategy.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String token;
final String strategiesURI = serverURI + "mspt/strategy";

/*
 * Provider: Strateies Provider
*/
class Strategies with ChangeNotifier {
  List<Strategy> _strategies = <Strategy>[];

  List<Strategy> get strategies => _strategies;

  Strategy findById(String id) {
    final index = strategies.indexWhere((strat) => strat.id == id);
    return strategies[index];
  }

  ///////
  ///

  Future<void> deleteById(String id) async {
    final _oldIndex = _strategies.indexWhere((inst) => inst.id == id);
    Strategy _oldStrategy = _strategies[_oldIndex];
    _strategies.removeWhere((strategy) => strategy.id == id);
    notifyListeners();

    await MSPTAuth().token().then((String value) => token = value);

    final response = await http.delete(
      strategiesURI + "/$id",
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      _oldStrategy = null;
    } else {
      _strategies.add(_oldStrategy);
      notifyListeners();
    }
  }

  Future<void> addStrategy(Strategy strategy) async {
    await MSPTAuth().token().then((String value) => token = value);
    final response = await http.post(
      strategiesURI,
      body: json.encode(
        {
          "name": strategy.name,
          "description": strategy.description,
        },
      ),
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      dynamic responseData = json.decode(response.body);
      Strategy newStrategy = Strategy.fromJson(responseData);
      _strategies.add(newStrategy);
      notifyListeners();
    } else {
      print("StatusCode: ${response.statusCode}");
      print("Error Body: ${response.body}");
      // Exception('Failed to Add instrument');
    }
    // _instruments.add(_instrument);
    // notifyListeners();
  }

  Future<void> updateStrategy(Strategy editedStrategy) async {
    final index =
        _strategies.indexWhere((strategy) => strategy.id == editedStrategy.id);
    final _oldStrategy = _strategies[index];
    _strategies[index] = editedStrategy;
    notifyListeners();

    await MSPTAuth().token().then((String value) => token = value);
    final response = await http.put(
      strategiesURI + "/${editedStrategy.id}",
      headers: bearerAuthHeader(token),
      body: json.encode(
        {
          "id": editedStrategy.id,
          "name": editedStrategy.name,
        },
      ),
    );

    if (response.statusCode == 200) {
    } else {
      _strategies[index] = _oldStrategy;
      print("StatusCode: ${response.statusCode}");
      print("Error Body: ${response.body}");
    }
  }

  Future<void> fetchStrategies() async {
    await MSPTAuth().token().then((String value) => token = value);
    final response = await http.get(
      strategiesURI,
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      // print(responseData);
      responseData.forEach((item) {
        //dont add if instrument exists in case of multi reloads
        final Strategy inComing = Strategy.fromJson(item);
        final elements =
            _strategies.where((element) => element.id == inComing.id);
        if (elements.length == 0) {
          _strategies.add(inComing);
        }
      });
      notifyListeners();
    } else if (response.statusCode == 401) {
      final String message = json.decode(response.body)['detail'];
      print("Error: ${response.statusCode} : $message");
    } else {
      print("StatusCode: ${response.statusCode}");
      print("Error Response Body: ${response.body}");
      Exception('Failed to load Strategies');
    }
    //
  }
}
