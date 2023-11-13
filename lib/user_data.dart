import 'package:flutter/material.dart';
import 'package:timemanagement/event.dart';

class UserData {
  List<CalendarEventBlock> generalEvents = [];

  Map<String, dynamic> toJson() {
    return {"events": generalEvents.map((e) => e.toJson()).toList()};
  }

  static UserData fromJson(Map<String, dynamic> json) {
    UserData newData = UserData();

    newData.generalEvents = [];

    List<dynamic> events = json["events"];

    for (var element in events) {
      newData.generalEvents.add(CalendarEventBlock.fromJson(element));
    }

    return newData;
  }
}
