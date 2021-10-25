import 'dart:convert';

import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/config/conf.dart';
import 'package:msagetrader/models/cot.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

String token;
final String cotURI = serverURI + "cot";

class CFTC with ChangeNotifier {
  bool _loading = false;
  List<String> _groups = <String>[
    "Commercials",
    "Non Commercials",
    "All",
  ];
  String _group;
  List<COTContract> _contracts = <COTContract>[];
  List<COTReport> _reports = <COTReport>[];
  Map _biases = Map();

  List<String> get groups => _groups;
  String get group => _group;
  List<COTReport> get reports => _reports;
  List<COTContract> get contracts => _contracts;
  Map get biases => _biases;
  bool get loading => _loading;

  void toggleLoading(bool val) => {_loading = val};  // , notifyListeners()

  Future<void> fetchContracts() async {
    toggleLoading(true);
    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.get(
      Uri.parse(cotURI + "/fetch-cot-contracts"),
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      responseData.forEach((item) {
        final COTContract inComing = COTContract.fromJson(item);
        final elements =
            _contracts.where((element) => element.uid == inComing.uid);
        if (elements.length == 0) {
          _contracts.add(inComing);
        }
      });
      toggleLoading(false);
      notifyListeners();
    } else if (response.statusCode == 401) {
      final String message = json.decode(response.body)['detail'];
      throw Exception("(${response.statusCode}): $message");
    } else {
      throw Exception("(${response.statusCode}): ${response.body}");
    }
    //
  }

  Future<void> fetchReports(String group, String contract) async {
    _reports = [];
    toggleLoading(true);
    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.get(
      Uri.parse(cotURI + "/fetch-cot-reports/" + contract),
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      responseData.forEach((item) {
        final COTReport inComing = COTReport.fromJson(item);
        final elements =
            _reports.where((element) => element.uid == inComing.uid);
        if (elements.length == 0) {
          _reports.add(inComing);
        }
      });
      toggleLoading(false);
      notifyListeners();
    } else if (response.statusCode == 401) {
      final String message = json.decode(response.body)['detail'];
      throw Exception("(${response.statusCode}): $message");
    } else {
      throw Exception("(${response.statusCode}): ${response.body}");
    }
    //
  }

  Future<void> fetchCOTPairBiases() async {
    _biases = null;
    toggleLoading(true);
    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.get(
      Uri.parse(cotURI + "/fetch-cot-pair-biases"),
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      _biases = responseData;
      toggleLoading(false);
      notifyListeners();
    } else if (response.statusCode == 401) {
      final String message = json.decode(response.body)['detail'];
      throw Exception("(${response.statusCode}): $message");
    } else {
      throw Exception("(${response.statusCode}): ${response.body}");
    }
    //
  }
}
