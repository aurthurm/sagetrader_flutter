import 'package:msagetrader/providers/tasks.dart';
import 'package:flutter/material.dart';
import 'package:msagetrader/models/task.dart';
import 'package:provider/provider.dart';

class TaskForm extends StatefulWidget {
  final bool newTask;
  final String taskID;
  TaskForm({this.newTask, this.taskID});
  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  //New Tade entry or editing
  String formTitle, saveButtonTitle;
  Task _task;
  @override
  void initState() {
    final _tasks = Provider.of<Tasks>(context, listen: false);
    if (widget.newTask) {
      formTitle = "New";
      saveButtonTitle = "Save this Task";
      _task = Task(id: null, title: '', description: '');
    } else {
      formTitle = "Edit";
      saveButtonTitle = "Update Task";
      _task = _tasks.findById(widget.taskID);
    }
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

  //Focus Nodes
  FocusNode _descriptionFocus = FocusNode();

  //Validations
  String _validateLength(v, chars, msg) {
    if (v.toString().length < chars) {
      return msg;
    }
    return null;
  }

  void _saveForm() {
    bool formIsValid = _formKey.currentState.validate();
    if (formIsValid) {
      _formKey.currentState.save();
      //new or edit form
      final _tasks = Provider.of<Tasks>(context, listen: false);

      if (_task.id == null) {
        _tasks.addTask(_task);
      } else {
        _tasks.updateTask(_task);
      }
      Navigator.of(context).pop();
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(formTitle + " Task."),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.fromLTRB(4, 2, 4, 0),
          child: Builder(
            builder: (context) => Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: "Task Name",
                            filled: true,
                            fillColor: Colors.grey.shade100),
                        initialValue: _task.title,
                        onChanged: (String value) {
                          setState(() {
                            _task.title = value;
                          });
                        },
                        validator: (value) => _validateLength(
                          value,
                          3,
                          "Task Name is too short!!",
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocus);
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: "Task Description",
                            filled: true,
                            fillColor: Colors.grey.shade100),
                        minLines: 5,
                        maxLines: 20,
                        initialValue: _task.description,
                        onChanged: (String value) {
                          setState(() {
                            _task.description = value;
                          });
                        },
                        validator: (value) => _validateLength(
                          value,
                          10,
                          "Task Description is too short!!",
                        ),
                        textInputAction: TextInputAction.newline,
                        focusNode: _descriptionFocus,
                      ),
                      SizedBox(height: 10),
                      RaisedButton(
                        color: Colors.blue,
                        child: Text(
                          saveButtonTitle.toUpperCase(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: _saveForm,
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
