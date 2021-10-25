import 'dart:convert';

import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/config/conf.dart';
import 'package:msagetrader/models/trading_plan.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

String token;
final String tradingPlansURI = serverURI + "mspt/trading-plan";

class TradingPlans with ChangeNotifier {
  bool _loading = false;
  List<TradingPlan> _plans = <TradingPlan>[];
  String _nextUrl;

  bool get loading => _loading;
  List<TradingPlan> get plans => _plans;

  List<TradingPlan> getShared({int excludeUid}){
    // get shared
    var _pl = _plans.where((item) => item.public == true);
    // eclude 
    if (excludeUid != null) {
      _pl = _pl.where((item) => item.owner.uid != excludeUid);
    }
    return _pl.toList();
  }


  List<TradingPlan> getForUser(int ownerUid) => _plans.where((item) => item.owner.uid == ownerUid).toList();

  bool hasMoreData(){
    if (_nextUrl == null) return false;
    return true;
  }

  void toggleLoading(bool val) => {
    _loading = val,
    notifyListeners()
  };

  Future<void> clearAll() async {
    await Future.delayed(Duration(seconds: 1)).then((_) {
      _plans.clear();
    });
    notifyListeners();
  }

  TradingPlan findById(String id) {
    final index = _plans.indexWhere((item) => item.uid == id);
    if(index == -1) {
      return null;
    }
    return _plans[index];
  }

  Future<void> deleteById(String id) async {
    final _oldIndex = _plans.indexWhere((item) => item.uid == id);
    TradingPlan _oldPlan = _plans[_oldIndex];
    _plans.removeWhere((item) => item.uid == id);
    await  Future.delayed(Duration(seconds: 1)).then((_) => notifyListeners());

    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.delete(
      Uri.parse(tradingPlansURI + "/$id"),
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      _oldPlan = null;
    } else {
      _plans.add(_oldPlan);
      notifyListeners();
    }
  }

  Future<void> fetchPlans({bool shared=false, bool loadMore=false}) async {
    String fetchURL;
    await MSPTAuth().getToken().then((String value) => token = value);

    if(loadMore) {
      if (hasMoreData() == false) return null;
        fetchURL = _nextUrl;
    } else {
        fetchURL = tradingPlansURI + "?shared=$shared";
        toggleLoading(true);
    }
    
    final response = await http.get(Uri.parse(fetchURL), headers: bearerAuthHeader(token));
    
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> _items = responseData['items'];
      _nextUrl = responseData['next_url'];
      _items.forEach((item) {
        //dont add if  exists in case of multi reloads
        final TradingPlan inComing = TradingPlan.fromJson(item);
        final elements = _plans.where((element) => element.uid == inComing.uid);
        if (elements.length == 0) {
          _plans.add(inComing);
        }
      });
      loadMore ? notifyListeners() : toggleLoading(false);
    } else if (response.statusCode == 401) {
      final String message = json.decode(response.body)['detail'];
      loadMore ? notifyListeners() : toggleLoading(false);
      throw Exception("(${response.statusCode}): $message");
    } else {
      loadMore ? notifyListeners() : toggleLoading(false);
      throw Exception("(${response.statusCode}): ${response.body}");
    }
    //
  }

  Future<void> addPlan(TradingPlan plan) async {
    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.post(
      Uri.parse(tradingPlansURI),
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
    final index = _plans.indexWhere((item) => item.uid == editedPlan.uid);
    final _oldStrategy = _plans[index];
    _plans[index] = editedPlan;
    notifyListeners();

    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.put(
      Uri.parse(tradingPlansURI + "/${editedPlan.uid}"),
      headers: bearerAuthHeader(token),
      body: json.encode(
        {
          "uid": editedPlan.uid,
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
