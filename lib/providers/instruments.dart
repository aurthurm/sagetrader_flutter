import 'package:msagetrader/models/instrument.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:msagetrader/config/conf.dart';
import 'package:msagetrader/auth/auth.dart';

final String instrumentsURI = serverURI + "mspt/instrument";

String token;

/*
 * Provider: Strateies Provider
*/
class Instruments with ChangeNotifier {
  List<Instrument> _instruments = <Instrument>[];

  List<Instrument> get instruments => _instruments;

  Future<void> clearAll() async {
    await Future.delayed(Duration(seconds: 1)).then((_) {
      _instruments.clear();
    });
    notifyListeners();
  }

  Instrument findById(String id) {
    final index = instruments.indexWhere((inst) => inst.uid == id);
    if(index == -1) {
      return null;
    }
    return instruments[index];
  }

  Future<void> deleteById(String id) async {
    final _oldIndex = _instruments.indexWhere((inst) => inst.uid == id);
    Instrument _oldInstrument = _instruments[_oldIndex];
    _instruments.removeWhere((instrument) => instrument.uid == id);
    await  Future.delayed(Duration(seconds: 1)).then((_) => notifyListeners());

    await MSPTAuth().getToken().then((String value) => token = value);

    final response = await http.delete(
      Uri.parse(instrumentsURI + "/$id"),
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      _oldInstrument = null;
    } else {
      _instruments.add(_oldInstrument);
      notifyListeners();
    }
  }

  Future<void> addInstrument(Instrument instrument) async {
    // final newId = (_instruments.length + 1).toString();
    // _instrument.uid = newId;

    await MSPTAuth().getToken().then((String value) => token = value);

    final response = await http.post(
      Uri.parse(instrumentsURI),
      body: json.encode(
        {
          "name": instrument.name(),
        },
      ),
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      dynamic responseData = json.decode(response.body);
      Instrument newInstrument = Instrument.fromJson(responseData);
      _instruments.add(newInstrument);
      notifyListeners();
    } else {
      throw Exception("(${response.statusCode}): ${response.body}");
    }

    // _instruments.add(_instrument);
    // notifyListeners();
  }

  Future<void> updateInstrument(Instrument editedInstrument) async {
    final index = _instruments
        .indexWhere((instrument) => instrument.uid == editedInstrument.uid);
    final _oldInstrument = _instruments[index];
    _instruments[index] = editedInstrument;
    notifyListeners();

    await MSPTAuth().getToken().then((String value) => token = value);

    final response = await http.put(
      Uri.parse(instrumentsURI + "/${editedInstrument.uid}"),
      headers: bearerAuthHeader(token),
      body: json.encode(
        {
          "uid": editedInstrument.uid,
          "name": editedInstrument.name(),
        },
      ),
    );

    if (response.statusCode == 200) {
    } else {
      _instruments[index] = _oldInstrument;
      throw Exception("(${response.statusCode}): ${response.body}");
    }
  }

  Future<void> fetchInstruments() async {
    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.get(
      Uri.parse(instrumentsURI),
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      responseData.forEach((item) {
        //dont add if instrument exists in case of multi reloads
        final Instrument inComing = Instrument.fromJson(item);
        final elements =
            _instruments.where((element) => element.uid == inComing.uid);
        if (elements.length == 0) {
          _instruments.add(inComing);
        }
      });
      notifyListeners();
    } else if (response.statusCode == 401) {
      final String message = json.decode(response.body)['detail'];
      throw Exception("(${response.statusCode}): $message");
    } else {
      throw Exception("(${response.statusCode}): ${response.body}");
    }
  }
}
