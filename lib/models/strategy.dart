/*
 * Model: 
 * Trading Strategy
*/

class Strategy {
  String uid;
  String name;
  String description;
  int won = 0;
  int lost = 0;
  int total = 0;
  Strategy(
      {this.uid, this.name, this.description, this.won, this.lost, this.total});
  String winRate() {
    if (total == 0) {
      return "0.00 %";
    }
    if (lost > won) {
      return "-" + (lost * 100 / total).toStringAsFixed(1) + " %";
    }
    return (won * 100 / total).toStringAsFixed(2) + " %";
  }

  factory Strategy.fromJson(Map<String, dynamic> json) {
    return Strategy(
      uid: json['uid'].toString(),
      name: json['name'],
      description: json['description'],
      won: json['won_trades'],
      lost: json['lost_trades'],
      total: json['total_trades'],
    );
  }
  //
}
