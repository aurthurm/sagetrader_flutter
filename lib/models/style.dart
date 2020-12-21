/*
 * Model: 
 * Trade Type
 * Types are Scalp, Day, Swing, Short Term, Position
*/
class Style {
  String uid;
  String title;
  Style({this.uid, this.title});

  String name() {
    return title.toUpperCase();
  }

  factory Style.fromJson(Map<String, dynamic> json) {
    return Style(
      uid: json['uid'].toString(),
      title: json['name'],
    );
  }
}
