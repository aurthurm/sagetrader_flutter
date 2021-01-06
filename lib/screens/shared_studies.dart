import 'package:flutter/material.dart';
import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/models/study.dart';
import 'package:msagetrader/providers/studies.dart';
import 'package:msagetrader/screens/study_detail.dart';
import 'package:msagetrader/utils/snacks.dart';
import 'package:msagetrader/utils/utils.dart';
import 'package:provider/provider.dart';

class SharedStudies extends StatefulWidget {
  const SharedStudies({Key key}) : super(key: key);

  @override
  _SharedStudiesState createState() => _SharedStudiesState();
}

class _SharedStudiesState extends State<SharedStudies> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Shared Studies"),
      ),
      body: _PageSharedStudies(),
    );
  }
}


class _PageSharedStudies extends StatefulWidget {
  @override
  __PageSharedStudiesState createState() => __PageSharedStudiesState();
}

class __PageSharedStudiesState extends State<_PageSharedStudies> {
  bool _isInit = true;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent) {
        final _st = Provider.of<Studies>(context, listen: false);
        if(_st.hasMoreData()) {
          cpiMsgSnackBar(context, "fetching ---", Theme.of(context).primaryColor, 1);
          _st.fetchStudies(shared: true, loadMore:true);
        } else {
          doneMsgSnackBar(context, "No more data to load", Colors.orange, 1);
        }
      }
    });
    super.initState();
  }
  
  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<Studies>(context, listen: false).fetchStudies(shared: true);
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<MSPTAuth>(context);
    final _studies = Provider.of<Studies>(context);
    List<Study> studies = _studies.getShared(excludeUid: auth.user.uid);

    return Container(
      child: _studies.loading ? 
      Center(
        child: CircularProgressIndicator(
          backgroundColor: Theme.of(context).primaryColor,
        ),
      )  : Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal:10),
        child: RefreshIndicator(
          onRefresh: () => Provider.of<Studies>(context, listen: false).fetchStudies(shared: true),
          child: studies.length > 0 ? ListView.builder(
            controller: scrollController,
            itemCount: studies.length,
            itemBuilder: (context, index) {
              Study study = studies[index];
              return Column(
                children: <Widget>[
                  ListTile(
                    visualDensity: VisualDensity.compact,
                    leading: Icon(
                      Icons.repeat,
                    ),
                    title: Text(
                      study.name,
                      style: Theme.of(context).textTheme.headline2.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    subtitle: auth.user.uid != study.owner.uid ? Text(
                        "By " + study.owner.getFullName(),
                        style: Theme.of(context).textTheme.headline5,
                    ): null,
                    onTap: () => {
                      navigateToPage(context, StudyDetail(studyID: study.uid)),
                    },
                  ),
                  Divider(),
                ],
              );
            },
            scrollDirection: Axis.vertical,
          )
          : ListView.builder(
            itemCount: 1,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  SizedBox(height: 50),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 40),
                      child: Text(
                        " --- There are no Shared studies at the moment. Be the first the share ---- ",
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                ],
              );
            },
            scrollDirection: Axis.vertical,
          ),
        ),
      )
    );
  }
}