import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/config/conf.dart';
import 'package:msagetrader/models/trade.dart';
import 'package:http/http.dart' as http;

String token;
final String tradesURI = serverURI + "mspt/trade";

/*
 * Provider: Trades Provider
*/
class Trades with ChangeNotifier {
  bool _loading = false;
  List<Trade> _trades = <Trade>[];
  String _nextUrl;

  List<Trade> getShared({int excludeUid}){
    // get shared
    var _tr = _trades.where((item) => item.public == true);
    // eclude 
    if (excludeUid != null) {
      _tr = _tr.where((item) => item.owner.uid != excludeUid);
    }
    return _tr.toList();
  }

  List<Trade> getForUser(int ownerUid) => _trades.where((item) => item.owner.uid == ownerUid).toList();

  Future<void> clearAll() async {
    await Future.delayed(Duration(seconds: 1)).then((_) {
      _trades.clear();
    });
    notifyListeners();
  }

  bool hasMoreData(){
    if (_nextUrl == null) return false;
    return true;
  }

  List<Trade> get trades => _trades;
  bool get loading => _loading;

  void toggleLoading(bool val) => {
    _loading = val,
    notifyListeners()
  };

  Trade findById(String id) {
    final index = _trades.indexWhere((trade) => trade.uid == id);
    if(index == -1) {
      return null;
    }
    return trades[index];
  }
  //
  ///

  Future<void> deleteById(String id) async {
    final _oldIndex = _trades.indexWhere((inst) => inst.uid == id);
    Trade _oldSTrade = _trades[_oldIndex];
    _trades.removeWhere((trade) => trade.uid == id);
    await Future.delayed(Duration(seconds: 1)).then((_) => notifyListeners());

    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.delete(
      tradesURI + "/$id",
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      _oldSTrade = null;
    } else {
      _trades.add(_oldSTrade);
      notifyListeners();
    }
  }

  Future<void> addTrade(Trade trade) async {
    await MSPTAuth().getToken().then((String value) => token = value);
    final data = json.encode(trade.toJson());
    final response = await http.post(
      tradesURI,
      body: data,
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      dynamic responseData = json.decode(response.body);
      Trade newTrade = Trade.fromJson(responseData);
      _trades.add(newTrade);
      notifyListeners();
    } else {
      Exception("(${response.statusCode}): ${response.body}");
      // Exception('Failed to Add instrument');
    }
    // _instruments.add(_instrument);
    // notifyListeners();
  }

  Future<void> updateTrade(Trade editedTrade) async {
    final index = _trades.indexWhere((trade) => trade.uid == editedTrade.uid);
    final _oldTrade = _trades[index];
    _trades[index] = editedTrade;
    notifyListeners();
    final data = json.encode(editedTrade.toJson());

    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.put(
      tradesURI + "/${editedTrade.uid}",
      headers: bearerAuthHeader(token),
      body: data,
    );

    if (response.statusCode == 200) {
    } else {
      _trades[index] = _oldTrade;
      Exception("(${response.statusCode}): ${response.body}");
    }
  }

  Future<List<Trade>> fetchTrades({bool shared=false, bool loadMore=false}) async {
    String fetchURL;
    await MSPTAuth().getToken().then((String value) => token = value);

    if(loadMore) {
      if (hasMoreData() == false) return null;
        fetchURL = _nextUrl;
    } else {
        fetchURL = tradesURI + "?shared=$shared";
        toggleLoading(true);
    }
    
    final response = await http.get(fetchURL, headers: bearerAuthHeader(token));

    // await Future.delayed(Duration(seconds: 10));

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> _items = responseData['items'];
      _nextUrl = responseData['next_url'];
      _items.forEach((item) {
        //dont add if instrument exists in case of multi reloads
        final Trade inComing = Trade.fromJson(item);
        final elements = _trades.where((element) => element.uid == inComing.uid);
        if (elements.length == 0) {
          _trades.add(inComing);
        }
      });
      loadMore ? notifyListeners() : toggleLoading(false);
      await Future.delayed(Duration(seconds: 2)); 
      return _trades;
    } else {
      final String message = json.decode(response.body)['detail'];
      loadMore ? notifyListeners() : toggleLoading(false);
      throw Exception("(${response.statusCode}): $message");
    }
    //
  }
  //
}
