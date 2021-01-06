/*
 * Model: 
 * Trade Type
 * Types are Scalp, Day, Swing, Short Term, Position
*/
import 'package:msagetrader/auth/auth.dart';

class TradingPlan {
  String uid;
  String title;
  String description;
  MSPTUser owner;
  bool public;
  
  TradingPlan({this.uid, this.title, this.description, this.owner, this.public});

  factory TradingPlan.fromJson(Map<String, dynamic> json) {
    return TradingPlan(
      uid: json['uid'].toString(),
      title: json['name'],
      description: json['description'],
      owner: MSPTUser.fromJson(json['owner']),
      public: json['public'],
    );
  }
}
