/*
 * Model: 
 * Intsrument either in stocks, forex etc
*/
class Instrument {
  String id;
  String title;
  Instrument({this.id, this.title});

  String name() {
    return title.toUpperCase();
  }

  factory Instrument.fromJson(Map<String, dynamic> json) {
    return Instrument(
      id: json['id'].toString(),
      title: json['name'],
    );
  }
}
