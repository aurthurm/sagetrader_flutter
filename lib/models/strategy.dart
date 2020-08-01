/*
 * Model: 
 * Trading Strategy
*/

class Strategy {
  String id;
  String name;
  String description;
  int won = 0;
  int lost = 0;
  int total = 0;
  Strategy(
      {this.id, this.name, this.description, this.won, this.lost, this.total});
  String winRate() {
    if (total == 0) {
      return "0.00 %";
    }
    return (won * 100 / total).toStringAsFixed(2) + " %";
  }

  factory Strategy.fromJson(Map<String, dynamic> json) {
    return Strategy(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      won: json['won_trades'],
      lost: json['lost_trades'],
      total: json['total_trades'],
    );
  }
  //
}