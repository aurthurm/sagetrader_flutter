/*
 * Model: 
 * File:  Image, Pdf xlsx, etc
*/

enum FileType { image, pdf, word, excel }
class FileData {
  String uid;
  FileType type;
  String name;
  String parent;
  String parentUid;
  List<int> bytes;
  String location;

  FileData({
    this.uid,
    this.name,
    this.bytes,
    this.parent,
    this.parentUid,
    this.type,
    this.location,
  });

  factory FileData.fromJson(Map<String, dynamic> json) {
    return FileData(
      uid: json['uid'].toString(),
      name: json['name'],
      type: FileType.image, //find a way to detect types
      bytes: json['bytes'],
      parent: json['parent'],
      parentUid: json['parent_uid'],
      location: json['location'], // "$baseURI${json['location']}",
    );
  }
}
