import 'package:msagetrader/providers/strategies.dart';
import 'package:flutter/material.dart';
import 'package:msagetrader/models/strategy.dart';
import 'package:provider/provider.dart';

class StrategyForm extends StatefulWidget {
  final bool newStrategy;
  final String strategyID;
  StrategyForm({this.newStrategy, this.strategyID});
  @override
  _StrategyFormState createState() => _StrategyFormState();
}

class _StrategyFormState extends State<StrategyForm> {
  //New Tade entry or editing
  String formTitle, saveButtonTitle;
  Strategy _strategy;
  bool done, loading;
  @override
  void initState() {
    done  = false;
    loading = false;
    final _strategies = Provider.of<Strategies>(context, listen: false);
    if (widget.newStrategy) {
      formTitle = "New";
      saveButtonTitle = "Save this Strategy";
      _strategy = Strategy(id: null, name: '', description: '');
    } else {
      formTitle = "Edit";
      saveButtonTitle = "Update Strategy";
      _strategy = _strategies.findById(widget.strategyID);
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
      final _strategies = Provider.of<Strategies>(context, listen: false);

      if (_strategy.id == null) {
          await _strategies.addStrategy(_strategy).then((value) => {
            setState((){
              done = true;
            })
          }).catchError((error) => {
            Exception("$error")
          });     
      } else {
        await _strategies.updateStrategy(_strategy).then((value) => {
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
        Exception("Error Occured try again :)");
      }
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
      fillColor: Theme.of(context).primaryColor.withOpacity(0.2),
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
        title: Text(formTitle + " Strategy."),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: loading ? 
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
                        decoration: _buildInputDecoration("Strategy Name"),
                        initialValue: _strategy.name,
                        onChanged: (String value) {
                          setState(() {
                            _strategy.name = value;
                          });
                        },
                        validator: (value) => _validateLength(
                          value,
                          3,
                          "Strategy Name is too short!!",
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocus);
                        },
                      ),
                      SizedBox(height: 10,),
                      TextFormField(
                        decoration:  _buildInputDecoration("Strategy Description"),
                        minLines: 5,
                        maxLines: 20,
                        initialValue: _strategy.description,
                        onChanged: (String value) {
                          setState(() {
                            _strategy.description = value;
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
