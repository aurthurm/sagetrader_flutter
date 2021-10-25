import 'package:flutter/material.dart';
import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/forms/study_form.dart';
import 'package:msagetrader/forms/study_item_form.dart';
import 'package:msagetrader/models/attribute.dart';
import 'package:msagetrader/models/study.dart';
import 'package:msagetrader/providers/attributes.dart';
import 'package:msagetrader/providers/studies.dart';
import 'package:msagetrader/providers/study_items.dart';
import 'package:msagetrader/screens/attributes.dart';
import 'package:msagetrader/screens/study_item_detail.dart';
import 'package:msagetrader/utils/utils.dart';
import 'package:provider/provider.dart';

class StudyDetail extends StatefulWidget {
  final String studyID;
  StudyDetail({Key key, this.studyID}) : super(key: key);

  @override
  _StudyDetailState createState() => _StudyDetailState();
}

class _StudyDetailState extends State<StudyDetail> {
  String formTitle;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Future.delayed(Duration.zero, () {
        Provider.of<Attributes>(context, listen: false)
            .fetchStudyAttrs(widget.studyID);
        Provider.of<StudyItems>(context, listen: false)
            .fetchStudyItems(widget.studyID);
      });
    }
    setState(() {
      _isInit = false;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<MSPTAuth>(context);
    final _studies = Provider.of<Studies>(context);
    Study study = _studies.findById(widget.studyID);
    final _studyItems = Provider.of<StudyItems>(context);
    List<StudyItem> studyItems = _studyItems.studyItemsByStudy(study.uid);
    final _studyAttrs = Provider.of<Attributes>(context);
    List<Attribute> studyAttrs = _studyAttrs.attrsByStudy(study.uid);

    return WillPopScope(
      onWillPop: () async {
        _studyItems.clearFilters();
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            study.name,
            style: Theme.of(context).textTheme.headline2.copyWith(
                  color: Colors.white,
                ),
          ),
          actions: auth.user.uid == study.owner.uid
              ? <Widget>[
                  IconButton(
                    icon: Icon(Icons.edit_attributes_rounded),
                    color: Colors.white,
                    onPressed: () {
                      navigateToPage(
                          context, AtrributesPage(studyID: study.uid));
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    color: Colors.white,
                    onPressed: () {
                      navigateToPage(context,
                          StudyForm(newStudy: false, studyID: study.uid));
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
                              fontSize: 20,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            "You are about to delete this Study. Note that this action is irrevesibe. Are you sure about this?",
                          ),
                          actions: [
                            TextButton(
                              child: Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop(); // pop alert dialog
                                Navigator.of(context)
                                    .pop(); // pop from deleted trade
                                _studies.deleteById(study.uid);
                              },
                            ),
                            TextButton(
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
                ]
              : [],
        ),
        body: Container(
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Study Detail",
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        Divider(),
                        Text(
                          study.description,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Filter by Attributes",
                          style: Theme.of(context).textTheme.headline3,
                        ),
                        _studyAttrs.loading
                            ? Center(
                                child: CircularProgressIndicator(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                              )
                            : Wrap(
                                direction: Axis.horizontal,
                                children: studyAttrs.length == 0
                                    ? <Widget>[]
                                    : studyAttrs
                                        .map<Widget>((attr) => FilterTag(
                                            attribute: attr,
                                            studyitems: _studyItems))
                                        .toList(),
                              ),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Study Items:",
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        auth.user.uid == study.owner.uid
                            ? TextButton(
                                onPressed: () => {
                                  navigateToPage(
                                    context,
                                    StudyItemForm(
                                        newStudyItem: true,
                                        studyId: study.uid,
                                        studyItemId: null),
                                  ),
                                },
                                child: Icon(
                                  Icons.add_box,
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                    child: _studyItems.loading
                        ? Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                          )
                        : ListView.builder(
                            primary: false,
                            itemCount: studyItems.length,
                            itemBuilder: (context, index) {
                              final studyItem = studyItems[index];
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
                                key: Key(studyItem.uid),
                                child: GestureDetector(
                                  child: StudyItemCard(studyItem: studyItem),
                                  onTap: () => {
                                    navigateToPage(
                                        context,
                                        StudyItemDetail(
                                            studyItemId: studyItem.uid)),
                                  },
                                ),
                                direction: DismissDirection.endToStart,
                                confirmDismiss:
                                    (DismissDirection dismissDirection) async {
                                  switch (dismissDirection) {
                                    case DismissDirection.endToStart:
                                      return await _showConfirmationDialog(
                                              context,
                                              'Delete',
                                              studyItem,
                                              _studyItems) ==
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
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "${studyItem.name} was deleted successfully"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  _studyItems.deleteById(studyItem.uid);
                                },
                              );
                            },
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                          ),
                  ),
                  SizedBox(height: 15)
                ]),
          ),
        ),
      ),
    );
  }
}

class FilterTag extends StatefulWidget {
  const FilterTag({
    Key key,
    @required StudyItems studyitems,
    @required Attribute attribute,
  })  : attribute = attribute,
        studyitems = studyitems,
        super(key: key);

  final Attribute attribute;
  final StudyItems studyitems;

  @override
  _FilterTagState createState() => _FilterTagState();
}

class _FilterTagState extends State<FilterTag> {
  bool toggled = false;

  @override
  void initState() {
    toggled = isToggled(widget.attribute);
    super.initState();
  }

  bool isToggled(Attribute attr) {
    final index =
        widget.studyitems.filters.indexWhere((a) => a.uid == attr.uid);
    if (index == -1) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: GestureDetector(
        child: Chip(
          elevation: toggled ? 4 : 1,
          label: Text(
            widget.attribute.name,
            style: Theme.of(context).textTheme.subtitle2.copyWith(
                fontStyle: FontStyle.italic,
                color: toggled
                    ? Colors.green
                    : Theme.of(context).primaryColor.withOpacity(0.6)),
          ),
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 2),
          shape: StadiumBorder(
            side: BorderSide(
              color: toggled
                  ? Colors.green
                  : Theme.of(context).primaryColor.withOpacity(0.4),
              width: 1,
            ),
          ),
        ),
        onTap: () => {
          setState(() => {toggled = !toggled}),
          widget.studyitems.toggleFilters(widget.attribute, toggled),
        },
      ),
    );
  }
}

class StudyItemCard extends StatelessWidget {
  final studyItem;
  const StudyItemCard({this.studyItem});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.2,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Colors.black,
              width: 3,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          child: Row(
            children: [
              Container(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  child: !studyItem.outcome
                      ? Icon(
                          Icons.cancel_rounded,
                          color: Colors.red,
                        )
                      : Icon(
                          Icons.check_rounded,
                          color: Colors.green,
                        ), // Icon(Icons.check),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                      child: Text(
                        getExerpt(studyItem.description, 200),
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                    Divider(
                      color: Colors.grey,
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      children: studyItem.attributes.length == 0
                          ? <Widget>[]
                          : studyItem.attributes
                              .map<Widget>((attr) => Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Chip(
                                      elevation: 1,
                                      label: Text(
                                        attr.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2
                                            .copyWith(
                                              fontStyle: FontStyle.italic,
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.8),
                                            ),
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .secondaryHeaderColor,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 2),
                                      shape: BeveledRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ), //StadiumBorder(side: BorderSide(color: Colors.black26, width: 1),),
                                    ),
                                  ))
                              .toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> _showConfirmationDialog(
    BuildContext context, String action, StudyItem studyItem, studyItems) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        title: Text('Do you want to Delete ${studyItem.name} ?'),
        actions: <Widget>[
          TextButton(
            child: Text('Delete'),
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
