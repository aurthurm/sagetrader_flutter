import 'package:flutter/material.dart';

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
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
        id: json['id'].toString(),
        instrument: json['instrument_id'].toString(),
        position: json['position'],
        status: json['status'],
        outcome: json['outcome'],
        pips: double.parse(json['pips'].toString()),
        date: json['date'].toString(),
        style: json['style_id'].toString(),
        description: json['description'],
        strategy: json['strategy_id'].toString(),
        riskReward: json['rr']);
  }

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
}
