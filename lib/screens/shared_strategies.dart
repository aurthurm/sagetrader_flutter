import 'package:flutter/material.dart';
import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/models/strategy.dart';
import 'package:msagetrader/providers/strategies.dart';
import 'package:msagetrader/screens/strategy_detail.dart';
import 'package:msagetrader/tabs/strategies.dart';
import 'package:msagetrader/utils/snacks.dart';
import 'package:msagetrader/utils/utils.dart';
import 'package:provider/provider.dart';


class SharedStrategies extends StatefulWidget {
  const SharedStrategies({Key key,}) : super(key: key);

  @override
  _SharedStrategiesState createState() => _SharedStrategiesState();
}

class _SharedStrategiesState extends State<SharedStrategies> { 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shared Strategies"),
      ),
      body: _PageSharedStrategies(),
    );
  }
}

class _PageSharedStrategies extends StatefulWidget {
  @override
  __PageSharedStrategiesState createState() => __PageSharedStrategiesState();
}

class __PageSharedStrategiesState extends State<_PageSharedStrategies> { 
  bool _isInit = true;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent) {
        final _st = Provider.of<Strategies>(context, listen: false);
        if(_st.hasMoreData()) {
          cpiMsgSnackBar(context, "fetching ---", Theme.of(context).primaryColor, 1);
          _st.fetchStrategies(shared: true, loadMore:true);
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
      Provider.of<Strategies>(context, listen: false).fetchStrategies(shared: true);
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
    final _strategies = Provider.of<Strategies>(context);
    List<Strategy> strategies = _strategies.getShared(excludeUid: auth.user.uid);


    return Container(
      child: _strategies.loading ? 
      Center(
        child: CircularProgressIndicator(
          backgroundColor: Theme.of(context).primaryColor,
        ),
      )  : Padding(
        padding: const EdgeInsets.all(10.0),
        child: RefreshIndicator(
          onRefresh: () => Provider.of<Strategies>(context, listen: false).fetchStrategies(shared: true),
          child: strategies.length > 0 ? ListView.builder(
            controller: scrollController,
            itemCount: strategies.length,
            itemBuilder: (context, index) {
              Strategy strategy = strategies[index];
              return GestureDetector(
                child: StrategyCard(strategy: strategy),
                onTap: () => navigateToPage(
                  context,
                  StrategyDetail(strategyId: strategy.uid),
                ),
              );
            },
            scrollDirection: Axis.vertical,
            // shrinkWrap: true,
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
                        " --- No Shared Strategies at the moment. Be the first to share --- ",
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Theme.of(context).primaryColor,
                        )
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