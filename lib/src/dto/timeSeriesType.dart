import 'package:flutter/material.dart';

class TimeSeriesType {

  dynamic base;
  String dateTimeProp;
  String colorProp;

  DateTime dateTime;
  Color color;

  TimeSeriesType(this.base, this.dateTimeProp, this.colorProp) {
    dateTime = DateTime.parse(base[dateTimeProp]);
    color =  Color(base[colorProp]);
  }

  DateTime getDateTime() {
    return dateTime;
  }

  Color getColor() {
    return color;
  }

  setColor(Color color) {
    this.color = color;
    base[colorProp] = color.value;
  }

  setDateTime(DateTime dateTime) {
    this.dateTime = dateTime;
    base[dateTimeProp] = dateTime.toIso8601String();
  }

}
