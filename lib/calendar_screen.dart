// ignore_for_file: sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:timemanagement/calendar_bottom_sheet.dart';
import 'package:timemanagement/event.dart';
import 'package:timemanagement/main.dart';
import 'package:timemanagement/user_data.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({
    super.key,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  UserData userData = UserData();

  List<int> hoursInDay = [];
  Map<int, CalendarEventBlock> eventMappedToHour = {};

  String headingText = "today";
  Color selectedColor = Colors.blue;

  DateTime selectedDay = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    for (int i = 0; i < 24; i++) {
      hoursInDay.add(i);
    }

    Localstore.instance.collection('user').doc('user').get().then((value) => {
          if (value != null) {userData = UserData.fromJson(value)}
        });
  }

  void switchToDay(String uniqueId) async {
    // Find a day based on the UniqueID and replace all the state
    print("Switching to day : " + uniqueId);

    // Hook into file system to find the day
    List<CalendarEventBlock> recievedBlocks = [];

    for (int i = 0; i < 24; i++) {
      String uid = selectedDay.day.toString().padLeft(2, '0') +
          selectedDay.month.toString().padLeft(2, '0') +
          selectedDay.year.toString().padLeft(2, '0') +
          i.toString().padLeft(2, '0').trim();

      final map = await Localstore.instance.collection('events').doc(uid).get();

      if (map != null) {
        CalendarEventBlock event = CalendarEventBlock.fromJson(map);
        recievedBlocks.add(event);
      }
    }

    setState(() {
      eventMappedToHour.clear();
      for (var event in recievedBlocks) {
        eventMappedToHour[event.hour] = event;
      }
    });
  }

  void onEventSelected(int hour) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ), // Remove border radius
      ),
      builder: (context) {
        return CalendarBottomSheet(
          userData: userData,
          eventCreated: (name, eventColor) {
            if (name != "") {
              this.setState(() {
                eventMappedToHour[hour] = CalendarEventBlock(
                  hour: hour,
                  eventName: name,
                  eventColor: eventColor,
                );
              });

              String uniqueId = selectedDay.day.toString().padLeft(2, '0') +
                  selectedDay.month.toString().padLeft(2, '0') +
                  selectedDay.year.toString().padLeft(2, '0') +
                  hour.toString().padLeft(2, '0');

              // save the item
              Localstore.instance
                  .collection('events')
                  .doc(uniqueId)
                  .set(eventMappedToHour[hour]!.toJson())
                  .then((_) => {print("Wrote file for : " + uniqueId)});

              userData.generalEvents.insert(
                  0,
                  CalendarEventBlock(
                    hour: hour,
                    eventName: name,
                    eventColor: eventColor,
                  ));

              userData.generalEvents = userData.generalEvents.toSet().toList();

              Localstore.instance.collection('user').doc('user').set(
                    userData.toJson(),
                  );
            } else {
              //Delete

              this.setState(() {
                eventMappedToHour.remove(hour);
              });

              String uniqueId = selectedDay.day.toString().padLeft(2, '0') +
                  selectedDay.month.toString().padLeft(2, '0') +
                  selectedDay.year.toString().padLeft(2, '0') +
                  hour.toString().padLeft(2, '0');

              // save the item
              Localstore.instance
                  .collection('events')
                  .doc(uniqueId)
                  .delete()
                  .then((_) => {print("Deleted file for : " + uniqueId)});
            }
          },
        );
      },
    );
  }

  void selectEventForIncompletion(int hour) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ), // Remove border radius
      ),
      builder: (context) {
        return CalendarBottomSheet(
          userData: userData,
          eventCreated: (name, eventColor) {
            this.setState(() {
              eventMappedToHour[hour]?.completed = true;
              eventMappedToHour[hour]?.replacedBy = CalendarEventBlock(
                hour: hour,
                eventName: name,
                eventColor: eventColor,
              );
            });

            String uniqueId = selectedDay.day.toString().padLeft(2, '0') +
                selectedDay.month.toString().padLeft(2, '0') +
                selectedDay.year.toString().padLeft(2, '0') +
                hour.toString().padLeft(2, '0');

            Localstore.instance
                .collection('events')
                .doc(uniqueId)
                .set(eventMappedToHour[hour]!.toJson());
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Localstore.instance.collection('events').delete();
                        Localstore.instance
                            .collection('user')
                            .doc('user')
                            .delete();
                      },
                      child: Text(
                        headingText,
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb),
                        Text("50%"),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: CalendarDays(
                onNewDaySelected: (day, month, year) {
                  String uniqueId = day.toString().padLeft(2, '0') +
                      month.toString().padLeft(2, '0') +
                      year.toString().padLeft(2, '0');

                  selectedDay = DateTime(year, month, day);

                  switchToDay(uniqueId);

                  DateTime today = DateTime.now();
                  if (day == today.day &&
                      month == today.month &&
                      year == today.year) {
                    setState(() {
                      headingText = "today";
                    });
                  } else {
                    setState(() {
                      headingText = "${day} ${month} ${year}";
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    children: hoursInDay.map((e) {
                      return CalendarEvent(
                        event: eventMappedToHour[e],
                        hour: e,
                        onClick: () => onEventSelected(e),
                        onComplete: () {
                          this.setState(() {
                            eventMappedToHour[e]?.completed = true;
                          });

                          String uniqueId =
                              selectedDay.day.toString().padLeft(2, '0') +
                                  selectedDay.month.toString().padLeft(2, '0') +
                                  selectedDay.year.toString().padLeft(2, '0') +
                                  e.toString().padLeft(2, '0');

                          Localstore.instance
                              .collection('events')
                              .doc(uniqueId)
                              .set(eventMappedToHour[e]!.toJson());
                        },
                        onIncomplete: () => {selectEventForIncompletion(e)},
                      );
                    }).toList(),
                  ),
                ),
              ),
              flex: 20,
            )
          ],
        ),
      ),
    );
  }
}

class CalendarTextField extends StatelessWidget {
  final String placeholder;
  final Color borderColor;
  final Function(String) onSubmitted;

  CalendarTextField({
    required this.placeholder,
    required this.onSubmitted,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: borderColor.withOpacity(0.8), width: 2.0),
      ),
      child: TextField(
        onSubmitted: (s) {
          onSubmitted(s);
          Navigator.of(context).pop();
        }, // Callback for when text is submitted
        decoration: InputDecoration(
          hintText: placeholder,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
