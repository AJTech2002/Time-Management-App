// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:timemanagement/calendar_event_screen.dart';
import 'package:timemanagement/calendar_screen.dart';
import 'package:timemanagement/event.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => const CalendarScreen(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/calendarEvent': (context) => const CalendarEventScreen(),
      },
      // home: CalendarScreen(),
    );
  }
}

class CalendarEvent extends StatelessWidget {
  final CalendarEventBlock? event;
  final int hour;

  final Function() onIncomplete;
  final Function() onComplete;
  final Function() onClick;
  final Function() onLongPress;

  const CalendarEvent({
    super.key,
    required this.event,
    required this.hour,
    required this.onClick,
    required this.onComplete,
    required this.onIncomplete,
    required this.onLongPress,
  });

  String getHour() {
    if (hour == -1) return "";
    if (hour > 12) {
      int newHour = hour - 12;
      return "${newHour}pm";
    }

    if (hour == 0) return "12am";

    return "${hour}am";
  }

  void incomplete(BuildContext context) {
    onIncomplete();
  }

  void complete(BuildContext context) {
    onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          event != null && event!.completed && event!.replacedBy != null
              ? Expanded(
                  flex: 4,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    height: 65,
                    decoration: BoxDecoration(
                      color: event != null
                          ? event!.replacedBy!.eventColor
                              .withOpacity(event!.completed ? 0.4 : 1)
                          : Colors.white,
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        event!.replacedBy!.eventName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
          Expanded(
            flex: 7,
            child: Slidable(
              enabled: event != null && !event!.completed,
              endActionPane: ActionPane(
                openThreshold: 0.2,
                motion: ScrollMotion(),
                children: [
                  SlidableAction(
                    // An action can be bigger than the others.
                    flex: 2,
                    onPressed: complete,
                    autoClose: true,
                    backgroundColor: Color(0xFF7BC043),
                    foregroundColor: Colors.white,
                    icon: Icons.check,
                    label: 'Complete',
                  ),
                ],
              ),
              startActionPane: ActionPane(
                openThreshold: 0.2,
                motion: ScrollMotion(),
                children: [
                  SlidableAction(
                    // An action can be bigger than the others.
                    flex: 2,
                    onPressed: incomplete,
                    autoClose: true,
                    backgroundColor: Color.fromARGB(255, 192, 67, 67),
                    foregroundColor: Colors.white,
                    icon: Icons.cancel,
                    label: 'Incomplete',
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: this.onClick,
                onLongPress: this.onLongPress,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  height: 65,
                  decoration: BoxDecoration(
                    color: event != null
                        ? event!.eventColor
                            .withOpacity(event!.completed ? 0.3 : 1)
                        : Colors.white,
                    border: (event != null && event!.completed)
                        ? Border.all(color: Colors.white)
                        : Border.all(
                            color: event != null
                                ? event!.eventColor
                                : Colors.blue.withOpacity(0.4),
                            style: BorderStyle.solid,
                            width: 2,
                          ),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  // Event Title
                  child: event != null
                      ? Container(
                          child: Row(
                            children: [
                              SizedBox(width: 20),
                              Text(
                                event!.eventName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              Text(
                                getHour(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(width: 20)
                            ],
                          ),
                        )
                      : Container(
                          child: Center(
                            child: Text(
                              getHour(),
                              style: TextStyle(
                                color: Colors.blue.withOpacity(0.3),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarDays extends StatefulWidget {
  final Function(int day, int month, int year) onNewDaySelected;

  const CalendarDays({
    super.key,
    required this.onNewDaySelected,
  });

  @override
  State<CalendarDays> createState() => _CalendarDaysState();
}

class _CalendarDaysState extends State<CalendarDays> {
  String selected = "MO";
  List<String> days = ["MO", "TU", "WE", "TH", "FR", "SA", "SU"];

  int todayIndex = -1;

  @override
  void initState() {
    super.initState();

    selected =
        DateFormat('EEEE').format(DateTime.now()).substring(0, 2).toUpperCase();

    todayIndex = days.indexOf(selected);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.onNewDaySelected(
          DateTime.now().day, DateTime.now().month, DateTime.now().year);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: days
          .map((e) => CalendarDay(
                day: e,
                onClick: () {
                  setState(() {
                    selected = e;
                  });

                  int currentIndex = days.indexOf(e);
                  int daysOff = currentIndex - todayIndex;

                  DateTime currentDateTime =
                      DateTime.now().add(Duration(days: daysOff));

                  widget.onNewDaySelected(currentDateTime.day,
                      currentDateTime.month, currentDateTime.year);
                },
                highlighted: e == selected,
              ))
          .toList(),
    );
  }
}

class CalendarDay extends StatelessWidget {
  final String day;
  final bool highlighted;
  final Function() onClick;

  const CalendarDay(
      {super.key,
      required this.day,
      required this.onClick,
      this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 20,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          color: highlighted ? Colors.blue : Colors.white,
        ),
        child: Text(
          day,
          style: TextStyle(
            color: highlighted ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
