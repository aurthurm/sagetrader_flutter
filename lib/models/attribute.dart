/*
 * Model: 
 * Study Attribute Type
*/

class Attribute {
  String suid;
  String uid;
  String name;
  String description;
  List<String> studyItemsIds = <String>[];
  Attribute({this.suid, this.uid, this.name, this.description, this.studyItemsIds});

  factory Attribute.fromJson(Map<String, dynamic> json) {
    List<String> _incoming = <String>[];
    for (var item in json['studyitems'] ?? []) {
      _incoming.add(item['uid'].toString());
    }
    return Attribute(
      suid: json['study_uid'].toString(),
      uid: json['uid'].toString(),
      name: json['name'],
      description: json['description'],
      studyItemsIds: _incoming,
    );
  }

  Map<String, dynamic> toJson() =>
    <String, dynamic>{
      "study_uid": suid,
      "uid": uid,
      "name": name,
      "description" : description
    };
  }
