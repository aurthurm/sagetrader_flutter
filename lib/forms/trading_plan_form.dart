import 'package:flutter/material.dart';
import 'package:msagetrader/models/trading_plan.dart';
import 'package:msagetrader/providers/trading_plans.dart';
import 'package:provider/provider.dart';

class TradingPlanForm extends StatefulWidget {
  final bool newPlan;
  final String planID;
  TradingPlanForm({Key key, this.newPlan, this.planID}) : super(key: key);
  @override
  _TradingPlanFormState createState() => _TradingPlanFormState();
}

class _TradingPlanFormState extends State<TradingPlanForm> {
  //New Tade entry or editing
  String formTitle, saveButtonTitle;
  TradingPlan _plan;
  @override
  void initState() {
    final _plans = Provider.of<TradingPlans>(context, listen: false);
    if (widget.newPlan) {
      formTitle = "New";
      saveButtonTitle = "Save this TradingPlan";
      _plan = TradingPlan(uid: null, title: '', description: '');
    } else {
      formTitle = "Edit";
      saveButtonTitle = "Update TradingPlan";
      _plan = _plans.findById(widget.planID);
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
      final _plans = Provider.of<TradingPlans>(context, listen: false);

      if (_plan.uid == null) {
        _plans.addPlan(_plan);
      } else {
        _plans.updatePlan(_plan);
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
        title: Text(formTitle + " TradingPlan."),
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
                        decoration: _buildInputDecoration("Trading Plan Name"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                        initialValue: _plan.title,
                        onChanged: (String value) {
                          setState(() {
                            _plan.title = value;
                          });
                        },
                        validator: (value) => _validateLength(
                          value,
                          3,
                          "TradingPlan name is too short!!",
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocus);
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration:
                            _buildInputDecoration("Trading Plan Description"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                        minLines: 5,
                        maxLines: 20,
                        initialValue: _plan.description,
                        onChanged: (String value) {
                          setState(() {
                            _plan.description = value;
                          });
                        },
                        validator: (value) => _validateLength(
                          value,
                          10,
                          "TradingPlan Description is too short!!",
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
