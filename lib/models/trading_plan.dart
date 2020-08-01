/*
 * Model: 
 * Trade Type
 * Types are Scalp, Day, Swing, Short Term, Position
*/
class TradingPlan {
  String id;
  String title;
  String description;
  TradingPlan({this.id, this.title, this.description});

  factory TradingPlan.fromJson(Map<String, dynamic> json) {
    return TradingPlan(
      id: json['id'].toString(),
      title: json['name'],
      description: json['description'],
    );
  }
}
