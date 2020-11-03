import 'package:flutter/material.dart';
import 'package:msagetrader/utils/utils.dart';

/*
 * Model: 
 * Trade
*/
class Trade {
  String id;
  String instrument;
  bool position;
  bool status;
  String style;
  double pips;
  bool outcome;
  String date;
  String description;
  String strategy;
  double riskReward;
  double sl;
  double tp;
  bool tpReached;
  bool tpExceeded;
  bool fullStop;
  double entryPrice;
  double slPrice;
  double tpPrice;
  bool scaledIn;
  bool scaledOut;
  bool correlatedPosition;

  Trade({
    this.id,
    this.instrument,
    this.position,
    this.status,
    this.style,
    this.pips,
    this.outcome,
    this.date,
    this.description,
    this.strategy,
    this.riskReward,
    this.sl,
    this.tp,
    this.tpReached,
    this.tpExceeded,
    this.fullStop,
    this.entryPrice,
    this.slPrice,
    this.tpPrice,
    this.scaledIn,
    this.scaledOut,
    this.correlatedPosition,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
        id: json['id'].toString(),
        instrument: json['instrument_id'].toString(),
        position: json['position'],
        status: json['status'],
        outcome: json['outcome'],
        pips: processNull(json['pips']),
        date: json['date'].toString(),
        style: json['style_id'].toString(),
        description: json['description'],
        strategy: json['strategy_id'].toString(),
        riskReward: json['rr'],
        sl: processNull(json['sl']),
        tp: processNull(json['tp']),
        tpReached:  json['tp_reached'],
        tpExceeded:  json['tp_exceeded'],
        fullStop:  json['full_stop'],
        entryPrice:  processNull(json['entry_price']),
        slPrice:  processNull(json['sl_price']),
        tpPrice:  processNull(json['tp_price']),
        scaledIn:  json['scaled_in'],
        scaledOut:  json['scaled_out'],
        correlatedPosition:  json['correlated_position'],
      );
  }

  Map<String, dynamic> toJson() =>
    <String, dynamic>{
      "instrument_id": instrument,
      "position": position,
      "status": status,
      "style_id": style,
      "pips": pips,
      "outcome": outcome,
      "date": date,
      "description": description,
      "strategy_id": strategy,
      "rr": riskReward,
      "sl": sl,
      "tp": tp,
      "tp_reached": tpReached,
      "tp_exceeded": tpExceeded,
      "full_stop": fullStop,
      "entry_price": entryPrice,
      "sl_price": slPrice,
      "tp_price": tpPrice,
      "scaled_in": scaledIn,
      "scaled_out": scaledOut,
      "correlated_position": correlatedPosition,
    };

  String positionAsText() {
    if (position) {
      return 'LONG';
    }
    return 'SHORT';
  }

  String statusAsText() {
    if (status) {
      return 'OPEN';
    }
    return 'CLOSED';
  }

  Icon getPosition() {
    if (position) {
      return Icon(
        Icons.arrow_upward,
        color: Colors.green,
        size: 20,
      );
    }
    return Icon(
      Icons.arrow_downward,
      color: Colors.red,
      size: 20,
    );
  }

  Icon getStatus() {
    if (status) {
      return Icon(
        Icons.lock_open,
        size: 20,
      );
    }
    return Icon(
      Icons.lock,
      size: 20,
    );
  }

  String toYesNo(bool val) {
    if(val == null)  return " -- Not Set --";
    if (val) return "Yes";
    return "No";
  }
}
