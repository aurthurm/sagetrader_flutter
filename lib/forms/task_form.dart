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
      _task = Task(uid: null, title: '', description: '');
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

      if (_task.uid == null) {
        _tasks.addTask(_task);
      } else {
        _tasks.updateTask(_task);
      }
      Navigator.of(context).pop();
    } else {
      return;
    }
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      isDense: true,
      labelStyle: TextStyle(
        color: Theme.of(context).primaryColor,
      ),
      labelText: hintText,
      // hintText: hintText,
      // hintStyle: TextStyle(
      //   color: Colors.white,
      // ),
      filled: true,
      fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        borderSide: BorderSide(
          width: 0,
          style: BorderStyle.none,
        ),
      ),
    );
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
                        decoration: _buildInputDecoration("Task Name"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
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
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: _buildInputDecoration("Task Detail"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
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
                          "Task Detail is too short!!",
                        ),
                        textInputAction: TextInputAction.newline,
                        focusNode: _descriptionFocus,
                      ),
                      SizedBox(height: 10),
                      RaisedButton(
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          saveButtonTitle.toUpperCase(),
                          style: Theme.of(context).textTheme.headline4.copyWith(
                            color: Colors.white
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
