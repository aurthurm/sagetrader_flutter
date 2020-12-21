import 'dart:convert';

import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/config/conf.dart';
import 'package:msagetrader/models/attribute.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

String token;
final String attributesURI = serverURI + "mspt/attribute";

class Attributes with ChangeNotifier {
  List<Attribute> _attributes = <Attribute>[];
  List<Attribute> _selected = <Attribute>[];

  Future<void> clearAll() async {
    await Future.delayed(Duration(seconds: 1)).then((_) {
      _selected.clear();
      _attributes.clear();
    });
    notifyListeners();
  }

  List<Attribute> get attributes => _attributes;
  List<Attribute> get seleted => _selected;

  Attribute findById(String id) {
    final index = attributes.indexWhere((attr) => attr.uid == id);
    if(index == -1) {
      return null;
    }
    return attributes[index];
  }

  List<Attribute> attrsByStudy(String sid) {
    return attributes.where((x) => x.suid == sid).toList();
  }

  void toggleSelection(Attribute attr, bool toggled) {
    if(toggled) {
      _selected.add(attr);
    } else {
      _selected.removeWhere((s) => s.uid == attr.uid);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selected = [];
    notifyListeners();
  }

  Future<void> deleteById(String id) async {
    final _oldIndex = _attributes.indexWhere((inst) => inst.uid == id);
    Attribute _oldAttribute = _attributes[_oldIndex];
    _attributes.removeWhere((strategy) => strategy.uid == id);
    await  Future.delayed(Duration(seconds: 1)).then((_) => notifyListeners());

    await MSPTAuth().getToken().then((String value) => token = value);

    final response = await http.delete(
      attributesURI + "/$id",
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      _oldAttribute = null;
    } else {
      _attributes.add(_oldAttribute);
      notifyListeners();
    }
  }

  Future addAttribute(Attribute attribute) async {
    await MSPTAuth().getToken().then((String value) => token = value);
    final data = json.encode(attribute.toJson());
    final response = await http.post(
      attributesURI,
      body: data,
      headers: bearerAuthHeader(token),
    );
    if (response.statusCode == 200) {
      dynamic responseData = json.decode(response.body);
      Attribute newAttribute = Attribute.fromJson(responseData);
      _attributes.add(newAttribute);
      // await Future.delayed(const Duration(seconds: 5));
      notifyListeners();
      return true;
    } else {
      throw Exception('Failed to Add Attribute: Try Again <<sc ${response.statusCode} | ${response.body}>>');
    }
  }

  Future updateAttribute(Attribute editedAttribute) async {
    final index =
        _attributes.indexWhere((strategy) => strategy.uid == editedAttribute.uid);
    final _oldAttribute = _attributes[index];
    _attributes[index] = editedAttribute;
    notifyListeners();

    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.put(
      attributesURI + "/${editedAttribute.uid}",
      headers: bearerAuthHeader(token),
      body: json.encode(
        {
          "uid": editedAttribute.uid,
          "name": editedAttribute.name,
        },
      ),
    );

    if (response.statusCode == 200) {
    } else {
      _attributes[index] = _oldAttribute;
      throw Exception("StatusCode: ${response.statusCode}, Error Body: ${response.body}");
    }
  }

  Future<void> fetchStudyAttrs(String studyId) async {
    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.get(
      attributesURI + "/$studyId",
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      responseData.forEach((item) {
        //dont add if instrument exists in case of multi reloads
        final Attribute inComing = Attribute.fromJson(item);
        final elements = _attributes.where((element) => element.uid == inComing.uid);
        if (elements.length == 0) {
          _attributes.add(inComing);
        }
      });
      notifyListeners();
    } else {
      final String message = json.decode(response.body)['detail'];
      throw Exception("(${response.statusCode}): $message");
    }
    //
  }
}
