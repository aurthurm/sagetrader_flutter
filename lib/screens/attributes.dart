import 'package:flutter/material.dart';
import 'package:msagetrader/forms/attribute_form.dart';
import 'package:msagetrader/models/attribute.dart';
import 'package:msagetrader/models/study.dart';
import 'package:msagetrader/providers/attributes.dart';
import 'package:msagetrader/providers/studies.dart';
import 'package:msagetrader/utils/utils.dart';
import 'package:provider/provider.dart';

class AtrributesPage extends StatefulWidget {
  final String studyID;
  AtrributesPage({Key key, this.studyID}) : super(key: key);

  @override
  _AtrributesPageState createState() => _AtrributesPageState();
}

class _AtrributesPageState extends State<AtrributesPage> {
  String formTitle;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Future.delayed(Duration.zero, () {
        Provider.of<Attributes>(context, listen: false)
            .fetchStudyAttrs(widget.studyID);
      });
    }
    setState(() {
      _isInit = false;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final _studies = Provider.of<Studies>(context);
    Study study = _studies.findById(widget.studyID);
    final _attributes = Provider.of<Attributes>(context);
    List<Attribute> attributes = _attributes.attrsByStudy(study.uid);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Attrs | " + study.name,
          style: Theme.of(context).textTheme.headline2.copyWith(
                color: Colors.white,
              ),
        ),
        actions: <Widget>[],
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
                          "Attributes are the various concentration Parameters/features/variations to be considered during this study",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(fontStyle: FontStyle.italic)),
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
                        "Add Attribute",
                        style: Theme.of(context).textTheme.headline2,
                      ),
                      TextButton(
                        onPressed: () => {
                          navigateToPage(
                            context,
                            AttributeForm(
                                newAttribute: true,
                                studyId: study.uid,
                                attributeId: null),
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
                    itemCount: attributes.length,
                    itemBuilder: (context, index) {
                      final attribute = attributes[index];
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
                        key: Key(attribute.uid),
                        child: GestureDetector(
                          child: AttributeCard(studyItem: attribute),
                          onTap: () => {
                            navigateToPage(
                                context,
                                AttributeForm(
                                    newAttribute: false,
                                    studyId: study.uid,
                                    attributeId: attribute.uid)),
                          },
                        ),
                        direction: DismissDirection.endToStart,
                        confirmDismiss:
                            (DismissDirection dismissDirection) async {
                          switch (dismissDirection) {
                            case DismissDirection.endToStart:
                              return await _showConfirmationDialog(context,
                                      'Delete', attribute, _attributes) ==
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
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "${attribute.name} was deleted successfully"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          _attributes.deleteById(attribute.uid);
                        },
                      );
                    },
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}

class AttributeCard extends StatelessWidget {
  final studyItem;
  const AttributeCard({this.studyItem});
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
                  child: Icon(Icons.edit_attributes),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studyItem.name.toUpperCase(),
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    Divider(
                      color: Colors.grey,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                      child: Text(
                        getExerpt(studyItem.description, 40),
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .copyWith(fontStyle: FontStyle.italic),
                      ),
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
    BuildContext context, String action, Attribute attribute, attributes) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        title: Text('Do you want to Delete ${attribute.name} ?'),
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
