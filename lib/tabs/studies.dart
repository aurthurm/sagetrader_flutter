import 'package:flutter/material.dart';
import 'package:msagetrader/models/study.dart';
import 'package:msagetrader/providers/studies.dart';
import 'package:msagetrader/screens/study_detail.dart';
import 'package:msagetrader/utils/utils.dart';
import 'package:provider/provider.dart';

class StudiesTab extends StatefulWidget {
  const StudiesTab({
    Key key,
  }) : super(key: key);

  @override
  _StudiesTabState createState() => _StudiesTabState();
}

class _StudiesTabState extends State<StudiesTab> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      // Provider.of<Studies>(context, listen: false).fetchStudies();
    }
    setState(() {
      _isInit = false;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final _studies = Provider.of<Studies>(context);
    List<Study> studies = _studies.studies;

    return ListView.builder(
      itemCount: studies.length,
      itemBuilder: (context, index) {
        Study study = studies[index];
        return Column(
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.repeat,
              ),
              title: Text(
                study.name,
                style: Theme.of(context).textTheme.headline2,
              ),
              onTap: () => {
                navigateToPage(context, StudyDetail(studyID: study.id)),
              },
            ),
            Divider(),
          ],
        );
      },
    );
  }
}
