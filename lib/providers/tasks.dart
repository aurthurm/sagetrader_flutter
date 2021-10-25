import 'dart:convert';

import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/config/conf.dart';
import 'package:msagetrader/models/task.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

String token;
final String tasksURI = serverURI + "mspt/task";

class Tasks with ChangeNotifier {
  bool _loading = false;
  List<Task> _tasks = <Task>[];
  String _nextUrl;
  List<Task> get tasks => _tasks;
  bool get loading => _loading;

  bool hasMoreData(){
    if (_nextUrl == null) return false;
    return true;
  }

  void toggleLoading(bool val) => {
    _loading = val,
    notifyListeners()
  };

  Future<void> clearAll() async {
    await Future.delayed(Duration(seconds: 1)).then((_) {
      _tasks.clear();
    });
    notifyListeners();
  }

  Task findById(String id) {
    final index = _tasks.indexWhere((item) => item.uid == id);
    if(index == -1) {
      return null;
    }
    return _tasks[index];
  }

  Future<void> deleteById(String id) async {
    final _oldIndex = _tasks.indexWhere((item) => item.uid == id);
    Task _oldPlan = _tasks[_oldIndex];
    _tasks.removeWhere((item) => item.uid == id);
    await  Future.delayed(Duration(seconds: 1)).then((_) => notifyListeners());

    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.delete(
      Uri.parse(tasksURI + "/$id"),
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      _oldPlan = null;
    } else {
      _tasks.add(_oldPlan);
      notifyListeners();
    }
  }

  Future<void> fetchTasks({ bool loadMore=false }) async {
    String fetchURL;
    await MSPTAuth().getToken().then((String value) => token = value);

    if(loadMore) {
      if (_nextUrl == null) return null;
        fetchURL = _nextUrl;
    } else {
        fetchURL = tasksURI;
    toggleLoading(true);
    }
  
    final response = await http.get(Uri.parse(fetchURL), headers: bearerAuthHeader(token));

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> _items = responseData['items'];
      _nextUrl = responseData['next_url'];
      _items.forEach((item) {
        //dont add if  exists in case of multi reloads
        final Task inComing = Task.fromJson(item);
        final elements = _tasks.where((element) => element.uid == inComing.uid);
        if (elements.length == 0) {
          _tasks.add(inComing);
        }
      });
      loadMore ? notifyListeners() : toggleLoading(false);
    } else if (response.statusCode == 401) {
      final String message = json.decode(response.body)['detail'];
      loadMore ? notifyListeners() : toggleLoading(false);
      throw Exception("(${response.statusCode}): $message");
    } else {
      loadMore ? notifyListeners() : toggleLoading(false);
      throw Exception("(${response.statusCode}): ${response.body}");
    }
    //
  }

  Future<void> addTask(Task task) async {
    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.post(
      Uri.parse(tasksURI),
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
      throw Exception("(${response.statusCode}): ${response.body}");
      // throw Exception('Failed to Add instrument');
    }
    // _instruments.add(_instrument);
    // notifyListeners();
  }

  Future<void> updateTask(Task editedTask) async {
    final index = _tasks.indexWhere((item) => item.uid == editedTask.uid);
    final _oldTask = _tasks[index];
    _tasks[index] = editedTask;
    notifyListeners();

    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.put(
      Uri.parse(tasksURI + "/${editedTask.uid}"),
      headers: bearerAuthHeader(token),
      body: json.encode(
        {
          "uid": editedTask.uid,
          "name": editedTask.title,
          "description": editedTask.description,
        },
      ),
    );

    if (response.statusCode == 200) {
    } else {
      _tasks[index] = _oldTask;
      throw Exception("(${response.statusCode}): ${response.body}");
    }
  }
}
