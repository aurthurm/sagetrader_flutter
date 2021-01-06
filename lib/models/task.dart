/*
 * Model: 
 * Task: Notes or to do
 * 
*/
import 'package:msagetrader/auth/auth.dart';

class Task {
  String uid;
  String title;
  String description;
  MSPTUser owner;
  
  Task({this.uid, this.title, this.description, this.owner});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      uid: json['uid'].toString(),
      title: json['name'],
      description: json['description'],
      owner: MSPTUser.fromJson(json['owner']),
    );
  }
}
