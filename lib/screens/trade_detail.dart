import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:msagetrader/models/file.dart';
import 'package:msagetrader/providers/files.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:msagetrader/forms/trade_form.dart';
import 'package:msagetrader/models/instrument.dart';
import 'package:msagetrader/models/strategy.dart';
import 'package:msagetrader/models/style.dart';
import 'package:msagetrader/models/trade.dart';
import 'package:msagetrader/providers/instruments.dart';
import 'package:msagetrader/providers/strategies.dart';
import 'package:msagetrader/providers/styles.dart';
import 'package:msagetrader/providers/trades.dart';
import 'package:msagetrader/utils/utils.dart';

class TradeDetail extends StatefulWidget {
  final tradeId;
  TradeDetail({this.tradeId});

  @override
  _TradeDetailState createState() => _TradeDetailState();
}

class _TradeDetailState extends State<TradeDetail> {
  List<Asset> _images = List<Asset>();
  List<FileData> _byteImageMaps = List<FileData>();
  bool _isInit = true, loading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<Files>(context, listen: false)
          .fetchFiles('trade', widget.tradeId);
    }
    setState(() {
      _isInit = false;
    });
    super.didChangeDependencies();
  }

  Future<void> _pickImages(BuildContext context) async {
    setState(() {
      loading = true;
    });
    List<Asset> resultList = List<Asset>();

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: _images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          // actionBarColor: "#abcdef",
          actionBarTitle: "Select Trade Images",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      final String error = e.toString();
      print("Errored: $error");
    }

    if (!mounted) return;
    setState(() {
      _images = resultList;
    });

    _byteImageMaps.clear();
    _images.forEach((asset) => assetToUint8ListFile(asset));

    Future.delayed(Duration(seconds: 2)).then((_) {
      Provider.of<Files>(context, listen: false).uploadFiles(
        _byteImageMaps,
        'trade',
        widget.tradeId,
      );
    });
  }

  Future<void> assetToUint8ListFile(asset) async {
    FileData _file;
    ByteData assetByteData = await asset.getByteData();
    final buffer = assetByteData.buffer;
    Uint8List img = buffer.asUint8List(
      assetByteData.offsetInBytes,
      assetByteData.lengthInBytes,
    );

    _file = FileData(
      bytes: img,
      parentId: widget.tradeId,
      parent: "trade",
    );

    setState(() {
      _byteImageMaps.add(_file);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _trades = Provider.of<Trades>(context);
    final _strategies = Provider.of<Strategies>(context, listen: false);
    final _instruments = Provider.of<Instruments>(context, listen: false);
    final _styles = Provider.of<Styles>(context, listen: false);
    Trade trade = _trades.findById(widget.tradeId);
    Instrument instrument = _instruments.findById(trade.instrument);
    Strategy strategy = _strategies.findById(trade.strategy);
    Style style = _styles.findById(trade.style);
    final _files = Provider.of<Files>(context);
    List<FileData> files = _files.files;
    setState(() {
      loading = _files.loading;
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(instrument.name() + " Trade Detail"),
            Text(
              humanizeDate(trade.date),
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.attach_file),
            color: Colors.black,
            onPressed: () => _pickImages(context),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            color: Colors.black,
            onPressed: () {
              navigateToPage(
                  context, TradeForm(newTrade: false, tradeID: trade.id));
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            color: Colors.red,
            onPressed: () => showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) {
                return AlertDialog(
                  title: Text(
                    "Warning",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  content: Text(
                    "You are about to delete this trade entry. Note that this action is irrevesibe. Are you sure about this?",
                  ),
                  actions: [
                    FlatButton(
                      child: Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // pop alert dialog
                        Navigator.of(context).pop(); // pop from deleted trade
                        _trades.deleteById(trade.id);
                      },
                    ),
                    FlatButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 19, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  KeyValuePair(
                    label: "Status:",
                    value: trade.status
                        ? "This Trade is still running"
                        : "This Trade was closed",
                    color: Colors.black,
                  ),
                  SizedBox(height: 10),
                  KeyValuePair(
                    label: "Position:",
                    value: trade.positionAsText(),
                    color: Colors.black,
                  ),
                  SizedBox(height: 10),
                  KeyValuePair(
                    label: "Outcome:",
                    value: trade.status
                        ? "-----------------------"
                        : trade.outcome
                            ? "Gained + ${trade.pips} pips"
                            : "Lost - ${trade.pips} pips",
                    color: trade.status
                        ? Colors.black
                        : trade.outcome ? Colors.green : Colors.red,
                  ),
                  SizedBox(height: 10),
                  KeyValuePair(
                    label: "Strategy:",
                    value: strategy.name,
                    color: Colors.black,
                  ),
                  SizedBox(height: 10),
                  KeyValuePair(
                    label: "Style:",
                    value: style.name(),
                    color: Colors.black,
                  ),
                  SizedBox(height: 10),
                  KeyValuePair(
                    label: "Risk Reward:",
                    value: "1:" + trade.riskReward.toString(),
                    color: Colors.black,
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey.shade600),
                ],
              ),
            ),
            loading
                ? CircularProgressIndicator()
                // Center(
                //     child: Text(
                //       "---- LOADING -----",
                //       style: TextStyle(color: Colors.green),
                //     ),
                //   )
                : files.length == 0 // _images.length == 0
                    ? Center(
                        child: Text(
                          "We have not found any images for this trade",
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    : Container(
                        height: 120.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: files.length, // _byteImageMaps.length,
                          itemBuilder: (context, index) {
                            // final bytes = _byteImageMaps[index].bytes;
                            final image = files[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: 0,
                                  top: 10,
                                  right: 5,
                                  bottom: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(
                                        2,
                                        3,
                                      ),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: GestureDetector(
                                    child: Image.network(
                                        image.location), // Image.memory(bytes),
                                    onTap: () => showGeneralDialog(
                                      context: context,
                                      barrierColor:
                                          Colors.black12.withOpacity(0.6),
                                      barrierDismissible: false,
                                      barrierLabel: "Text Dialog",
                                      transitionDuration:
                                          Duration(milliseconds: 400),
                                      pageBuilder: (_, __, ___) {
                                        return SizedBox.expand(
                                          child: Column(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 9,
                                                child: SizedBox.expand(
                                                  child: Center(
                                                    child: Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        child: PhotoView(
                                                          imageProvider:
                                                              NetworkImage(image
                                                                  .location), // MemoryImage(bytes),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: SizedBox.expand(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: <Widget>[
                                                      RaisedButton(
                                                        color: Colors.red,
                                                        child: Text(
                                                          "Delete",
                                                          style: TextStyle(
                                                            fontSize: 40,
                                                            color:
                                                                Colors.white70,
                                                          ),
                                                        ),
                                                        onPressed: () => {
                                                          Navigator.pop(
                                                              context),
                                                          _files.deleteFile(
                                                              'trade', image.id)
                                                        },
                                                      ),
                                                      RaisedButton(
                                                        color: Colors.blue,
                                                        child: Text(
                                                          "Close",
                                                          style: TextStyle(
                                                              fontSize: 40),
                                                        ),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 19, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Divider(color: Colors.grey.shade600),
                  SizedBox(height: 10),
                  Text(
                    "Trade Description.",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(trade.description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KeyValuePair extends StatelessWidget {
  const KeyValuePair({
    Key key,
    @required this.label,
    @required this.value,
    @required this.color,
  }) : super(key: key);

  final label;
  final value;
  final color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: color,
          ),
        ),
      ],
    );
  }
}
