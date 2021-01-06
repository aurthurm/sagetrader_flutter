import 'package:flutter/material.dart';
import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/models/instrument.dart';
import 'package:msagetrader/models/strategy.dart';
import 'package:msagetrader/models/style.dart';
import 'package:msagetrader/utils/utils.dart';

/*
 * Model: 
 * Trade
*/
class Trade {
  String uid;
  Instrument instrument;
  bool position;
  bool status;
  Style style;
  double pips;
  bool outcome;
  String date;
  String description;
  Strategy strategy;
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
  MSPTUser owner;
  bool public;

  Trade({
    this.uid,
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
    this.owner,
    this.public,
  });

  bool hasStyle() => ![style.uid].contains(null);
  bool hasStrategy() => ![strategy.uid].contains(null);
  bool hasInstrument() => ![instrument.uid].contains(null);

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
        uid: json['uid'].toString(),
        instrument: Instrument.fromJson(json['instrument']),
        position: json['position'],
        status: json['status'],
        outcome: json['outcome'],
        pips: processNull(json['pips']),
        date: json['date'].toString(),
        style: Style.fromJson(json['style']),
        description: json['description'],
        strategy: Strategy.fromJson(json['strategy']),
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
        owner: MSPTUser.fromJson(json['owner']),
        public:  json['public'],
      );
  }

  Map<String, dynamic> toJson() =>
    <String, dynamic>{
      "uid": uid,
      "instrument_uid": instrument?.uid,
      "position": position,
      "status": status,
      "style_uid": style?.uid,
      "pips": pips,
      "outcome": outcome,
      "date": date,
      "description": description,
      "strategy_uid": strategy?.uid,
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
      "owner_uid": owner?.uid,
      "public": public,
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
