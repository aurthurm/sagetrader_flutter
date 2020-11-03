import 'package:flutter/material.dart';
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
      Provider.of<Attributes>(context).fetchStudyAttrs(widget.studyID);
      Provider.of<StudyItems>(context).fetchStudyItems(widget.studyID);
    }
    setState(() {
      _isInit = false;
    });
    super.didChangeDependencies();
  }

  void toggleFilter(Attribute attr, toggled) {

  }

  @override
  Widget build(BuildContext context) {
    final _studies = Provider.of<Studies>(context);
    Study study = _studies.findById(widget.studyID);
    final _studyItems = Provider.of<StudyItems>(context, listen: false);
    List<StudyItem> studyItems = _studyItems.studyItemsByStudy(study.id);
    final _studyAttrs = Provider.of<Attributes>(context, listen: false);
    List<Attribute> studyAttrs = _studyAttrs.attrsByStudy(study.id);

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
            style:  Theme.of(context).textTheme.headline2.copyWith(
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.edit_attributes_rounded),
            color: Colors.white,
              onPressed: () {
                navigateToPage(context, AtrributesPage(studyID: study.id));
              },
            ),
            IconButton(
              icon: Icon(Icons.edit),
            color: Colors.white,
              onPressed: () {
                navigateToPage(
                    context, StudyForm(newStudy: false, studyID: study.id));
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
                      "You are about to delete this Study. Note that this action is irrevesibe. Are you sure about this?",
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
                          _studies.deleteById(study.id);
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
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
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
                        Wrap(
                          direction: Axis.horizontal,
                          children: studyAttrs.length == 0 ? <Widget>[] : 
                          studyAttrs.map<Widget>(
                            (attr) => FilterTag(attribute: attr, studyitems: _studyItems)
                          ).toList(),
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
                        FlatButton(
                          onPressed: () => {
                             navigateToPage(context,
                              StudyItemForm(newStudyItem: true, studyId: study.id, studyItemId: null),
                            ),
                          },
                          child: Icon(
                            Icons.add_box,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                      child: ListView.builder(
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
                            key: Key(studyItem.id),
                            child: GestureDetector(
                                child: StudyItemCard(studyItem: studyItem),
                                onTap: () => {
                                  navigateToPage(context, StudyItemDetail(studyItemId: studyItem.id)),
                                },
                              ),
                            direction: DismissDirection.endToStart,
                            confirmDismiss:
                                (DismissDirection dismissDirection) async {
                              switch (dismissDirection) {
                                case DismissDirection.endToStart:
                                  return await _showConfirmationDialog(context,
                                          'Delete', studyItem, _studyItems) ==
                                      true;
                                case DismissDirection.startToEnd:
                                case DismissDirection.horizontal:
                                case DismissDirection.vertical:
                                case DismissDirection.up:
                                case DismissDirection.down:
                              }
                              return false;
                            },
                            onDismissed: (direction) {
                              Scaffold.of(context).hideCurrentSnackBar();
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "${studyItem.name} was deleted successfully"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              _studyItems.deleteById(studyItem.id);
                            },
                          );
                        },
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                      ),
                    ),
                    SizedBox(height: 15)
              ]
            ),
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
  }) : attribute = attribute, studyitems = studyitems, super(key: key);

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
    final index = widget.studyitems.filters.indexWhere((a) => a.id == attr.id);
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
              color: toggled ? Colors.green : Theme.of(context).primaryColor.withOpacity(0.6)
            ),
          ),
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 2),
          shape:  StadiumBorder(
            side: BorderSide(
              color: toggled ? Colors.green : Theme.of(context).primaryColor.withOpacity(0.4), 
              width: 1,
            ),
          ),
        ),
        onTap: () => {
          setState(() => {
            toggled = !toggled
          }),
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
                child:  Padding(
                  padding:  EdgeInsets.symmetric(vertical:0, horizontal:10),
                  child: !studyItem.outcome ? Icon(Icons.cancel_rounded, color: Colors.red,) : Icon(Icons.check_rounded, color: Colors.green,), // Icon(Icons.check),
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
                        style: Theme.of(context).textTheme.bodyText2.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                    Divider(
                      color: Colors.grey,
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      children: studyItem.attributes.length == 0 ? <Widget>[] : 
                      studyItem.attributes.map<Widget>(
                        (attr) => 
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Chip(
                              elevation: 1,
                              label: Text(
                                attr.name,
                                style: Theme.of(context).textTheme.subtitle2.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(context).primaryColor.withOpacity(0.8),
                                ),
                              ),
                              backgroundColor: Theme.of(context).secondaryHeaderColor,
                              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 2),
                              shape:  BeveledRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ), //StadiumBorder(side: BorderSide(color: Colors.black26, width: 1),),
                            ),
                          )
                      ).toList(),
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
          FlatButton(
            child: Text('Delete'),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          FlatButton(
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
