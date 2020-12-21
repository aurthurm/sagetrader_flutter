/*
 * Model: 
 * Intsrument either in stocks, forex etc
*/
class Instrument {
  String uid;
  String title;
  Instrument({this.uid, this.title});

  String name() {
    return title.toUpperCase();
  }

  factory Instrument.fromJson(Map<String, dynamic> json) {
    return Instrument(
      uid: json['uid'].toString(),
      title: json['name'],
    );
  }
}
