import 'package:msagetrader/models/trade.dart';
import 'package:msagetrader/providers/instruments.dart';
import 'package:msagetrader/providers/strategies.dart';
import 'package:msagetrader/providers/styles.dart';
import 'package:msagetrader/providers/trades.dart';
import 'package:flutter/material.dart';
import 'package:msagetrader/screens/trade_detail.dart';
import 'package:msagetrader/utils/utils.dart';
import 'package:provider/provider.dart';

class TradesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   final _trades = Provider.of<Trades>(context);
    List<Trade> trades = _trades.trades;

    return Container(
      child: _trades.loading ?
      Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.red,
        ),
      ) :
      ListView.builder(
        itemCount: trades.length,
        itemBuilder: (context, index) {
            if (trades.length > 0) {
              return GestureDetector(
              child: TradeCard(trade: trades[index]),
              onTap: () => navigateToPage(
                context,
                TradeDetail(tradeId: trades[index].id),
              ),
            );
          } else {
            return Center(
              child: Text(
                "You havent Journaled any trades yet.",
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                  color: Theme.of(context).primaryColor,
                )
              ),
            );
          }
        },
        scrollDirection: Axis.vertical,
        // shrinkWrap: true,
      ),
    );
  }
}



class TradeCard extends StatelessWidget {
  final trade;
  const TradeCard({this.trade});
  @override
  Widget build(BuildContext context) {
    final _strategies = Provider.of<Strategies>(context, listen: false);
    final _instruments = Provider.of<Instruments>(context, listen: false);
    final _styles = Provider.of<Styles>(context, listen: false);
    final instrument = _instruments.findById(trade.instrument);
    final strategy = _strategies.findById(trade.strategy);
    final style = _styles.findById(trade.style);

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
                width: 85,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      instrument.name(),
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
                      text: getExerpt(strategy.name, 10),
                      background: Theme.of(context).primaryColor, // Color(0xFFFFB703),
                      fsize: 13,
                      fweight: FontWeight.w400,
                      fcolor: Colors.white,
                    )
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
                      getExerpt(style.name(), 7),
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