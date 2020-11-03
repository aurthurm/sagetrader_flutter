import 'package:msagetrader/providers/studies.dart';
import 'package:flutter/material.dart';
import 'package:msagetrader/models/study.dart';
import 'package:provider/provider.dart';

class StudyForm extends StatefulWidget {
  final bool newStudy;
  final String studyID;
  StudyForm({this.newStudy, this.studyID});
  @override
  _StudyFormState createState() => _StudyFormState();
}

class _StudyFormState extends State<StudyForm> {
  //New Strudy entry or editing
  String formTitle, saveButtonTitle;
  Study _study;
  bool done, loading;
  @override
  void initState() {
    done  = false;
    loading = false;
    final _studies = Provider.of<Studies>(context, listen: false);
    if (widget.newStudy) {
      formTitle = "New";
      saveButtonTitle = "Save this Study";
      _study = Study(id: null, name: '', description: '');
    } else {
      formTitle = "Edit";
      saveButtonTitle = "Update Strudy";
      _study = _studies.findById(widget.studyID);
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

  void _saveForm() async {
    setState(() {
      loading = true;
    }); 
    bool formIsValid = _formKey.currentState.validate();
    if (formIsValid) {
      _formKey.currentState.save();
      //new or edit form
      final _studies = Provider.of<Studies>(context, listen: false);

      if (_study.id == null) {
          await _studies.addStudy(_study).then((value) => {
            setState((){
              done = true;
            })
          }).catchError((error) => {
            Exception("$error")
          });     
      } else {
        await _studies.updateStudy(_study).then((value) => {
            setState((){
              done = true;
            })
          }).catchError((error) => {
            Exception("$error")
          });  
      }
      setState(() {
        loading = false;
      }); 
      if (done) {
        Navigator.of(context).pop();
      } else {
        Exception("An Error Occured, try again :)");
      }
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(formTitle + " Study."),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: loading ? 
      Center(
        child: CircularProgressIndicator(),
      ) 
      : Container(
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
                            labelText: "Study Name",
                            filled: true,
                            fillColor: Colors.grey.shade100),
                        initialValue: _study.name,
                        onChanged: (String value) {
                          setState(() {
                            _study.name = value;
                          });
                        },
                        validator: (value) => _validateLength(
                          value,
                          3,
                          "Study Name is too short!!",
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocus);
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: "Study Description",
                            filled: true,
                            fillColor: Colors.grey.shade100),
                        minLines: 5,
                        maxLines: 20,
                        initialValue: _study.description,
                        onChanged: (String value) {
                          setState(() {
                            _study.description = value;
                          });
                        },
                        validator: (value) => _validateLength(
                          value,
                          10,
                          "Trade Description is too short!!",
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
