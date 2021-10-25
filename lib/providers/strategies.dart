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
  bool _loading = false;
  List<Strategy> _strategies = <Strategy>[];
  String _nextUrl;


  bool hasMoreData(){
    if (_nextUrl == null) return false;
    return true;
  }
  
  bool get loading => _loading;
  List<Strategy> get strategies => _strategies;

  List<Strategy> getShared({int excludeUid}){
    // get shared
    var _str = _strategies.where((item) => item.public == true);
    // eclude 
    if (excludeUid != null) {
      _str = _str.where((item) => item.owner.uid != excludeUid);
    }
    return _str.toList();
  }

  List<Strategy> getForUser(int ownerUid) => _strategies.where((item) => item.owner.uid == ownerUid).toList();

  Future<void> clearAll() async {
    await Future.delayed(Duration(seconds: 1)).then((_) {
      _strategies.clear();
    });
    notifyListeners();
  }

  void toggleLoading(bool val) => {
    _loading = val,
    notifyListeners()
  };

  Strategy findById(String id) {
    final index = strategies.indexWhere((strat) => strat.uid == id);
    if(index == -1) {
      return null;
    }
    return strategies[index];
  }

  ///////
  ///

  Future<void> deleteById(String id) async {
    final _oldIndex = _strategies.indexWhere((inst) => inst.uid == id);
    Strategy _oldStrategy = _strategies[_oldIndex];
    _strategies.removeWhere((strategy) => strategy.uid == id);
    await  Future.delayed(Duration(seconds: 1)).then((_) => notifyListeners());

    await MSPTAuth().getToken().then((String value) => token = value);

    final response = await http.delete(
      Uri.parse(strategiesURI + "/$id"),
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      _oldStrategy = null;
    } else {
      _strategies.add(_oldStrategy);
      notifyListeners();
    }
  }

  Future addStrategy(Strategy strategy) async {
    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.post(
      Uri.parse(strategiesURI),
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
      // await Future.delayed(const Duration(seconds: 5));
      notifyListeners();
      return true;
    } else {
      throw Exception('Failed to Add Srategy: Try Again <<sc ${response.statusCode} | ${response.body}>>');
    }
  }

  Future updateStrategy(Strategy editedStrategy) async {
    final index =
        _strategies.indexWhere((strategy) => strategy.uid == editedStrategy.uid);
    final _oldStrategy = _strategies[index];
    _strategies[index] = editedStrategy;
    notifyListeners();

    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.put(
      Uri.parse(strategiesURI + "/${editedStrategy.uid}"),
      headers: bearerAuthHeader(token),
      body: json.encode(
        {
          "uid": editedStrategy.uid,
          "name": editedStrategy.name,
        },
      ),
    );

    if (response.statusCode == 200) {
    } else {
      _strategies[index] = _oldStrategy;
      throw Exception("(${response.statusCode}): ${response.body}");
    }
  }

  Future<void> fetchStrategies({bool shared=false, bool loadMore=false}) async {
    String fetchURL;
    await MSPTAuth().getToken().then((String value) => token = value);

    if(loadMore) {
      if (_nextUrl == null) return null;
        fetchURL = _nextUrl;
    } else {
        fetchURL = strategiesURI + "?shared=$shared";
        toggleLoading(true);
    }
    
    final response = await http.get(Uri.parse(fetchURL), headers: bearerAuthHeader(token));


    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> _items = responseData['items'];
      _nextUrl = responseData['next_url'];
      _items.forEach((item) {
        //dont add if instrument exists in case of multi reloads
        final Strategy inComing = Strategy.fromJson(item);
        final elements =
            _strategies.where((element) => element.uid == inComing.uid);
        if (elements.length == 0) {
          _strategies.add(inComing);
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
}
