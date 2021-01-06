import 'dart:convert';

import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/config/conf.dart';
import 'package:msagetrader/models/attribute.dart';
import 'package:msagetrader/models/study.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String token;
final String studyItemsURI = serverURI + "mspt/studyitems";

/*
 * Provider: StudyItems Provider
*/
class StudyItems with ChangeNotifier {
  bool _loading = false;
  List<StudyItem> _studyItems = <StudyItem>[];
  String _nextUrl;
  List<Attribute> _filters = <Attribute>[];
  bool get loading => _loading;

  Future<void> clearAll() async {
    await Future.delayed(Duration(seconds: 1)).then((_) {
      _filters.clear();
      _studyItems.clear();
    });
    notifyListeners();
  }

  bool hasMoreData(){
    if (_nextUrl == null) return false;
    return true;
  }

  void toggleLoading(bool val) => {
    _loading = val,
    notifyListeners()
  };

  List<Attribute> get filters => _filters;
  
  List<StudyItem> get studyitems => _studyItems;

  List<StudyItem> studyItemsByStudy(String sid) {
    List<StudyItem> studyitemz = _studyItems.where((x) => x.suid == sid).toList();
    return applyFilters(studyitemz);
  }

  StudyItem findById(String id) {
    final index = _studyItems.indexWhere((studyitem) => studyitem.uid == id);
    if(index == -1) {
      return null;
    }
    return _studyItems[index];
  }

  void clearFilters() {
    _filters = [];
    notifyListeners();
  }

  void toggleFilters(Attribute attr, bool toggled) {
    if(toggled) {
      _filters.add(attr);
    } else {
      _filters.removeWhere((s) => s.uid == attr.uid);
    }
    notifyListeners();
  }

  List<StudyItem> applyFilters(List<StudyItem> sitems) {
    final List<StudyItem> filtered = sitems;
    if (_filters.length == 0) {
      return filtered;
    }

    // Collect all ids StudyItems with attrs that meet search criterias
    final ids = Set<String>();
    for (StudyItem _si in sitems ?? []) {
      for(Attribute _attr in _si.attributes ?? []) {
        for (Attribute _f in _filters ?? []){
          if (_attr.uid == _f.uid) {
            ids.add(_si.uid);
          }
        }
      }
    }

    filtered.retainWhere((x) => ids.remove(x.uid));
    return filtered;
  }

  Future<void> deleteById(String id) async {
    final _oldIndex = _studyItems.indexWhere((x) => x.uid == id);
    StudyItem _oldStudy = _studyItems[_oldIndex];
    _studyItems.removeWhere((x) => x.uid == id);
    await  Future.delayed(Duration(seconds: 1)).then((_) => notifyListeners());

    await MSPTAuth().getToken().then((String value) => token = value);

    final response = await http.delete(
      studyItemsURI + "/$id",
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      _oldStudy = null;
    } else {
      _studyItems.add(_oldStudy);
      notifyListeners();
    }
  }

  Future addStudyItem(StudyItem studyItem) async {
    await MSPTAuth().getToken().then((String value) => token = value);
    final data = json.encode(
      {
        "study_uid": studyItem.suid,
        "description": studyItem.description,
        "instrument_uid": studyItem.instrument,
        "position": studyItem.position,
        "outcome": studyItem.outcome,
        "pips": studyItem.pips,
        "date": studyItem.date.toString(),
        "style_uid": studyItem.style,
        "rrr": studyItem.riskReward,
        "attributes": studyItem.attributes, //_attrs,
      },
    );
    
    final response = await http.post(
      studyItemsURI,
      body: data,
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      dynamic responseData = json.decode(response.body);
      StudyItem newStudyItem = StudyItem.fromJson(responseData);
      _studyItems.add(newStudyItem);
      // await Future.delayed(const Duration(seconds: 5));
      notifyListeners();
    } else {
      throw Exception('Failed to Add StudyItem: Try Again <<sc ${response.statusCode} | ${response.body}>>');
    }
  }

  Future updateStudyItem(StudyItem editedStudyItem) async {
    final index =
        _studyItems.indexWhere((study) => study.uid == editedStudyItem.uid);
    final _oldStudy = _studyItems[index];
    _studyItems[index] = editedStudyItem;
    notifyListeners();

    await MSPTAuth().getToken().then((String value) => token = value);
    List<String> _attrs = [];
    if(editedStudyItem.attributes == []) {
      _attrs = [];
    } else if (editedStudyItem.attributes == null) {
      _attrs = [];
    } else {
      editedStudyItem.attributes.forEach((element) => _attrs.add(element.uid.toString()));
    }

    final data = json.encode(
      {
        "uid": editedStudyItem.uid,
        "instrument_uid": editedStudyItem.instrument,
        "position": editedStudyItem.position,
        "outcome": editedStudyItem.outcome,
        "pips": editedStudyItem.pips,
        "date": editedStudyItem.date.toString(),
        "style_uid": editedStudyItem.style,
        "description": editedStudyItem.description,
        "rrr": editedStudyItem.riskReward,
        "attributes": editedStudyItem.attributes, //_attrs,
      },
    );
    
    final response = await http.put(
      studyItemsURI + "/${editedStudyItem.uid}",
      headers: bearerAuthHeader(token),
      body: data,
    );

    if (response.statusCode == 200) {
    } else {
      _studyItems[index] = _oldStudy;
      throw Exception("(${response.statusCode}): ${response.body}");
    }
  }

  Future<void> fetchStudyItems(String sid) async {
    toggleLoading(true);
    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.get(
      studyItemsURI + "/$sid",
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> _items = responseData['items'];
      _nextUrl = responseData['next_url'];
      _items.forEach((item) {
        //dont add if instrument exists in case of multi reloads
        final StudyItem inComing = StudyItem.fromJson(item);
        final elements =
            _studyItems.where((element) => element.uid == inComing.uid);
        if (elements.length == 0) {
          _studyItems.add(inComing);
        }
      });
      toggleLoading(false);
    } else {
      final String message = json.decode(response.body)['detail'];
      toggleLoading(false);
      throw Exception("(${response.statusCode}): $message");
    }
    //
  }
}
