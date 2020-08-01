import 'package:msagetrader/models/instrument.dart';
import 'package:msagetrader/models/style.dart';
import 'package:msagetrader/providers/instruments.dart';
import 'package:msagetrader/providers/strategies.dart';
import 'package:msagetrader/providers/styles.dart';
import 'package:msagetrader/providers/trades.dart';
import 'package:flutter/material.dart';
import 'package:msagetrader/models/trade.dart';
import 'package:msagetrader/models/strategy.dart';
import 'package:msagetrader/utils/utils.dart';
import 'package:provider/provider.dart';

class TradeForm extends StatefulWidget {
  final bool newTrade;
  final String tradeID;
  TradeForm({this.newTrade, this.tradeID});
  @override
  _TradeFormState createState() => _TradeFormState();
}

class _TradeFormState extends State<TradeForm> {
  //New Tade entry or editing
  String formTitle, saveButtonTitle;
  String _pickedDate = DateTime.now().toString();
  Trade _trade;
  @override
  void initState() {
    final _trades = Provider.of<Trades>(context, listen: false);
    if (widget.newTrade) {
      formTitle = "New";
      saveButtonTitle = "!! Add Trade to your journal !!";
      _trade = Trade(
        id: null,
        instrument: '',
        position: true,
        status: false,
        outcome: true,
        style: '',
        strategy: '',
        description: '',
        pips: 0,
        riskReward: 0,
        date: 'use a date picker',
      );
    } else {
      formTitle = "Edit";
      saveButtonTitle = "!! Save updated to your journal !!";
      _trade = _trades.findById(widget.tradeID);
    }
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

  //Focus Nodes
  FocusNode _descriptionFocus = FocusNode();
  FocusNode _riskRewardFocus = FocusNode();
  FocusNode _pipsFocus = FocusNode();
  FocusNode _strategyFocus = FocusNode();
  FocusNode _styleFocus = FocusNode();

  //Validations[]
  String _validateRiskReward(v, msg) {
    if (v.toString().length == 0) {
      return msg;
    }
    return null;
  }

  String _validateDescription(v, msg) {
    if (v.toString().length < 10) {
      return msg;
    }
    return null;
  }

  String _validateChoices(v, msg) {
    if (v == null) {
      return msg;
    }
    return null;
  }

  String _validatePips(v) {
    if (_trade.status) {
      return null;
    } else {
      if (v == '') {
        if (_trade.outcome) {
          return "How many pips did you gain";
        }
        return "How many pips did you lose";
      }
      return null;
    }
  }

  void _saveForm() {
    bool formIsValid = _formKey.currentState.validate();
    if (formIsValid) {
      _formKey.currentState.save();
      //new or edit form
      final _trades = Provider.of<Trades>(context, listen: false);
      _trade.date = _pickedDate;
      if (_trade.id == null) {
        /*
         * Safety checks:
         * If trade is open then pips == 0.0 and outcome is true;
        */
        if (_trade.status) {
          _trade.pips = 0;
          _trade.outcome = true;
        }
        _trades.addTrade(_trade);
      } else {
        _trades.updateTrade(_trade);
      }
      Navigator.of(context).pop();
    } else {
      return;
    }
  }

  Future _selectDate(BuildContext context) async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _pickedDate = picked.toString());
  }

  @override
  Widget build(BuildContext context) {
    final _strategies = Provider.of<Strategies>(context, listen: false);
    final _instruments = Provider.of<Instruments>(context, listen: false);
    final _styles = Provider.of<Styles>(context, listen: false);
    List<Strategy> strategies = _strategies.strategies;
    List<Instrument> instruments = _instruments.instruments;
    List<Style> styles = _styles.styles;

    return Scaffold(
      appBar: AppBar(
        title: Text(formTitle + " Trade Journal Entry."),
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
                      Container(
                        child: Row(
                          children: <Widget>[
                            RaisedButton(
                              onPressed: () => _selectDate(context),
                              child: Text("Select Trade Date ..."),
                            ),
                            Spacer(),
                            Text(humanizeDate(_pickedDate.toString())),
                          ],
                        ),
                      ),
                      Focus(
                        child: Listener(
                          onPointerUp: (_) {
                            // FocusScope.of(context).requestFocus(_pipsFocus);
                          },
                          child: DropdownButtonFormField(
                            value: _trade.instrument.isNotEmpty
                                ? _trade.instrument
                                : null,
                            hint: Text(
                              'Select an Instrument',
                            ),
                            onChanged: (value) =>
                                setState(() => _trade.instrument = value),
                            validator: (value) => _validateChoices(
                              value,
                              "Please Select an Instrument",
                            ),
                            items: instruments.map((instrument) {
                              return DropdownMenuItem(
                                value: instrument.id,
                                child: Text(instrument.name()),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SwitchListTile(
                        title: Text("Long Trade?"),
                        value: _trade.position,
                        onChanged: (val) {
                          print("Hey " + _trade.position.toString());
                          setState(() => _trade.position = val);
                        },
                      ),
                      SwitchListTile(
                        title: Text("Trade is  Open?"),
                        value: _trade.status,
                        onChanged: (val) {
                          setState(() => _trade.status = val);
                        },
                      ),
                      Visibility(
                        visible: !_trade.status,
                        child: SwitchListTile(
                          title: Text("Closed in Profit?"),
                          value: _trade.outcome,
                          onChanged: (val) {
                            setState(() => _trade.outcome = val);
                          },
                        ),
                      ),
                      Visibility(
                        visible: !_trade.status,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "How many pips",
                          ),
                          initialValue:
                              _trade.id == null ? '' : _trade.pips.toString(),
                          onChanged: (String newValue) {
                            setState(() {
                              _trade.pips = double.parse(newValue);
                            });
                          },
                          validator: (value) => _validatePips(value),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_riskRewardFocus);
                          },
                          focusNode: _pipsFocus,
                        ),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Risk Reward 1:?",
                        ),
                        initialValue: _trade.riskReward.toString() == "0.0"
                            ? ''
                            : _trade.riskReward.toString(),
                        onChanged: (String value) {
                          setState(() {
                            _trade.riskReward = double.parse(value);
                          });
                        },
                        validator: (value) => _validateRiskReward(
                          value,
                          "What the R:R ??",
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_strategyFocus);
                        },
                        focusNode: _riskRewardFocus,
                      ),
                      Focus(
                        focusNode: _strategyFocus,
                        child: Listener(
                          onPointerDown: (_) {
                            FocusScope.of(context).requestFocus(_styleFocus);
                          },
                          child: DropdownButtonFormField(
                            value: _trade.strategy.isNotEmpty
                                ? _trade.strategy
                                : null,
                            hint: Text(
                              'Select a trading strategy',
                            ),
                            onChanged: (value) =>
                                setState(() => _trade.strategy = value),
                            validator: (value) => _validateChoices(
                              value,
                              "Please Select a Strategy",
                            ),
                            items: strategies.map(
                              (strategy) {
                                return DropdownMenuItem(
                                  value: strategy.id,
                                  child: Text(strategy.name),
                                );
                              },
                            ).toList(),
                          ),
                        ),
                      ),
                      Focus(
                        focusNode: _styleFocus,
                        child: Listener(
                          onPointerDown: (_) {
                            // FocusScope.of(context).requestFocus(_descriptionFocus);
                          },
                          child: DropdownButtonFormField(
                            value:
                                _trade.style.isNotEmpty ? _trade.style : null,
                            hint: Text(
                              'Select a trading style',
                            ),
                            onChanged: (value) =>
                                setState(() => _trade.style = value),
                            validator: (value) => _validateChoices(
                              value,
                              "Please Select a trading Style",
                            ),
                            items: styles.map(
                              (style) {
                                return DropdownMenuItem(
                                  value: style.id,
                                  child: Text(style.name()),
                                );
                              },
                            ).toList(),
                          ),
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: "Trade Description",
                            filled: true,
                            fillColor: Colors.grey.shade100),
                        minLines: 5,
                        maxLines: 20,
                        initialValue: _trade.description,
                        onChanged: (String value) {
                          setState(() {
                            _trade.description = value;
                          });
                        },
                        validator: (value) => _validateDescription(
                          value,
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
