import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:msagetrader/models/file.dart';
import 'package:msagetrader/providers/files.dart';
import 'package:msagetrader/widgets/keyvaluepair.dart';
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
      Exception("Errored: $error");
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
            Text(
              instrument.name() + " Trade Detail",
              style:  Theme.of(context).textTheme.headline2.copyWith(
                color: Colors.white,
              ),
            ),
            Text(
              humanizeDate(trade.date),
              style:  Theme.of(context).textTheme.subtitle2
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.attach_file),
            color: Colors.white,
            onPressed: () => _pickImages(context),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            color: Colors.white,
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
        child: SingleChildScrollView(
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
                      color: Colors.black87,
                    ),
                    SizedBox(height: 10),
                    KeyValuePair(
                      label: "Position:",
                      value: trade.positionAsText(),
                      color: Colors.black87,
                    ),
                    SizedBox(height: 10),
                    KeyValuePair(
                      label: "Outcome:",
                      value: trade.status
                          ? "-- running trade --"
                          : trade.outcome
                              ? "Gained + ${trade.pips} pips"
                              : "Lost - ${trade.pips} pips",
                      color: trade.status
                          ? Colors.black87
                          : trade.outcome ? Colors.green : Colors.red,
                    ),
                    SizedBox(height: 10),
                    KeyValuePair(
                      label: "Strategy:",
                      value: strategy.name,
                      color: Colors.black87,
                    ),
                    SizedBox(height: 10),
                    KeyValuePair(
                      label: "Style:",
                      value: style.name(),
                      color: Colors.black87,
                    ),
                    SizedBox(height: 10),
                    KeyValuePair(
                      label: "Risk Reward:",
                      value: "1:" + trade.riskReward.toString(),
                      color: Colors.black87,
                    ),
                    SizedBox(height: 10),
                    KeyValuePair(
                      label: "Stop Loss Price:",
                      value: trade.slPrice?.toString() ?? "-- not set --",
                      color: Colors.black87,
                    ),
                    SizedBox(height: 10),
                    KeyValuePair(
                      label: "Entry Price:",
                      value: trade.entryPrice?.toString() ?? "-- not set --",
                      color: Colors.black87,
                    ),
                    SizedBox(height: 10),
                    KeyValuePair(
                      label: "Take Profit Price:",
                      value: trade.slPrice?.toString() ?? "-- not set --",
                      color: Colors.black87,
                    ),
                    SizedBox(height: 10),
                    KeyValuePair(
                      label: "Stop Loss in pips:",
                      value: trade.sl?.toString() ?? "-- not set --",
                      color: Colors.black87,
                    ),
                    SizedBox(height: 10),
                    KeyValuePair(
                      label: "Take Profit in pips:",
                      value: trade.tp?.toString() ?? "-- not set --",
                      color: Colors.black87,
                    ),
                    SizedBox(height: 10),
                    KeyValuePair(
                      label: "Reached Take Profit",
                      value: trade.toYesNo(trade.tpReached),
                      color: Colors.black87,
                    ),
                    SizedBox(height: 10),
                    KeyValuePair(
                      label: "Exceeded Take Profit",
                      value: trade.toYesNo(trade.tpExceeded),
                      color: Colors.black87,
                    ),
                    SizedBox(height: 10),
                    KeyValuePair(
                      label: "Took a Full Stop",
                      value: trade.toYesNo(trade.fullStop),
                      color: Colors.black87,
                    ),
                    SizedBox(height: 10),
                    KeyValuePair(
                      label: "Scaled In",
                      value: trade.toYesNo(trade.scaledIn),
                      color: Colors.black87,
                    ),
                    SizedBox(height: 10),
                    KeyValuePair(
                      label: "Scaled Out",
                      value: trade.toYesNo(trade.scaledOut),
                      color: Colors.black87,
                    ),
                    SizedBox(height: 10),
                    KeyValuePair(
                      label: "Correlated Position",
                      value: trade.toYesNo(trade.correlatedPosition),
                      color: Colors.black87,
                    ),
                    Divider(color: Colors.grey.shade600),
                  ],
                ),
              ),
              loading
                  ? Center(child: CircularProgressIndicator(),)
                  : files.length == 0 // _images.length == 0
                      ? Center(
                          child: Text(
                            "We have not found any images for this trade",
                            style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.red,
                            ),
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
                                          image.location,
                                          errorBuilder: (context, _, __) => 
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0,),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.error, color: Colors.red,),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    "Not Found",
                                                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                                                      color: Colors.red,
                                                    ),
                                                  )
                                                ]
                                              ),
                                            ),
                                          ),
                                      ), // Image.memory(bytes),
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
                                                      child: Container(
                                                        child: PhotoView(
                                                          imageProvider: NetworkImage(image .location), // MemoryImage(bytes),
                                                          loadFailedChild: 
                                                          Container(
                                                            color: Theme.of(context).primaryColor,
                                                            child: Center(
                                                              child: Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0,),
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Icon(Icons.error, color: Colors.red,),
                                                                    SizedBox(height: 10),
                                                                    Text(
                                                                      "Image Not Found",
                                                                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                                                                        color: Colors.red,
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: 10),
                                                                    Divider(),
                                                                    Padding(
                                                                      padding: const EdgeInsets.all(20.0),
                                                                      child: Text(
                                                                        "Click Delete to remove reference to old image and re upload",
                                                                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                                                                          color: Colors.red,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ]
                                                                ),
                                                              ),
                                                            ),
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
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    SizedBox(height: 15),
                    Text(
                      trade.description,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
