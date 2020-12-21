import 'package:flutter/material.dart';
import 'package:msagetrader/models/attribute.dart';

/*
 * Model: 
 * Trading Study
*/

class Study {
  String uid;
  String name;
  String description;
  List<StudyItem> items = <StudyItem>[];
  List<Attribute> attributes = <Attribute>[];
  Study(
      {this.uid, this.name, this.description, this.attributes});

  factory Study.fromJson(Map<String, dynamic> json) {
    List<Attribute> _attr = <Attribute>[];

    for (var attr in json['attributes'] ?? []) {
       _attr.add(Attribute.fromJson(attr));
    }

    return Study(
      uid: json['uid'].toString(),
      name: json['name'],
      description: json['description'],
      attributes: [],
    );
  }
  //
}


/*
 * Model: 
 * Trading Study Item
*/

class StudyItem {
  String suid;  //study uid
  String uid;
  String name = "Study Item"; //default value
  String description;
  String instrument;
  bool position;
  String style;
  double pips;
  bool outcome;
  String date;
  double riskReward;
  List<Attribute> attributes = <Attribute>[];

  StudyItem({
    this.suid,
    this.uid,
    this.instrument,
    this.position,
    this.style,
    this.pips,
    this.outcome,
    this.date,
    this.description,
    this.riskReward,
    this.attributes,
  });

  factory StudyItem.fromJson(Map<String, dynamic> json) {
    List<Attribute> _attr = <Attribute>[];

    for (var attr in json['attributes'] ?? []) {
      _attr.add(Attribute.fromJson(attr));
    }

    return StudyItem(
      suid: json['study_uid'].toString(),
      uid: json['uid'].toString(),
      description: json['description'],
      instrument: json['instrument_uid'].toString(),
      position: json['position'],
      outcome: json['outcome'],
      pips: double.parse(json['pips'].toString()),
      date: json['date'].toString(),
      style: json['style_uid'].toString(),
      riskReward: json['rrr'],
      attributes: _attr,
    );
  }

  String positionAsText() {
    if (position) {
      return 'LONG';
    }
    return 'SHORT';
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
  
}