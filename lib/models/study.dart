import 'package:flutter/material.dart';
import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/models/attribute.dart';
import 'package:msagetrader/models/instrument.dart';
import 'package:msagetrader/models/style.dart';

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
  MSPTUser owner;
  bool public;
  Study(
      {this.uid, this.name, this.description, this.attributes, this.owner, this.public});

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
      owner: MSPTUser.fromJson(json['owner']),
      public: json['public'],
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
  Instrument instrument;
  bool position;
  Style style;
  double pips;
  bool outcome;
  String date;
  double riskReward;
  List<Attribute> attributes = <Attribute>[];
  bool public;

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
    this.public,
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
      instrument: Instrument.fromJson(json['instrument']),
      position: json['position'],
      outcome: json['outcome'],
      pips: double.parse(json['pips'].toString()),
      date: json['date'].toString(),
      style: Style.fromJson(json['style']),
      riskReward: json['rrr'],
      attributes: _attr,
      public: json['public'],
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