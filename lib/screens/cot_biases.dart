import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msagetrader/models/cot.dart';
import 'package:msagetrader/providers/cot.dart';
import 'package:provider/provider.dart';

class COTPairBias extends StatefulWidget {
  const COTPairBias({Key key}) : super(key: key);

  @override
  _COTPairBiasState createState() => _COTPairBiasState();
}

class _COTPairBiasState extends State<COTPairBias> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("COT Pair Bias Experimental"),
      ),
      body: _PageCOTPairBias(),
    );
  }
}

class _PageCOTPairBias extends StatefulWidget {
  @override
  __PageCOTPairBiasState createState() => __PageCOTPairBiasState();
}

class __PageCOTPairBiasState extends State<_PageCOTPairBias> {
  bool _isInit = true;
  ScrollController scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  String _cot_group = "Non Commercials";
  String _cot_contract;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<CFTC>(context, listen: false).fetchCOTPairBiases();
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

  int biasStrength(double val) {
    if (val < 10.0) return 50;
    if (val < 20.0) return 100;
    if (val < 30.0) return 200;
    if (val < 40.0) return 300;
    if (val < 50.0) return 400;
    if (val < 60.0) return 500;
    if (val < 70.0) return 600;
    if (val < 80.0) return 700;
    if (val < 90.0) return 800;
    if (val < 100.0) return 900;
    return 900;
  }

  PairBias pairBias(COTReport base, COTReport quote) {
    double baseNet, quoteNet;

    if (_cot_group == 'Commercials') {
      baseNet = base.commercialLong - base.commercialShort;
      quoteNet = quote.commercialLong - quote.commercialShort;
    }
    if (_cot_group == 'Non Commercials') {
      baseNet = base.nonCommercialLong - base.nonCommercialShort;
      quoteNet = quote.nonCommercialLong - quote.nonCommercialShort;
    }
    if (_cot_group == 'All') {
      baseNet = base.totalLong - base.totalShort;
      quoteNet = quote.totalLong - quote.totalShort;
    }

    double bnp = sqrt(baseNet * baseNet);
    double qnp = sqrt(quoteNet * quoteNet);
    double total = bnp + qnp;
    double baseWeight = bnp / total * 100;
    double quoteWeight = qnp / total * 100;

    Map<String, dynamic> data = new Map();
    data['baseNetPositions'] = baseNet;
    data['baseWeight'] = baseWeight;
    data['baseStrength'] = biasStrength(baseWeight);
    data['quoteNetPositions'] = quoteNet;
    data['quoteWeight'] = quoteWeight;
    data['quoteStrength'] = biasStrength(baseWeight);
    if (bnp > qnp) {
      data['bias'] = "Bullish";
    } else {
      data['bias'] = "Bearish";
    }
    return PairBias.fromJson(data);
  }

  List<DataRow> _buildDataRow(biases) {
    var dates = biases.keys;
    var keys = biases[dates.first].keys.toList();

    var columns = ['Date'] + keys;
    List<DataRow> dataRows = [];
    for (var date in dates.toList()) {
      Map<String, dynamic> pairsData = biases[date];
      var pairs = pairsData.keys.toList(); // == keys

      List<DataCell> cells = [];
      DateTime _date = DateTime.parse(date);

      cells.add(
        DataCell(
          Text(
            DateFormat("y-MM-dd").format(_date),
            style: TextStyle(color: Colors.black),
          ),
        ),
      );

      pairsData.forEach(
        (key, value) {
          var pair = key;
          var _base = value[pair.split('/')[0]];
          var _quote = value[pair.split('/')[1]];

          COTReport base = COTReport.fromJson(_base);
          COTReport quote = COTReport.fromJson(_quote);
          PairBias _pairBias = pairBias(base, quote);
          cells.add(
            DataCell(
              // Text(
              //   _pairBias.bias,
              //   style: TextStyle(
              //     color: _pairBias.baseWeight > _pairBias.quoteWeight
              //         ? Colors.green[_pairBias.baseStrength]
              //         : Colors.red[_pairBias.quoteStrength],
              //   ),
              // ),
              Container(
                decoration: BoxDecoration(
                  color: _pairBias.baseWeight > _pairBias.quoteWeight
                      ? Colors.green[_pairBias.baseStrength]
                      : Colors.red[_pairBias.quoteStrength],
                ),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pairBias.baseWeight > _pairBias.quoteWeight
                            ? _pairBias.baseWeight.toStringAsFixed(2) + " %"
                            : _pairBias.quoteWeight.toStringAsFixed(2) + " %",
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                        pair.split('/')[0] +
                            ": " +
                            _pairBias.baseNetPositions.toString(),
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                        pair.split('/')[1] +
                            ": " +
                            _pairBias.quoteNetPositions.toString(),
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
      dataRows.add(DataRow(cells: cells));
    }

    return dataRows;
  }

  @override
  Widget build(BuildContext context) {
    final cftc = Provider.of<CFTC>(context, listen: true);
    List<COTContract> contracts = cftc.contracts;
    List<String> groups = cftc.groups;

    List<dynamic> biases = [];
    List<String> columns = ["Date"];
    if (!cftc.loading) {
      biases = cftc.biases.entries.toList();
      columns = ['Date'] + cftc.biases[cftc.biases.keys.first].keys.toList();
    }

    return Container(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: cftc.loading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              )
            : SingleChildScrollView(
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
                                          color:
                                              Theme.of(context).primaryColor)),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  .copyWith(
                                      color: Theme.of(context).primaryColor),
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
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                    Divider(),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: biases.length > 0
                          ? DataTable(
                              horizontalMargin: 0,
                              columnSpacing: 1,
                              columns: columns.length > 0
                                  ? columns.map((colname) {
                                      return DataColumn(label: Text(colname));
                                    }).toList()
                                  : [],
                              rows: biases.length > 0
                                  ? _buildDataRow(cftc.biases)
                                  : [],
                            )
                          : Center(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
