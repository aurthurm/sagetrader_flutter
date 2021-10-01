import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msagetrader/models/cot.dart';
import 'package:msagetrader/providers/cot.dart';
import 'package:provider/provider.dart';

class COTData extends StatefulWidget {
  const COTData({Key key}) : super(key: key);

  @override
  _COTDataState createState() => _COTDataState();
}

class _COTDataState extends State<COTData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("COT DATA"),
      ),
      body: _PageCOTData(),
    );
  }
}

class _PageCOTData extends StatefulWidget {
  @override
  __PageCOTDataState createState() => __PageCOTDataState();
}

class __PageCOTDataState extends State<_PageCOTData> {
  bool _isInit = true;
  ScrollController scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  String _cot_group;
  String _cot_contract;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<CFTC>(context, listen: false).fetchContracts();
    }
    setState(() {
      _isInit = false;
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  String _validateChoice(v, msg) {
    if (v == null) {
      return msg;
    }
    return null;
  }

  void _filterCOT() {
    bool formIsValid = _formKey.currentState.validate();
    if (formIsValid) {
      _formKey.currentState.save();
      final _cftc = Provider.of<CFTC>(context, listen: false);
      _cftc.fetchReports(_cot_group, _cot_contract);
      //new or edit form
      // final _trades = Provider.of<Trades>(context, listen: false);

    } else {
      return;
    }
  }

  DataRow _buildDataRow(COTReport report) {
    double longs, longsCh, shorts, shortsCh, openInt, openIntCh;

    DateTime _date = DateTime.parse(report.date);
    String date = DateFormat("y-MM-dd").format(_date);

    if (_cot_group == 'Commercials') {
      longs = report.commercialLong;
      shorts = report.commercialShort;
      openInt = report.openInterest;
      longsCh = report.commercialLongCh;
      shortsCh = report.commercialShortCh;
      openIntCh = report.openInterestCh;
    }
    if (_cot_group == 'Non Commercials') {
      longs = report.nonCommercialLong;
      shorts = report.nonCommercialShort;
      openInt = report.openInterest;
      longsCh = report.nonCommercialLongCh;
      shortsCh = report.nonCommercialShortCh;
      openIntCh = report.openInterestCh;
    }
    if (_cot_group == 'All') {
      longs = report.totalLong;
      shorts = report.totalShort;
      openInt = report.openInterest;
      longsCh = report.totalLongCh;
      shortsCh = report.totalShortCh;
      openIntCh = report.openInterestCh;
    }

    double total = longs + shorts;
    double longPerc = longs / total * 100;
    double shortPerc = shorts / total * 100;
    double netPositions = longs - shorts;

    return DataRow(
      cells: [
        DataCell(
          Text(
            date,
            style: TextStyle(color: Colors.black),
          ),
        ),
        DataCell(
          Text(
            longs.toString(),
            style: TextStyle(color: Colors.black),
          ),
        ),
        DataCell(
          Text(
            shorts.toString(),
            style: TextStyle(color: Colors.black),
          ),
        ),
        DataCell(
          Text(
            longsCh.toString(),
            style: TextStyle(color: longsCh > 0 ? Colors.green : Colors.red),
          ),
        ),
        DataCell(
          Text(
            shortsCh.toString(),
            style: TextStyle(color: shortsCh > 0 ? Colors.green : Colors.red),
          ),
        ),
        DataCell(
          Text(
            longPerc.toStringAsFixed(2) + " %",
            style: TextStyle(color: Colors.black),
          ),
        ),
        DataCell(
          Text(
            shortPerc.toStringAsFixed(2) + " %",
            style: TextStyle(color: Colors.black),
          ),
        ),
        DataCell(
          SizedBox.expand(
            child: Text(
              netPositions.toString(),
              style: TextStyle(
                color: netPositions > 0 ? Colors.lightGreen : Colors.redAccent,
              ),
            ),
            // Container(
            //   decoration: BoxDecoration(
            //     color: netPositions > 0 ? Colors.lightGreen : Colors.redAccent,
            //   ),
            //   child: Center(
            //     child: Text(
            //       netPositions.toString(),
            //       style: TextStyle(color: Colors.black),
            //     ),
            //   ),
            // ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cftc = Provider.of<CFTC>(context, listen: true);
    List<COTContract> contracts = cftc.contracts;
    List<String> groups = cftc.groups;
    List<COTReport> reports = cftc.reports;

    return Container(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Builder(
                builder: (context) => Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      DropdownButtonFormField(
                        value: null,
                        hint: Text('COT Group',
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(
                                    color: Theme.of(context).primaryColor)),
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            .copyWith(color: Theme.of(context).primaryColor),
                        onChanged: (value) => setState(() {
                          _cot_group = value;
                        }),
                        validator: (value) =>
                            _validateChoice(value, "Select COT Group"),
                        items: groups.map(
                          (grp) {
                            return DropdownMenuItem(
                              value: grp,
                              child: Text(grp),
                            );
                          },
                        ).toList(),
                      ),
                      DropdownButtonFormField(
                        value: null,
                        hint: Text('Futures Contract',
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(
                                    color: Theme.of(context).primaryColor)),
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            .copyWith(color: Theme.of(context).primaryColor),
                        onChanged: (value) => setState(() {
                          _cot_contract = value;
                        }),
                        validator: (value) =>
                            _validateChoice(value, "Select COT Contract"),
                        items: contracts.map(
                          (cntrct) {
                            return DropdownMenuItem(
                              value: cntrct.name,
                              child: Text(cntrct.name),
                            );
                          },
                        ).toList(),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        // elevation: 5,
                        // color: Theme.of(context).primaryColor,
                        child: Text(
                          cftc.loading ? "--- loading ---" : "Load COT Data",
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(color: Colors.white),
                        ),
                        onPressed: cftc.loading ? null : _filterCOT,
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
              Divider(),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  horizontalMargin: 0,
                  columnSpacing: 10,
                  columns: [
                    DataColumn(
                      label: Text(
                        "Date",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Long",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Short",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Long Ch",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Short Ch",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "% Long",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "% Short",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Net Pos",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                  rows: reports.length > 0
                      ? reports.map((report) {
                          return _buildDataRow(report);
                        }).toList()
                      : [],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
