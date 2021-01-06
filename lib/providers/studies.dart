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
  bool _loading = false;
  List<Study> _studies = <Study>[];
  String _nextUrl;

  bool hasMoreData(){
    if (_nextUrl == null) return false;
    return true;
  }

  bool get loading => _loading;

  List<Study> get studies => _studies;

  List<Study> getShared({int excludeUid}){
    // get shared
    var _st = _studies.where((item) => item.public == true);
    // eclude 
    if (excludeUid != null) {
      _st = _st.where((item) => item.owner.uid != excludeUid);
    }
    return _st.toList();
  }

  List<Study> getForUser(int ownerUid) => _studies.where((item) => item.owner.uid == ownerUid).toList();

  Future<void> clearAll() async {
    await Future.delayed(Duration(seconds: 1)).then((_) {
      _studies.clear();
    });
    notifyListeners();
  }

  void toggleLoading(bool val) => {
    _loading = val,
    notifyListeners()
  };

  Study findById(String id) {
    final index = studies.indexWhere((study) => study.uid == id);
    if(index == -1) {
      return null;
    }
    return studies[index];
  }

  ///////
  ///

  Future<void> deleteById(String id) async {
    final _oldIndex = _studies.indexWhere((inst) => inst.uid == id);
    Study _oldStudy = _studies[_oldIndex];
    _studies.removeWhere((study) => study.uid == id);
    await  Future.delayed(Duration(seconds: 1)).then((_) => notifyListeners());

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
        _studies.indexWhere((study) => study.uid == editedStudy.uid);
    final _oldStudy = _studies[index];
    _studies[index] = editedStudy;
    notifyListeners();

    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.put(
      studiesURI + "/${editedStudy.uid}",
      headers: bearerAuthHeader(token),
      body: json.encode(
        {
          "uid": editedStudy.uid,
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

  Future<void> fetchStudies({bool shared=false, bool loadMore=false}) async {
    String fetchURL;
    await MSPTAuth().getToken().then((String value) => token = value);

    if(loadMore) {
      if (_nextUrl == null) return null;
        fetchURL = _nextUrl;
    } else {
        fetchURL = studiesURI + "?shared=$shared";
        toggleLoading(true);
    }
    
    final response = await http.get(fetchURL, headers: bearerAuthHeader(token));

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> _items = responseData['items'];
      _nextUrl = responseData['next_url'];
      _items.forEach((item) {
        //dont add if instrument exists in case of multi reloads
        final Study inComing = Study.fromJson(item);
        final elements =
            _studies.where((element) => element.uid == inComing.uid);
        if (elements.length == 0) {
          _studies.add(inComing);
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
