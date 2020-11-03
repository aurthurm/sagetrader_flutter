import 'package:flutter/material.dart';
import 'package:msagetrader/providers/files.dart';
import 'package:msagetrader/widgets/keyvaluepair.dart';
import 'package:provider/provider.dart';
import 'package:msagetrader/forms/strategy_form.dart';
import 'package:msagetrader/models/strategy.dart';
import 'package:msagetrader/models/file.dart';
import 'package:msagetrader/providers/strategies.dart';
import 'package:msagetrader/utils/utils.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:photo_view/photo_view.dart';

class StrategyDetail extends StatefulWidget {
  final strategyId;
  StrategyDetail({this.strategyId});

  @override
  _StrategyDetailState createState() => _StrategyDetailState();
}

class _StrategyDetailState extends State<StrategyDetail> {
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
          .fetchFiles('strategy', widget.strategyId);
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
          actionBarTitle: "Select Straegy Images",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      final String error = e.toString();
      Exception("Errored: $error");
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _images = resultList;
    });

    _byteImageMaps.clear();
    _images.forEach((asset) => assetToUint8ListFile(asset));

    Future.delayed(Duration(seconds: 2)).then((_) {
      Provider.of<Files>(context, listen: false).uploadFiles(
        _byteImageMaps,
        'strategy',
        widget.strategyId,
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
      parentId: widget.strategyId,
      parent: "strategy",
    );

    setState(() {
      _byteImageMaps.add(_file);
    });
  }

  Widget build(BuildContext context) {
    final _strategies = Provider.of<Strategies>(context);
    Strategy strategy = _strategies.findById(widget.strategyId);
    final _files = Provider.of<Files>(context);
    List<FileData> files = _files.files;
    setState(() {
      loading = _files.loading;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          strategy.name + " Strategy",
          style:  Theme.of(context).textTheme.headline2.copyWith(
            color: Colors.white,
          ),
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
              navigateToPage(context,
                  StrategyForm(newStrategy: false, strategyID: strategy.id));
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
                    "You are about to delete this strategy. Note that this action is irrevesibe. Are you sure about this?",
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
                        _strategies.deleteById(strategy.id);
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
              // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  KeyValuePair(
                    label: "Total Trades:",
                    value: (strategy.won + strategy.lost).toString(),
                    color: Colors.black,
                  ),
                  SizedBox(height: 10),
                  KeyValuePair(
                    label: "Won Trades:",
                    value: strategy.won.toString(),
                    color: Colors.green,
                  ),
                  SizedBox(height: 10),
                  KeyValuePair(
                    label: "Lost Trades:",
                    value: strategy.lost.toString(),
                    color: Colors.red,
                  ),
                  SizedBox(height: 10),
                  KeyValuePair(
                    label: "Strategy Win Rate:",
                    value: strategy.winRate(),
                    color: Colors.black,
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey.shade600),
                ],
              ),
            ),
            loading
                ? Center(
                    child: Text(
                      "---- LOADING -----",
                      style: TextStyle(color: Colors.green),
                    ),
                  )
                : files.length == 0 // _images.length == 0
                    ? Center(
                        child: Text(
                          "We have not found any images for this strategy",
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
                                                              'strategy',
                                                              image.id)
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
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Divider(color: Colors.grey.shade600),
                  SizedBox(height: 10),
                  Text(
                    "Strategy Description.",
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  SizedBox(height: 15),
                  Text(
                    strategy.description,
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
