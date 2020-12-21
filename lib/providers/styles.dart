import 'dart:convert';

import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/config/conf.dart';
import 'package:msagetrader/models/style.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

String token;
final String stylesURI = serverURI + "mspt/style";

class Styles with ChangeNotifier {
  List<Style> _styles = <Style>[];

  List<Style> get styles => _styles;

  Style findById(String id) {
    final index = styles.indexWhere((sty) => sty.uid == id);
    if(index == -1) {
      return null;
    }
    return styles[index];
  }

  Future<void> fetchStyles() async {
    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.get(
      stylesURI,
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      responseData.forEach((item) {
        //dont add if instrument exists in case of multi reloads
        final Style inComing = Style.fromJson(item);
        final elements = _styles.where((element) => element.uid == inComing.uid);
        if (elements.length == 0) {
          _styles.add(inComing);
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
