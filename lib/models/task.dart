/*
 * Model: 
 * Task: Notes or to do
 * 
*/
class Task {
  String uid;
  String title;
  String description;
  Task({this.uid, this.title, this.description});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      uid: json['uid'].toString(),
      title: json['name'],
      description: json['description'],
    );
  }
}
