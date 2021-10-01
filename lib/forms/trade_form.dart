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
        uid: null,
        instrument: Instrument(),
        position: true,
        status: false,
        outcome: true,
        style: Style(),
        strategy: Strategy(),
        description: '',
        pips: null,
        riskReward: null,
        date: 'use a date picker',
        sl: null,
        tp: null,
        entryPrice: null,
        slPrice: null,
        tpPrice: null,
        tpReached: false,
        tpExceeded: false,
        fullStop: false,
        scaledIn: false,
        scaledOut: false,
        correlatedPosition: false,
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
  FocusNode _slFocus = FocusNode();
  FocusNode _tpFocus = FocusNode();
  FocusNode _slPriceFocus = FocusNode();
  FocusNode _tpPriceFocus = FocusNode();
  FocusNode _entryPriceFocus = FocusNode();

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
      if (_trade.uid == null) {
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

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      isDense: true,
      labelStyle: Theme.of(context)
          .textTheme
          .headline5
          .copyWith(color: Theme.of(context).primaryColor),
      labelText: hintText,
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        child: Row(
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () => _selectDate(context),
                              child: Text(
                                "Select Trade Date ...",
                              ),
                            ),
                            Spacer(),
                            Text(
                              humanizeDate(_pickedDate.toString()),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  .copyWith(
                                      color: Theme.of(context).primaryColor),
                            ),
                          ],
                        ),
                      ),
                      Focus(
                        child: Listener(
                          onPointerUp: (_) {
                            // FocusScope.of(context).requestFocus(_riskRewardFocus);
                          },
                          child: DropdownButtonFormField(
                            value: _trade.hasInstrument()
                                ? _trade.instrument.uid
                                : null,
                            hint: Text('Select an Instrument',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    .copyWith(
                                        color: Theme.of(context).primaryColor)),
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(
                                    color: Theme.of(context).primaryColor),
                            onChanged: (value) => setState(() {
                              _trade.instrument = _instruments.findById(value);
                            }),
                            validator: (value) => _validateChoices(
                              value,
                              "Please Select an Instrument",
                            ),
                            items: instruments.map((instrument) {
                              return DropdownMenuItem(
                                value: instrument.uid,
                                child: Text(instrument.name()),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SwitchListTile(
                        title: Text(
                          "Long Trade?",
                          style: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(color: Theme.of(context).primaryColor),
                        ),
                        value: _trade.position,
                        onChanged: (val) {
                          setState(() => _trade.position = val);
                        },
                        activeColor: Theme.of(context).primaryColor,
                        activeTrackColor:
                            Theme.of(context).primaryColor.withOpacity(0.6),
                      ),
                      SwitchListTile(
                        title: Text(
                          "Trade is Open?",
                          style: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(color: Theme.of(context).primaryColor),
                        ),
                        value: _trade.status,
                        onChanged: (val) {
                          setState(() => _trade.status = val);
                        },
                        activeColor: Theme.of(context).primaryColor,
                        activeTrackColor:
                            Theme.of(context).primaryColor.withOpacity(0.6),
                      ),
                      Visibility(
                        visible: !_trade.status,
                        child: SwitchListTile(
                          title: Text(
                            "Closed in Profit?",
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(
                                    color: Theme.of(context).primaryColor),
                          ),
                          value: _trade.outcome,
                          onChanged: (val) {
                            setState(() => _trade.outcome = val);
                          },
                          activeColor: Theme.of(context).primaryColor,
                          activeTrackColor:
                              Theme.of(context).primaryColor.withOpacity(0.6),
                        ),
                      ),
                      Visibility(
                        visible: !_trade.outcome,
                        child: SwitchListTile(
                          title: Text(
                            "Full Stop Hit?",
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(
                                    color: Theme.of(context).primaryColor),
                          ),
                          value: _trade.fullStop,
                          onChanged: (val) {
                            setState(() => _trade.fullStop = val);
                          },
                          activeColor: Theme.of(context).primaryColor,
                          activeTrackColor:
                              Theme.of(context).primaryColor.withOpacity(0.6),
                        ),
                      ),
                      SwitchListTile(
                        title: Text(
                          "Scaled In?",
                          style: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(color: Theme.of(context).primaryColor),
                        ),
                        value: _trade.scaledIn,
                        onChanged: (val) {
                          setState(() => _trade.scaledIn = val);
                        },
                        activeColor: Theme.of(context).primaryColor,
                        activeTrackColor:
                            Theme.of(context).primaryColor.withOpacity(0.6),
                      ),
                      SwitchListTile(
                        title: Text(
                          "Scaled Out?",
                          style: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(color: Theme.of(context).primaryColor),
                        ),
                        value: _trade.scaledOut,
                        onChanged: (val) {
                          setState(() => _trade.scaledOut = val);
                        },
                        activeColor: Theme.of(context).primaryColor,
                        activeTrackColor:
                            Theme.of(context).primaryColor.withOpacity(0.6),
                      ),
                      Visibility(
                        visible: !_trade.status,
                        child: SwitchListTile(
                          title: Text(
                            "TP Hit?",
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(
                                    color: Theme.of(context).primaryColor),
                          ),
                          value: _trade.tpReached,
                          onChanged: (val) {
                            setState(() => _trade.tpReached = val);
                          },
                          activeColor: Theme.of(context).primaryColor,
                          activeTrackColor:
                              Theme.of(context).primaryColor.withOpacity(0.6),
                        ),
                      ),
                      Visibility(
                        visible: !_trade.status,
                        child: SwitchListTile(
                          title: Text(
                            "TP Exceeded?",
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(
                                    color: Theme.of(context).primaryColor),
                          ),
                          value: _trade.tpExceeded,
                          onChanged: (val) {
                            setState(() => _trade.tpExceeded = val);
                          },
                          activeColor: Theme.of(context).primaryColor,
                          activeTrackColor:
                              Theme.of(context).primaryColor.withOpacity(0.6),
                        ),
                      ),
                      SwitchListTile(
                        title: Text(
                          "Correlated Position?",
                          style: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(color: Theme.of(context).primaryColor),
                        ),
                        value: _trade.correlatedPosition,
                        onChanged: (val) {
                          setState(() => _trade.correlatedPosition = val);
                        },
                        activeColor: Theme.of(context).primaryColor,
                        activeTrackColor:
                            Theme.of(context).primaryColor.withOpacity(0.6),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Risk Reward 1:?",
                          labelStyle: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(color: Theme.of(context).primaryColor),
                        ),
                        initialValue: _trade.riskReward?.toString() ?? "",
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
                          FocusScope.of(context).requestFocus(_entryPriceFocus);
                        },
                        focusNode: _riskRewardFocus,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Entry Price",
                          labelStyle: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(color: Theme.of(context).primaryColor),
                        ),
                        initialValue: _trade.entryPrice?.toString() ?? "",
                        onChanged: (String value) {
                          setState(() {
                            _trade.entryPrice = double.parse(value);
                          });
                        },
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_tpPriceFocus);
                        },
                        focusNode: _entryPriceFocus,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Take Profit Price",
                          labelStyle: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(color: Theme.of(context).primaryColor),
                        ),
                        initialValue: _trade.tpPrice?.toString() ?? "",
                        onChanged: (String value) {
                          setState(() {
                            _trade.tpPrice = double.parse(value);
                          });
                        },
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_slPriceFocus);
                        },
                        focusNode: _tpPriceFocus,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Stop Loss Price",
                          labelStyle: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(color: Theme.of(context).primaryColor),
                        ),
                        initialValue: _trade.slPrice?.toString() ?? "",
                        onChanged: (String value) {
                          setState(() {
                            _trade.slPrice = double.parse(value);
                          });
                        },
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_slFocus);
                        },
                        focusNode: _slPriceFocus,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Stop Loss in pips",
                          labelStyle: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(color: Theme.of(context).primaryColor),
                        ),
                        initialValue: _trade.sl?.toString() ?? "",
                        onChanged: (String value) {
                          setState(() {
                            _trade.sl = double.parse(value);
                          });
                        },
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_tpFocus);
                        },
                        focusNode: _slFocus,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Take Profit in pips",
                          labelStyle: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(color: Theme.of(context).primaryColor),
                        ),
                        initialValue: _trade.tp?.toString() ?? "",
                        onChanged: (String value) {
                          setState(() {
                            _trade.tp = double.parse(value);
                          });
                        },
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_strategyFocus);
                        },
                        focusNode: _tpFocus,
                      ),
                      Visibility(
                        visible: !_trade.status,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "How many pips Gained/Lost",
                            labelStyle: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(
                                    color: Theme.of(context).primaryColor),
                          ),
                          initialValue: _trade.uid == null
                              ? ''
                              : _trade.pips?.toString() ?? "",
                          onChanged: (String newValue) {
                            setState(() {
                              _trade.pips = double.parse(newValue);
                            });
                          },
                          validator: (value) => _validatePips(value),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_strategyFocus);
                          },
                          focusNode: _pipsFocus,
                        ),
                      ),
                      Focus(
                        focusNode: _strategyFocus,
                        child: Listener(
                          onPointerDown: (_) {
                            FocusScope.of(context).requestFocus(_styleFocus);
                          },
                          child: DropdownButtonFormField(
                            value: _trade.hasStrategy()
                                ? _trade.strategy.uid
                                : null,
                            hint: Text(
                              'Select a trading strategy',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  .copyWith(
                                      color: Theme.of(context).primaryColor),
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(
                                    color: Theme.of(context).primaryColor),
                            onChanged: (value) => setState(() =>
                                _trade.strategy = _strategies.findById(value)),
                            validator: (value) => _validateChoices(
                              value,
                              "Please select a strategy",
                            ),
                            items: strategies.map(
                              (strategy) {
                                return DropdownMenuItem(
                                  value: strategy.uid,
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
                            value: _trade.hasStyle() ? _trade.style.uid : null,
                            hint: Text(
                              'Select a trading style',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  .copyWith(
                                      color: Theme.of(context).primaryColor),
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(
                                    color: Theme.of(context).primaryColor),
                            onChanged: (value) => setState(
                                () => _trade.style = _styles.findById(value)),
                            validator: (value) => _validateChoices(
                              value,
                              "Please select a trading Style",
                            ),
                            items: styles.map(
                              (style) {
                                return DropdownMenuItem(
                                  value: style.uid,
                                  child: Text(style.name()),
                                );
                              },
                            ).toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: _buildInputDecoration("Trade Description"),
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(color: Theme.of(context).primaryColor),
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
                      ElevatedButton(
                        // color: Theme.of(context).primaryColor,
                        child: Text(
                          saveButtonTitle.toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
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
