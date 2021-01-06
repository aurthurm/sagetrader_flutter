import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/models/trade.dart';
import 'package:msagetrader/providers/trades.dart';
import 'package:flutter/material.dart';
import 'package:msagetrader/screens/trade_detail.dart';
import 'package:msagetrader/utils/snacks.dart';
import 'package:msagetrader/utils/utils.dart';
import 'package:provider/provider.dart';

class TradesTab extends StatefulWidget {
  @override
  _TradesTabState createState() => _TradesTabState();
}

class _TradesTabState extends State<TradesTab> { 
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent) {
        final _tr = Provider.of<Trades>(context, listen: false);
        if(_tr.hasMoreData()) {
          cpiMsgSnackBar(context, "fetching ---", Theme.of(context).primaryColor, 1);
          _tr.fetchTrades(shared: false, loadMore:true);
        } else {
          doneMsgSnackBar(context, "No more data to load", Colors.orange, 1);
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _trades = Provider.of<Trades>(context);
    final me = Provider.of<MSPTAuth>(context);
    List<Trade> trades = _trades.getForUser(me.user.uid);

    return Container(
      child: _trades.loading ?
      Center(
        child: CircularProgressIndicator(
          backgroundColor: Theme.of(context).primaryColor,
        ),
      ) : 
      RefreshIndicator(
        onRefresh: () => Provider.of<Trades>(context, listen: false).fetchTrades(),
        child: trades.length > 0 ? ListView.builder(
          controller: scrollController,
          physics: AlwaysScrollableScrollPhysics(),
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
                    "You havent Journaled any trades yet.",
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
    );
  }
}



class TradeCard extends StatelessWidget {
  final trade;
  const TradeCard({this.trade});
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<MSPTAuth>(context);

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  auth.user.uid != trade.owner.uid ? Padding(
                    padding: const EdgeInsets.fromLTRB(10, 2, 0, 2),
                    child: Text(
                      "By " + trade.owner.getFullName(),
                    ),
                  ) : Container(),
                ]
              ),
              Row(
                children: [
                  Container(
                    width: 85,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          trade.instrument.name(),
                          style: Theme.of(context).textTheme.headline2
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              trade.getPosition(),
                              Text(" | "),
                              Text(
                                trade.statusAsText(),
                                style:  Theme.of(context).textTheme.headline4
                              ),
                            ],
                          ),
                        ),
                        Tag(
                          text: getExerpt(trade.strategy.name, 10),
                          background: Theme.of(context).primaryColor, // Color(0xFFFFB703),
                          fsize: 13,
                          fweight: FontWeight.w400,
                          fcolor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          humanizeDate(trade.date),
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        Divider(
                          color: Colors.grey,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                          child: Text(
                            getExerpt(trade.description, 30),
                            style:  Theme.of(context).textTheme.bodyText2.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        // Row(
                        //   children: [
                        //     Tag(
                        //       text: strategy.name,
                        //       background: Colors.grey,
                        //       fsize: 11,
                        //       fweight: FontWeight.w300,
                        //       fcolor: Colors.white,
                        //     ),
                        //     Tag(
                        //       text: strategy.name,
                        //       background: Colors.grey,
                        //       fsize: 11,
                        //       fweight: FontWeight.w300,
                        //       fcolor: Colors.white,
                        //     ),
                        //   ],
                        // )
                      ],
                    ),
                  ),
                  SizedBox(width: 5),
                  Container(
                    width: 80,
                    child: Column(
                      children: [
                        Text(
                          getExerpt(trade.style.name(), 7),
                          style:  Theme.of(context).textTheme.headline5
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                          child: Text(
                            (trade.outcome ? "+ " : "- ") + trade.pips.toString(),
                            style:  Theme.of(context).textTheme.headline5.copyWith(
                              color: trade.outcome ? Colors.green : Colors.red
                            ),
                          ),
                        ),
                        Text(
                          "RR  1:" + trade.riskReward.toString(),                      
                          style:  Theme.of(context).textTheme.headline5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Tag extends StatelessWidget {
  final String text;
  final Color background;
  final double fsize;
  final FontWeight fweight;
  final Color fcolor;
  const Tag(
      {this.text, this.background, this.fsize, this.fweight, this.fcolor});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 1,
        horizontal: 5,
      ),
      margin: EdgeInsets.only(right: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fcolor,
          fontWeight: fweight,
          fontSize: fsize,
        ),
      ),
    );
  }
}


// Kept for future reference, they work
// just that they fetch from the api evertime the
// tab is opened: therefore i am using didchangedependencies


// child: FutureProvider<List<Trade>>(
//   create: (_) async => Trades().fetchTrades(),
//   child: Consumer<List<Trade>>(
//     builder: (context, data, __) {
//       var length = data?.length ?? 0;
//       if (length == 0) {
//         return Center(child: CircularProgressIndicator(),);
//       }
//       return ListView.builder(
//             itemCount: length,
//             itemBuilder: (context, index) {
//               return GestureDetector(
//                 child: TradeCard(trade: data[index]),
//                 onTap: () => navigateToPage(
//                   context,
//                   TradeDetail(tradeId: data[index].id),
//                 ),
//               );
//             },
//             scrollDirection: Axis.vertical,
//             // shrinkWrap: true,
//           );
//     }
//   ),
// ),

//       child: FutureBuilder(
//         future: Trades().fetchTrades(),
//         builder: (context, snapshot) {
//           switch (snapshot.connectionState) {
//             case ConnectionState.active:
//             case ConnectionState.waiting:
//               return Center(child: CircularProgressIndicator());
//             case ConnectionState.none:
//               return Center(child: Text("Add trades."));
//             case ConnectionState.done:              
//               if (snapshot.hasError) {
//                 return Center(child: Text("Error Occured"),);
//               }

//               if(snapshot.hasData) {
//                 return ListView.builder(
//                   itemCount: snapshot.data.length,
//                   itemBuilder: (context, index) {
//                     return GestureDetector(
//                       child: TradeCard(trade: snapshot.data[index]),
//                       onTap: () => navigateToPage(
//                         context,
//                         TradeDetail(tradeId: snapshot.data[index].id),
//                       ),
//                     );
//                   },
//                   scrollDirection: Axis.vertical,
//                   // shrinkWrap: true,
//                 );
//               }

//               return Center(child: Text("Arrg, not supposed to happen"));
//           }
//         },
//       ),