/*
 * Model: 
 * Study Attribute Type
*/

class Attribute {
  String sid;
  String id;
  String name;
  String description;
  List<String> studyItemsIds = <String>[];
  Attribute({this.sid, this.id, this.name, this.description, this.studyItemsIds});

  factory Attribute.fromJson(Map<String, dynamic> json) {
    List<String> _incoming = <String>[];
    for (var item in json['studyitems'] ?? []) {
      _incoming.add(item['id'].toString());
    }
    return Attribute(
      sid: json['study_id'].toString(),
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      studyItemsIds: _incoming,
    );
  }

  Map<String, dynamic> toJson() =>
    <String, dynamic>{
      "study_id": sid,
      "id": id,
      "name": name,
      "description" : description
    };
  }
