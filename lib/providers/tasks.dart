import 'dart:convert';

import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/config/conf.dart';
import 'package:msagetrader/models/task.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

String token;
final String tasksURI = serverURI + "mspt/task";

class Tasks with ChangeNotifier {
  List<Task> _tasks = <Task>[];
  List<Task> get tasks => _tasks;

  Task findById(String id) {
    final index = _tasks.indexWhere((item) => item.id == id);
    return _tasks[index];
  }

  Future<void> deleteById(String id) async {
    final _oldIndex = _tasks.indexWhere((item) => item.id == id);
    Task _oldPlan = _tasks[_oldIndex];
    _tasks.removeWhere((item) => item.id == id);
    notifyListeners();

    await MSPTAuth().token().then((String value) => token = value);
    final response = await http.delete(
      tasksURI + "/$id",
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      _oldPlan = null;
    } else {
      _tasks.add(_oldPlan);
      notifyListeners();
    }
  }

  Future<void> fetchTasks() async {
    await MSPTAuth().token().then((String value) => token = value);
    final response = await http.get(
      tasksURI,
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      // print(responseData);
      responseData.forEach((item) {
        //dont add if  exists in case of multi reloads
        final Task inComing = Task.fromJson(item);
        final elements = _tasks.where((element) => element.id == inComing.id);
        if (elements.length == 0) {
          _tasks.add(inComing);
        }
      });
      notifyListeners();
    } else if (response.statusCode == 401) {
      final String message = json.decode(response.body)['detail'];
      print("Error: ${response.statusCode} : $message");
    } else {
      print("StatusCode: ${response.statusCode}");
      print("Error Response Body: ${response.body}");
      Exception('Failed to load _tasks');
    }
    //
  }

  Future<void> addTask(Task task) async {
    await MSPTAuth().token().then((String value) => token = value);
    final response = await http.post(
      tasksURI,
      body: json.encode(
        {
          "name": task.title,
          "description": task.description,
        },
      ),
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      dynamic responseData = json.decode(response.body);
      Task newTask = Task.fromJson(responseData);
      _tasks.add(newTask);
      notifyListeners();
    } else {
      print("StatusCode: ${response.statusCode}");
      print("Error Body: ${response.body}");
      // Exception('Failed to Add instrument');
    }
    // _instruments.add(_instrument);
    // notifyListeners();
  }

  Future<void> updateTask(Task editedTask) async {
    final index = _tasks.indexWhere((item) => item.id == editedTask.id);
    final _oldTask = _tasks[index];
    _tasks[index] = editedTask;
    notifyListeners();

    await MSPTAuth().token().then((String value) => token = value);
    final response = await http.put(
      tasksURI + "/${editedTask.id}",
      headers: bearerAuthHeader(token),
      body: json.encode(
        {
          "id": editedTask.id,
          "name": editedTask.title,
          "description": editedTask.description,
        },
      ),
    );

    if (response.statusCode == 200) {
    } else {
      _tasks[index] = _oldTask;
      print("StatusCode: ${response.statusCode}");
      print("Error Body: ${response.body}");
    }
  }
}
