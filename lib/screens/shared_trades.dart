import 'package:flutter/material.dart';
import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/models/trade.dart';
import 'package:msagetrader/providers/trades.dart';
import 'package:msagetrader/screens/trade_detail.dart';
import 'package:msagetrader/tabs/trades.dart';
import 'package:msagetrader/utils/snacks.dart';
import 'package:msagetrader/utils/utils.dart';
import 'package:provider/provider.dart';

class SharedTrades extends StatefulWidget {
  const SharedTrades({Key key}) : super(key: key);

  @override
  _SharedTradesState createState() => _SharedTradesState();
}

class _SharedTradesState extends State<SharedTrades> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Shared Trades"),
      ),
      body:  _PageSharedTrades(),
    );
  }
}

class _PageSharedTrades extends StatefulWidget {
  @override
  __PageSharedTradesState createState() => __PageSharedTradesState();
}

class __PageSharedTradesState extends State<_PageSharedTrades> {
  bool _isInit = true;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent) {
        final _tr = Provider.of<Trades>(context, listen: false);
        if(_tr.hasMoreData()) {
          cpiMsgSnackBar(context, "fetching ---", Theme.of(context).primaryColor, 1);
          _tr.fetchTrades(shared: true, loadMore:true);
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
      Provider.of<Trades>(context, listen: false).fetchTrades(shared: true);
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
    final _trades = Provider.of<Trades>(context);
    List<Trade> trades = _trades.getShared(excludeUid: auth.user.uid);

    return Container(
      child: _trades.loading ? 
      Center(
        child: CircularProgressIndicator(
          backgroundColor: Theme.of(context).primaryColor,
        ),
      ) : Padding(
        padding: const EdgeInsets.all(10.0),
        child: RefreshIndicator(
          onRefresh: () => Provider.of<Trades>(context, listen: false).fetchTrades(shared: true),
          child: trades.length > 0 ? ListView.builder(
            controller: scrollController,
            itemCount: trades.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                child: TradeCard(trade: trades[index]),
                onTap: () => navigateToPage(
                  context,
                  TradeDetail(tradeId: trades[index].uid),
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
                    child: Text(
                      " --- There are no Shared Trades yet. Be the first to share --- ",
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: Theme.of(context).primaryColor,
                      )
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