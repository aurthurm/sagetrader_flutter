import 'package:msagetrader/models/attribute.dart';
import 'package:msagetrader/models/instrument.dart';
import 'package:msagetrader/models/study.dart';
import 'package:msagetrader/models/style.dart';
import 'package:msagetrader/providers/attributes.dart';
import 'package:msagetrader/providers/instruments.dart';
import 'package:msagetrader/providers/study_items.dart';
import 'package:msagetrader/providers/styles.dart';
import 'package:flutter/material.dart';
import 'package:msagetrader/utils/utils.dart';
import 'package:provider/provider.dart';

class StudyItemForm extends StatefulWidget {
  final bool newStudyItem;
  final String studyItemId;
  final String studyId;
  StudyItemForm({this.newStudyItem, this.studyId, this.studyItemId});
  @override
  _StudyItemFormState createState() => _StudyItemFormState();
}

class _StudyItemFormState extends State<StudyItemForm> {
  //New Tade entry or editing
  String formTitle, saveButtonTitle;
  String _pickedDate = DateTime.now().toString();
  StudyItem _studyItem;
  List<Attribute> studyAttributes;
  List<Attribute> studyItemAttributes = []; // selected attrs

  @override
  void initState() {
    final _studyItems = Provider.of<StudyItems>(context, listen: false);
    
    if (widget.newStudyItem) {
      formTitle = "New";
      saveButtonTitle = "!! Save Study Item !!";
      _studyItem = StudyItem(
        sid: widget.studyId,
        id: null,
        instrument: '',
        position: true,
        outcome: true,
        style: '',
        description: '',
        pips: 0,
        riskReward: 0,
        date: 'use a date picker',
      );
    } else {
      formTitle = "Edit";
      saveButtonTitle = "!! Save updated Study Item !!";
      _studyItem = _studyItems.findById(widget.studyItemId);
      studyItemAttributes = _studyItem.attributes;
    }
    super.initState();
  }

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if(!widget.newStudyItem){
        // get studyitem
        final StudyItem _studyItem = Provider.of<StudyItems>(context).findById(widget.studyItemId);
        // get studyitem attrs
        final List<Attribute> studyItemAttrs = _studyItem.attributes;
        // add study item attrs to selected
        final  _attrs = Provider.of<Attributes>(context);
        for (var attr in studyItemAttrs ?? []){
          _attrs.seleted.add(attr);
        }
      }
    }
    setState(() {
      _isInit = false;
    });
    super.didChangeDependencies();
  }


  final _formKey = GlobalKey<FormState>();

  //Focus Nodes
  FocusNode _descriptionFocus = FocusNode();
  FocusNode _riskRewardFocus = FocusNode();
  FocusNode _pipsFocus = FocusNode();
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
      if (v == '') {
        if (_studyItem.outcome) {
          return "How many pips did you gain";
        }
        return "How many pips did you lose";
      }
      return null;
  }

  void _saveForm() {
    bool formIsValid = _formKey.currentState.validate();
    if (formIsValid) {
      _formKey.currentState.save();
      //new or edit form
      final _studyItems = Provider.of<StudyItems>(context, listen: false);
      final _attrs = Provider.of<Attributes>(context, listen: false);
      _studyItem.date = _pickedDate;
      _studyItem.attributes = _attrs.seleted;
      if (_studyItem.id == null) {
        /*
         * Safety checks:
         * outcome is true ?
        */
        _studyItem.outcome = true;
        _studyItems.addStudyItem(_studyItem);
      } else {
        _studyItems.updateStudyItem(_studyItem);
      }
      _attrs.clearSelection();
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
    final _instruments = Provider.of<Instruments>(context, listen: false);
    final _styles = Provider.of<Styles>(context, listen: false);
    List<Instrument> instruments = _instruments.instruments;
    List<Style> styles = _styles.styles;
    final _attributes  = Provider.of<Attributes>(context, listen: true);
    studyAttributes = _attributes.attrsByStudy(widget.studyId);

    return WillPopScope(
      onWillPop: () async {
        _attributes.clearSelection();
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(formTitle + " Study Item"),
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
                                child: Text("Select Study Date ..."),
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
                              value: _studyItem.instrument.isNotEmpty
                                  ? _studyItem.instrument
                                  : null,
                              hint: Text(
                                'Select an Instrument',
                              ),
                              onChanged: (value) =>
                                  setState(() => _studyItem.instrument = value),
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
                          value: _studyItem.position,
                          onChanged: (val) {
                            setState(() => _studyItem.position = val);
                          },
                        ),
                        SwitchListTile(
                          title: Text("Closed in Profit?"),
                          value: _studyItem.outcome,
                          onChanged: (val) {
                            setState(() => _studyItem.outcome = val);
                          },
                        ),             
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "How many pips",
                          ),
                          initialValue:
                              _studyItem.id == null ? '' : _studyItem.pips.toString(),
                          onChanged: (String newValue) {
                            setState(() {
                              _studyItem.pips = double.parse(newValue);
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
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Risk Reward 1:?",
                          ),
                          initialValue: _studyItem.riskReward.toString() == "0.0"
                              ? ''
                              : _studyItem.riskReward.toString(),
                          onChanged: (String value) {
                            setState(() {
                              _studyItem.riskReward = double.parse(value);
                            });
                          },
                          validator: (value) => _validateRiskReward(
                            value,
                            "What the R:R ??",
                          ),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_styleFocus);
                          },
                          focusNode: _riskRewardFocus,
                        ),
                        Focus(
                          focusNode: _styleFocus,
                          child: Listener(
                            onPointerDown: (_) {
                              // FocusScope.of(context).requestFocus(_descriptionFocus);
                            },
                            child: DropdownButtonFormField(
                              value:
                                  _studyItem.style.isNotEmpty ? _studyItem.style : null,
                              hint: Text(
                                'Select a trading style',
                              ),
                              onChanged: (value) =>
                                  setState(() => _studyItem.style = value),
                              validator: (value) => _validateChoices(
                                value,
                                "Please select a trading Style",
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
                              labelText: "Study Item Description",
                              filled: true,
                              fillColor: Colors.grey.shade100),
                          minLines: 5,
                          maxLines: 20,
                          initialValue: _studyItem.description,
                          onChanged: (String value) {
                            setState(() {
                              _studyItem.description = value;
                            });
                          },
                          validator: (value) => _validateDescription(
                            value,
                            "StudyItem Description is too short!!",
                          ),
                          textInputAction: TextInputAction.newline,
                          focusNode: _descriptionFocus,
                        ),
                        Divider(),
                        Wrap(
                          direction: Axis.horizontal,
                          children: studyAttributes.map(
                            (attr) => 
                              SelectTag(attributes: _attributes, attribute: attr, studyitem: _studyItem,)
                          ).toList(),
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
      ),
    );
  }
}


class SelectTag extends StatefulWidget {
  const SelectTag({
    Key key,
    @required Attributes attributes,
    @required Attribute attribute,
    @required StudyItem studyitem,
  }) : _attributes = attributes, attr = attribute, studyitem = studyitem, super(key: key);

  final Attributes _attributes;
  final Attribute attr;
  final StudyItem studyitem;

  @override
  _SelectTagState createState() => _SelectTagState();
}

class _SelectTagState extends State<SelectTag> {
  bool toggled = false;

  @override
  void initState() {
    toggled = isToggled(widget.attr);
    super.initState();
  }

  bool isToggled(Attribute attr) {
    final index = widget._attributes.seleted.indexWhere((e) => e.id == attr.id);
    if (index == -1) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 2),
      child: GestureDetector(
        child: Chip(
          label: Text(
            widget.attr.name,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          backgroundColor: !toggled ? Colors.black12 : Colors.lightGreen,
        ),
        onTap: () => {
          setState(() => {
            toggled = !toggled
          }),
          widget._attributes.toggleSelection(widget.attr, toggled),
        },
      ),
    );
  }
}
