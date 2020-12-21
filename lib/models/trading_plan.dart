/*
 * Model: 
 * Trade Type
 * Types are Scalp, Day, Swing, Short Term, Position
*/
class TradingPlan {
  String uid;
  String title;
  String description;
  TradingPlan({this.uid, this.title, this.description});

  factory TradingPlan.fromJson(Map<String, dynamic> json) {
    return TradingPlan(
      uid: json['uid'].toString(),
      title: json['name'],
      description: json['description'],
    );
  }
}
