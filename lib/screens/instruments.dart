import 'package:flutter/material.dart';
import 'package:msagetrader/providers/instruments.dart';
import 'package:msagetrader/models/instrument.dart';
import 'package:provider/provider.dart';

class InstrumentsPage extends StatefulWidget {
  const InstrumentsPage({Key key}) : super(key: key);
  @override
  _InstrumentsPageState createState() => _InstrumentsPageState();
}

class _InstrumentsPageState extends State<InstrumentsPage> {
  String formTitle, _buttomText;
  Instrument _instrument;
  @override
  void initState() {
    _instrument = Instrument(uid: null, title: '');
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

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
      final _instruments = Provider.of<Instruments>(context, listen: false);
      if (_instrument.uid == null) {
        _instruments.addInstrument(_instrument);
      } else {
        _instruments.updateInstrument(_instrument);
      }
      _instrument = Instrument(uid: null, title: "");
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _instruments = Provider.of<Instruments>(context);
    List<Instrument> instruments = _instruments.instruments;
    var size = MediaQuery.of(context).size;
    var _crossAxisSpacing = 8;
    var _screenWidth = size.width;
    var _crossAxisCount = 1;
    var _width = (_screenWidth - ((_crossAxisCount - 1) * _crossAxisSpacing)) /
        _crossAxisCount;
    var cellHeight = 32;
    var _aspectRatio = _width / cellHeight;

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Trading Istruments"),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            Provider.of<Instruments>(context, listen: false).fetchInstruments(),
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "When you journal your trades. You will be limited to the instruments that you have set here.",
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.8),
                          ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => {
                      // New Instrument Creation
                      _buttomText = "Add",
                      instrumentDialogue(context),
                    },
                    child: Icon(
                      Icons.add_box,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              Divider(),
              Expanded(
                child: GridView.builder(
                  itemCount: instruments.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _crossAxisCount,
                    childAspectRatio: _aspectRatio,
                  ),
                  itemBuilder: (context, index) {
                    Instrument instrument = instruments[index];
                    return Dismissible(
                      dismissThresholds: {
                        DismissDirection.endToStart: 0.1,
                        DismissDirection.startToEnd: 0.2
                      },
                      background: Container(
                        color: Colors.red,
                        child: Row(
                          children: <Widget>[
                            Spacer(),
                            Icon(Icons.delete),
                          ],
                        ),
                      ),
                      key: Key(instrument.uid),
                      child: Card(
                        elevation: 0.5,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                              child: Text(
                                instrument.name(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3
                                    .copyWith(
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                            ),
                            Spacer(),
                            TextButton(
                              onPressed: () => {
                                setState(() {
                                  _buttomText = "Edit";
                                  _instrument = instrument;
                                }),
                                instrumentDialogue(context),
                              },
                              child: Icon(
                                Icons.edit,
                                color: Colors.black,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      confirmDismiss:
                          (DismissDirection dismissDirection) async {
                        switch (dismissDirection) {
                          case DismissDirection.endToStart:
                            return await _showConfirmationDialog(context,
                                    'Delete', instrument, _instruments) ==
                                true;
                          case DismissDirection.startToEnd:
                          case DismissDirection.horizontal:
                          case DismissDirection.vertical:
                          case DismissDirection.up:
                          case DismissDirection.down:
                          case DismissDirection.none:
                            // TODO: Handle this case.
                            break;
                        }
                        return false;
                      },
                      onDismissed: (direction) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "${instrument.name()} was deleted successfully"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        _instruments.deleteById(instrument.uid);
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future instrumentDialogue(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.all(16.0),
        content: Builder(
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
                          labelText: "Instrument Name",
                          filled: true,
                          fillColor: Colors.grey.shade100),
                      initialValue: _instrument.name(),
                      onSaved: (String value) {
                        setState(() {
                          _instrument.title = value;
                        });
                      },
                      validator: (value) => _validateLength(
                        value,
                        1,
                        "Instrument Name is too short!!",
                      ),
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
              // color: Colors.orange,
              child: Text('Cancel',
                  style: Theme.of(context).textTheme.headline5.copyWith(
                        color: Colors.red,
                      )),
              onPressed: () {
                _instrument = Instrument(uid: null, title: "");
                Navigator.pop(context);
              }),
          TextButton(
              // color: Theme.of(context).primaryColor,
              child: Text(_buttomText,
                  style: Theme.of(context).textTheme.headline5.copyWith(
                        color: Colors.blue,
                      )),
              onPressed: () {
                Navigator.pop(context);
                _saveForm();
              })
        ],
      ),
    );
  }
}

Future<bool> _showConfirmationDialog(
    BuildContext context, String action, Instrument instrument, instruments) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        title: Text('Do you want to Delete ${instrument.name()} ?'),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context, false); // showDialog() returns false
            },
          ),
        ],
      );
    },
  );
}
