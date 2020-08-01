/*
 * Model: 
 * Trade Type
 * Types are Scalp, Day, Swing, Short Term, Position
*/
class Style {
  String id;
  String title;
  Style({this.id, this.title});

  String name() {
    return title.toUpperCase();
  }

  factory Style.fromJson(Map<String, dynamic> json) {
    return Style(
      id: json['id'].toString(),
      title: json['name'],
    );
  }
}
