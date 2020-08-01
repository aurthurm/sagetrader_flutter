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
  List<Trade> _trades = <Trade>[];

  List<Trade> get trades => _trades;

  Trade findById(String id) {
    final index = _trades.indexWhere((trade) => trade.id == id);
    return trades[index];
  }
  //
  ///

  Future<void> deleteById(String id) async {
    final _oldIndex = _trades.indexWhere((inst) => inst.id == id);
    Trade _oldSTrade = _trades[_oldIndex];
    _trades.removeWhere((trade) => trade.id == id);
    notifyListeners();

    await MSPTAuth().token().then((String value) => token = value);
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
    await MSPTAuth().token().then((String value) => token = value);
    final response = await http.post(
      tradesURI,
      body: json.encode(
        {
          "instrument_id": trade.instrument,
          "position": trade.position,
          "status": trade.status,
          "outcome": trade.outcome,
          "pips": trade.pips,
          "date": trade.date.toString(),
          "style_id": trade.style,
          "description": trade.description,
          "strategy_id": trade.strategy,
          "rr": trade.riskReward,
        },
      ),
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      dynamic responseData = json.decode(response.body);
      Trade newTrade = Trade.fromJson(responseData);
      _trades.add(newTrade);
      notifyListeners();
    } else {
      print("StatusCode: ${response.statusCode}");
      print("Error Body: ${response.body}");
      // Exception('Failed to Add instrument');
    }
    // _instruments.add(_instrument);
    // notifyListeners();
  }

  Future<void> updateTrade(Trade editedTrade) async {
    final index = _trades.indexWhere((trade) => trade.id == editedTrade.id);
    final _oldTrade = _trades[index];
    _trades[index] = editedTrade;
    notifyListeners();

    await MSPTAuth().token().then((String value) => token = value);
    final response = await http.put(
      tradesURI + "/${editedTrade.id}",
      headers: bearerAuthHeader(token),
      body: json.encode(
        {
          "id": editedTrade.id,
          "instrument_id": editedTrade.instrument,
          "position": editedTrade.position,
          "status": editedTrade.status,
          "outcome": editedTrade.outcome,
          "pips": editedTrade.pips,
          "date": editedTrade.date.toString(),
          "style_id": editedTrade.style,
          "description": editedTrade.description,
          "strategy_id": editedTrade.strategy,
          "rr": editedTrade.riskReward,
        },
      ),
    );

    if (response.statusCode == 200) {
    } else {
      _trades[index] = _oldTrade;
      print("StatusCode: ${response.statusCode}");
      print("Error Body: ${response.body}");
    }
  }

  Future<void> fetchTrades() async {
    await MSPTAuth().token().then((String value) => token = value);
    final response = await http.get(
      tradesURI,
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      // print(responseData);
      responseData.forEach((item) {
        //dont add if instrument exists in case of multi reloads
        final Trade inComing = Trade.fromJson(item);
        final elements = _trades.where((element) => element.id == inComing.id);
        if (elements.length == 0) {
          _trades.add(inComing);
        }
      });
      notifyListeners();
    } else if (response.statusCode == 401) {
      final String message = json.decode(response.body)['detail'];
      print("Error: ${response.statusCode} : $message");
    } else {
      print("StatusCode: ${response.statusCode}");
      print("Error Response Body: ${response.body}");
      Exception('Failed to load Trades');
    }
    //
  }
}
