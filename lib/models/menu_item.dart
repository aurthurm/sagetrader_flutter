import 'package:flutter/material.dart';

/*
 * Model: 
 * Single Menu Item Instance for each Tab
*/
class MenuItem {
  String title;
  IconData icon;
  Widget tab;
  MenuItem({this.title, this.icon, this.tab});
}

/*
 * Data: 
 * Menu Tabs
*/
List<MenuItem> menuItems = <MenuItem>[
  MenuItem(title: "Trades", icon: Icons.assessment),
  MenuItem(title: "Strategies", icon: Icons.adjust),
  MenuItem(title: "Studies", icon: Icons.refresh),
  MenuItem(title: "T Plan", icon: Icons.work),
  MenuItem(title: "Tasks", icon: Icons.speaker_notes),
  MenuItem(title: "Statistics", icon: Icons.trending_up),
];
