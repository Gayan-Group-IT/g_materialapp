import 'package:flutter/material.dart';

/// themeData class
class GSideMenuThemeData{
  Color? groupTitleColor;
  Color? itemTitleColor;
  Color? activeItemTitleColor;
  Color? itemIconColor;
  Color? activeItemIconColor;
  Color? expandedIconColor;
  Color? collapsedIconColor;
  BoxDecoration? decoration;

  GSideMenuThemeData({
    this.groupTitleColor,
    this.itemTitleColor,
    this.activeItemTitleColor,
    this.itemIconColor,
    this.activeItemIconColor,
    this.expandedIconColor,
    this.collapsedIconColor,
    this.decoration,
  });
}