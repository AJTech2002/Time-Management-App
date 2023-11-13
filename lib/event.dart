import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CalendarEventBlock extends Equatable {
  final int hour;
  final String eventName;
  final Color eventColor;
  bool completed;
  CalendarEventBlock? replacedBy;

  CalendarEventBlock({
    required this.hour,
    required this.eventName,
    required this.eventColor,
    this.completed = false,
    this.replacedBy,
  });

  static CalendarEventBlock fromJson(Map<String, dynamic> json) {
    CalendarEventBlock block = CalendarEventBlock(
      hour: json["hour"],
      eventName: json["eventName"],
      eventColor: Color(json["eventColor"]),
      completed: json["completed"],
    );

    if (json.containsKey("replacedBy")) {
      block.replacedBy = CalendarEventBlock(
        hour: 0,
        eventName: json["replacedBy"]["eventName"],
        eventColor: Color(json["replacedBy"]["eventColor"]),
      );
    }

    return block;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> mapped = {
      "hour": hour,
      "eventName": eventName,
      "eventColor": eventColor.value,
      "completed": completed,
    };

    if (replacedBy != null) {
      mapped["replacedBy"] = {
        "eventName": replacedBy?.eventName,
        "eventColor": replacedBy?.eventColor.value
      };
    }

    return mapped;
  }

  @override
  List<Object?> get props => [eventName, eventColor.value];
}
