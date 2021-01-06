/*
 * Model: 
 * Intsrument either in stocks, forex etc
*/
import 'package:msagetrader/auth/auth.dart';

class Instrument {
  String uid;
  String title;
  MSPTUser owner;
  Instrument({this.uid, this.title, this.owner});

  String name() {
    return title.toUpperCase();
  }
  
  factory Instrument.fromJson(Map<String, dynamic> json) {
    return Instrument(
      uid: json['uid'].toString(),
      title: json['name'],
      owner: MSPTUser.fromJson(json['owner']),
    );
  }
}
