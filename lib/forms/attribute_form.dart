import 'package:msagetrader/models/attribute.dart';
import 'package:msagetrader/providers/attributes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AttributeForm extends StatefulWidget {
  final bool newAttribute;
  final String studyId;
  final String attributeId;
  AttributeForm({this.newAttribute, this.studyId, this.attributeId});
  @override
  _AttributeFormState createState() => _AttributeFormState();
}

class _AttributeFormState extends State<AttributeForm> {
  //New Tade entry or editing
  String formTitle, saveButtonTitle;
  Attribute _attribute;
  bool done, loading;
  @override
  void initState() {
    done = false;
    loading = false;
    final _attributes = Provider.of<Attributes>(context, listen: false);
    if (widget.newAttribute) {
      formTitle = "New";
      saveButtonTitle = "Save this Attribute";
      _attribute =
          Attribute(suid: widget.studyId, uid: null, name: '', description: '');
    } else {
      formTitle = "Edit";
      saveButtonTitle = "Update Attribute";
      _attribute = _attributes.findById(widget.attributeId);
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
      final _attributes = Provider.of<Attributes>(context, listen: false);

      if (_attribute.uid == null) {
        await _attributes
            .addAttribute(_attribute)
            .then((value) => {
                  setState(() {
                    done = true;
                  })
                })
            .catchError((error) => {throw Exception("$error")});
      } else {
        await _attributes
            .updateAttribute(_attribute)
            .then((value) => {
                  setState(() {
                    done = true;
                  })
                })
            .catchError((error) => {throw Exception("$error")});
      }
      setState(() {
        loading = false;
      });
      if (done) {
        Navigator.of(context).pop();
      } else {
        throw Exception("Error Occured try again :)");
      }
    } else {
      setState(() {
        loading = false;
      });
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
        title: Text(formTitle + " Attribute."),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: loading
          ?
          // showDialog(
          //   context: context,
          //   barrierDismissible: false,
          //   builder: (BuildContext context) {
          //     return SimpleDialog(
          //       elevation: 0.0,
          //       backgroundColor: Colors.transparent,
          //       children: <Widget>[
          //         Center(
          //           child: CircularProgressIndicator(),
          //         )
          //       ],
          //     );
          //   }
          // )
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
                              decoration:
                                  _buildInputDecoration("Attribute Name"),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                              initialValue: _attribute.name,
                              onChanged: (String value) {
                                setState(() {
                                  _attribute.name = value;
                                });
                              },
                              validator: (value) => _validateLength(
                                value,
                                3,
                                "Attribute Name is too short!!",
                              ),
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_descriptionFocus);
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              decoration: _buildInputDecoration(
                                  "Attribute Description"),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                              minLines: 5,
                              maxLines: 20,
                              initialValue: _attribute.description,
                              onChanged: (String value) {
                                setState(() {
                                  _attribute.description = value;
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
                            ElevatedButton(
                              // color: Theme.of(context).primaryColor,
                              child: Text(
                                saveButtonTitle.toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4
                                    .copyWith(color: Colors.white),
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
