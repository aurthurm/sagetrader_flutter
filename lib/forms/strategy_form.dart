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
  @override
  void initState() {
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

  void _saveForm() {
    bool formIsValid = _formKey.currentState.validate();
    if (formIsValid) {
      _formKey.currentState.save();
      //new or edit form
      final _strategies = Provider.of<Strategies>(context, listen: false);

      if (_strategy.id == null) {
        _strategies.addStrategy(_strategy);
      } else {
        _strategies.updateStrategy(_strategy);
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
        title: Text(formTitle + " Strategy."),
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
                            labelText: "Strategy Name",
                            filled: true,
                            fillColor: Colors.grey.shade100),
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
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: "Straegy Description",
                            filled: true,
                            fillColor: Colors.grey.shade100),
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