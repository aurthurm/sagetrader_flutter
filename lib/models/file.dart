/*
 * Model: 
 * File:  Image, Pdf xlsx, etc
*/

import 'package:msagetrader/config/conf.dart';

enum FileType { image, pdf, word, excel }
class FileData {
  String id;
  FileType type;
  String name;
  String parent;
  String parentId;
  List<int> bytes;
  String location;

  FileData({
    this.id,
    this.name,
    this.bytes,
    this.parent,
    this.parentId,
    this.type,
    this.location,
  });

  factory FileData.fromJson(Map<String, dynamic> json) {
    return FileData(
      id: json['id'].toString(),
      name: json['name'],
      type: FileType.image, //find a way to detect types
      bytes: json['bytes'],
      parent: json['parent'],
      parentId: json['parent_id'],
      location: json['location'], // "$baseURI${json['location']}",
    );
  }
}
