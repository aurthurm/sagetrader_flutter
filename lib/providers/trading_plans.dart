import 'dart:convert';

import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/config/conf.dart';
import 'package:msagetrader/models/trading_plan.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

String token;
final String tradingPlansURI = serverURI + "mspt/trading-plan";

class TradingPlans with ChangeNotifier {
  List<TradingPlan> _plans = <TradingPlan>[];
  List<TradingPlan> get plans => _plans;

  TradingPlan findById(String id) {
    final index = _plans.indexWhere((item) => item.id == id);
    return _plans[index];
  }

  Future<void> deleteById(String id) async {
    final _oldIndex = _plans.indexWhere((item) => item.id == id);
    TradingPlan _oldPlan = _plans[_oldIndex];
    _plans.removeWhere((item) => item.id == id);
    notifyListeners();

    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.delete(
      tradingPlansURI + "/$id",
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      _oldPlan = null;
    } else {
      _plans.add(_oldPlan);
      notifyListeners();
    }
  }

  Future<void> fetchPlans() async {
    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.get(
      tradingPlansURI,
      headers: bearerAuthHeader(token),
    );
    
    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      responseData.forEach((item) {
        //dont add if  exists in case of multi reloads
        final TradingPlan inComing = TradingPlan.fromJson(item);
        final elements = _plans.where((element) => element.id == inComing.id);
        if (elements.length == 0) {
          _plans.add(inComing);
        }
      });
      notifyListeners();
    } else if (response.statusCode == 401) {
      final String message = json.decode(response.body)['detail'];
      throw Exception("(${response.statusCode}): $message");
    } else {
      throw Exception("(${response.statusCode}): ${response.body}");
    }
    //
  }

  Future<void> addPlan(TradingPlan plan) async {
    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.post(
      tradingPlansURI,
      body: json.encode(
        {
          "name": plan.title,
          "description": plan.description,
        },
      ),
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      dynamic responseData = json.decode(response.body);
      TradingPlan newPlan = TradingPlan.fromJson(responseData);
      _plans.add(newPlan);
      notifyListeners();
    } else {
      throw Exception("(${response.statusCode}): ${response.body}");
    }
    // _instruments.add(_instrument);
    // notifyListeners();
  }

  Future<void> updatePlan(TradingPlan editedPlan) async {
    final index = _plans.indexWhere((item) => item.id == editedPlan.id);
    final _oldStrategy = _plans[index];
    _plans[index] = editedPlan;
    notifyListeners();

    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.put(
      tradingPlansURI + "/${editedPlan.id}",
      headers: bearerAuthHeader(token),
      body: json.encode(
        {
          "id": editedPlan.id,
          "name": editedPlan.title,
          "description": editedPlan.description,
        },
      ),
    );

    if (response.statusCode == 200) {
    } else {
      _plans[index] = _oldStrategy;
      throw Exception("(${response.statusCode}): ${response.body}");
    }
  }
}
