import 'package:flutter/material.dart';
import 'package:msagetrader/forms/study_item_form.dart';
import 'package:msagetrader/models/instrument.dart';
import 'package:msagetrader/models/study.dart';
import 'package:msagetrader/models/style.dart';
import 'package:msagetrader/providers/files.dart';
import 'package:msagetrader/providers/instruments.dart';
import 'package:msagetrader/providers/studies.dart';
import 'package:msagetrader/providers/study_items.dart';
import 'package:msagetrader/providers/styles.dart';
import 'package:msagetrader/utils/utils.dart';
import 'package:msagetrader/widgets/keyvaluepair.dart';
import 'package:provider/provider.dart';
import 'package:msagetrader/models/file.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:photo_view/photo_view.dart';

class StudyItemDetail extends StatefulWidget {
  final studyItemId;
  StudyItemDetail({this.studyItemId});

  @override
  _StudyItemDetailState createState() => _StudyItemDetailState();
}

class _StudyItemDetailState extends State<StudyItemDetail> {
  List<Asset> _images = List<Asset>();
  List<FileData> _byteImageMaps = List<FileData>();
  bool _isInit = true, loading = true;
  List<dynamic> tags = List<dynamic>();
  String caption = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<Files>(context, listen: false)
          .fetchFiles('studyitem', widget.studyItemId);
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
          actionBarTitle: "Select StudyItem Images",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      final String error = e.toString();
      throw Exception("Errored: $error");
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
        'studyitem',
        widget.studyItemId,
        tags,
        caption
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
      parentUid: widget.studyItemId,
      parent: "studyitem",
    );

    setState(() {
      _byteImageMaps.add(_file);
    });
  }

  _buildTagsAlt(StudyItem st, Style sty, Instrument inst) {
    var _tags = [];
    _tags.add(inst.title.toUpperCase());
    _tags.add(st.positionAsText().toUpperCase());
    _tags.add(sty.title.toUpperCase());
    st.attributes.forEach((attr) =>  _tags.add(attr.name.toUpperCase()));
    setState(() {
      tags = _tags;
      caption = "${st.positionAsText().toUpperCase()} ${inst.title.toUpperCase()} ${sty.title.toUpperCase()} Study";
    });
    // print("StudyItemTags: $tags");
  }

  Widget build(BuildContext context) {
    final _studyItems = Provider.of<StudyItems>(context);
    StudyItem studyItem = _studyItems.findById(widget.studyItemId);
    final _studies = Provider.of<Studies>(context);
    Study study = _studies.findById(studyItem.suid);
    final _styles = Provider.of<Styles>(context, listen: false);
    Style style = _styles.findById(studyItem.style);
    final _instruments = Provider.of<Instruments>(context, listen: false);
    Instrument instrument = _instruments.findById(studyItem.instrument);
    final _files = Provider.of<Files>(context);
    List<FileData> files = _files.files;
    setState(() {
      loading = _files.loading;
    });
    _buildTagsAlt(studyItem, style, instrument);


    return Scaffold(
      appBar: AppBar(
        title: Text(studyItem.name),
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
                  StudyItemForm(newStudyItem: false, studyId: study.uid, studyItemId: studyItem.uid,));
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
                    "You are about to delete this studyItem. Note that this action is irrevesibe. Are you sure about this?",
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
                        _studyItems.deleteById(studyItem.uid);
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
                    label: "Study:",
                    value: study.name.toUpperCase(),
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  KeyValuePair(
                    label: "Instrument:",
                    value: instrument.name(),
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  KeyValuePair(
                    label: "Position:",
                    value: studyItem.positionAsText(),
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  KeyValuePair(
                    label: "Outcome:",
                    value: (studyItem.outcome
                            ? "+"
                            : "-") 
                            + "${studyItem.pips} pips",
                    color: studyItem.outcome ? Colors.green : Colors.red,
                  ),
                  SizedBox(height: 10),
                  KeyValuePair(
                    label: "Style:",
                    value: style.name(),
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  KeyValuePair(
                    label: "Risk Reward:",
                    value: "1:" + studyItem.riskReward.toString(),
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey.shade600),
                  Wrap(
                    direction: Axis.horizontal,
                    children: studyItem.attributes.length == 0 ? 
                    [
                      Center(
                        child: Text("... No Attributes ...")
                      ),
                    ] : 
                    studyItem.attributes.map(
                      (attr) => 
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Chip(
                            elevation: 3,
                            label: Text(
                              attr.name,
                              style: Theme.of(context).textTheme.subtitle2.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                              )
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                        )
                    ).toList(),
                  ),
                  Divider(color: Colors.grey.shade600),
                ],
              ),
            ),
            loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : files.length == 0 // _images.length == 0
            ? Center(
                child: Text(
                  "We have not found any images for this study item",
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
                              barrierColor: Colors.black12.withOpacity(0.6),
                              barrierDismissible: false,
                              barrierLabel: "Text Dialog",
                              transitionDuration: Duration(milliseconds: 400),
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
                                                      'studyitem',
                                                      image.uid)
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
                    "Study Item Description.",
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey.shade600),
                  Text(
                    studyItem.description,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
