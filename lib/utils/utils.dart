import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/*
 * Creates an excerpt from a given string
*/
String getExerpt(string, count) {
  if (string.length > count) {
    return string.replaceRange(count, string.length, " ...");
  }
  return string;
}

/*
 * Navigate to a different Page
*/
Future navigateToPage(context, thePage) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => thePage));
}

/*
 * Navigate to a different Page
*/
String humanizeDate(String date) {
  DateTime _date = DateTime.parse(date);
  return DateFormat("EEEE d MMMM y").format(_date); // e.g Monday 12 May 2020
}
