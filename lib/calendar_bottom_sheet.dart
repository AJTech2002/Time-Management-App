import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:timemanagement/calendar_screen.dart';
import 'package:timemanagement/main.dart';
import 'package:timemanagement/user_data.dart';

class CalendarBottomSheet extends StatefulWidget {
  final Function(String name, Color eventColor) eventCreated;
  final UserData userData;

  const CalendarBottomSheet(
      {super.key, required this.eventCreated, required this.userData});

  @override
  State<CalendarBottomSheet> createState() => _CalendarBottomSheetState();
}

class _CalendarBottomSheetState extends State<CalendarBottomSheet> {
  Color selectedColor = Colors.blue;

  List<Widget> userDataEvents() {
    return [
      Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: CalendarEvent(
          event: null,
          hour: -1,
          onClick: () {
            widget.eventCreated("", Colors.blue);
            Navigator.of(context).pop();
          },
          onComplete: () => {},
          onIncomplete: () => {},
        ),
      ),
      ...widget.userData.generalEvents
          .map<Widget>(
            (e) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: CalendarEvent(
                event: e,
                hour: -1,
                onClick: () {
                  widget.eventCreated(e.eventName, e.eventColor);
                  Navigator.of(context).pop();
                },
                onComplete: () => {},
                onIncomplete: () => {},
              ),
            ),
          )
          .toList()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ColorPicker(
                        color: selectedColor,
                        onColorChanged: (Color color) {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                        heading: Text('Select a Color'),
                        subheading: Text('Choose a color for your design'),
                      ).showPickerDialog(
                        context,
                      );
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1000),
                        color: selectedColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: CalendarTextField(
                      borderColor: selectedColor,
                      placeholder: "Event Name",
                      onSubmitted: (s) => {
                        widget.eventCreated(s, selectedColor),
                      },
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 15, bottom: 15, top: 15),
                  alignment: Alignment.centerLeft,
                  child: const Text("Suggested Events"),
                ),
                ...userDataEvents()
              ],
            )
          ],
        ),
      ),
    );
  }
}
