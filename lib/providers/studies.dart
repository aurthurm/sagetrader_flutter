import 'dart:convert';

import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/config/conf.dart';
import 'package:msagetrader/models/study.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String token;
final String studiesURI = serverURI + "mspt/study";

/*
 * Provider: Studies Provider
*/
class Studies with ChangeNotifier {
  List<Study> _studies = <Study>[];

  List<Study> get studies => _studies;

  Study findById(String id) {
    final index = studies.indexWhere((study) => study.id == id);
    return studies[index];
  }

  ///////
  ///

  Future<void> deleteById(String id) async {
    final _oldIndex = _studies.indexWhere((inst) => inst.id == id);
    Study _oldStudy = _studies[_oldIndex];
    _studies.removeWhere((study) => study.id == id);
    notifyListeners();

    await MSPTAuth().getToken().then((String value) => token = value);

    final response = await http.delete(
      studiesURI + "/$id",
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      _oldStudy = null;
    } else {
      _studies.add(_oldStudy);
      notifyListeners();
    }
  }

  Future<void> addStudy(Study study) async {
    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.post(
      studiesURI,
      body: json.encode(
        {
          "name": study.name,
          "description": study.description,
        },
      ),
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      dynamic responseData = json.decode(response.body);
      Study newStudy = Study.fromJson(responseData);
      _studies.add(newStudy);
      // await Future.delayed(const Duration(seconds: 5));
      notifyListeners();
      return true;
    } else {
      throw Exception('Failed to Add Study: Try Again <<sc ${response.statusCode} | ${response.body}>>');
    }
  }

  Future<void> updateStudy(Study editedStudy) async {
    final index =
        _studies.indexWhere((study) => study.id == editedStudy.id);
    final _oldStudy = _studies[index];
    _studies[index] = editedStudy;
    notifyListeners();

    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.put(
      studiesURI + "/${editedStudy.id}",
      headers: bearerAuthHeader(token),
      body: json.encode(
        {
          "id": editedStudy.id,
          "name": editedStudy.name,
        },
      ),
    );

    if (response.statusCode == 200) {
    } else {
      _studies[index] = _oldStudy;
      throw Exception("(${response.statusCode}): ${response.body}");
    }
  }

  Future<void> fetchStudies() async {
    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.get(
      studiesURI,
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      responseData.forEach((item) {
        //dont add if instrument exists in case of multi reloads
        final Study inComing = Study.fromJson(item);
        final elements =
            _studies.where((element) => element.id == inComing.id);
        if (elements.length == 0) {
          _studies.add(inComing);
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
}
