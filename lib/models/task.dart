/*
 * Model: 
 * Task: Notes or to do
 * 
*/
class Task {
  String id;
  String title;
  String description;
  Task({this.id, this.title, this.description});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      title: json['name'],
      description: json['description'],
    );
  }
}
