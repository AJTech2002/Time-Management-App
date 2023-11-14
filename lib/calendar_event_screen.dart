import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:timemanagement/event.dart';

class CalendarEventScreen extends StatefulWidget {
  const CalendarEventScreen({super.key});

  @override
  State<CalendarEventScreen> createState() => _CalendarEventScreenState();
}

class _CalendarEventScreenState extends State<CalendarEventScreen> {
  String eventId = "";
  CalendarEventBlock? block;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((d) async {
      eventId = ModalRoute.of(context)!.settings.arguments as String;
      var doc =
          await Localstore.instance.collection('events').doc(eventId).get();
      setState(() {
        if (doc != null) {
          block = CalendarEventBlock.fromJson(doc);
          print(block!.description);
        } else {
          Navigator.of(context).pop();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: block == null
            ? Container()
            : Container(
                child: Stack(
                children: [
                  Container(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_back_ios),
                        ),
                      ),
                      margin: EdgeInsets.only(left: 15 - 8, top: 35 - 8)),
                  Column(
                    children: [
                      Container(
                        height: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1000),
                                color: block!.eventColor,
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              block!.eventName,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 15),
                            child: Text("Description"),
                          ),
                          Container(
                            margin: EdgeInsets.all(15),
                            child: MinimalistTextField(
                              hintText: "Blah blah blah",
                              onChanged: (s) => {block!.description = s},
                              focusedBorderColor: block!.eventColor,
                              initialValue: block!.description,
                            ),
                          ),
                          Center(
                            child: ElevatedButton(
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();

                                  await Localstore.instance
                                      .collection('events')
                                      .doc(eventId)
                                      .set(block!.toJson());

                                  print(block!.toJson());
                                  Navigator.of(context).pop();
                                },
                                child: FittedBox(
                                  child: Row(
                                    children: [
                                      Icon(Icons.check),
                                      SizedBox(width: 10),
                                      Text("Finish")
                                    ],
                                  ),
                                )),
                          )
                        ],
                      )),
                    ],
                  ),
                ],
              )),
      )),
    );
  }
}

class MinimalistTextField extends StatefulWidget {
  final String hintText;
  final Function(String) onChanged;
  final Color focusedBorderColor;
  final String initialValue;

  MinimalistTextField({
    required this.hintText,
    required this.onChanged,
    this.focusedBorderColor = Colors.blue,
    required this.initialValue,
  });

  @override
  _MinimalistTextFieldState createState() => _MinimalistTextFieldState();
}

class _MinimalistTextFieldState extends State<MinimalistTextField> {
  bool _isFocused = false;

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: _isFocused ? widget.focusedBorderColor : Colors.grey,
          width: 2.0,
        ),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        onTap: () {
          setState(() {
            _isFocused = true;
          });
        },
        onSubmitted: (_) {
          setState(() {
            _isFocused = false;
          });
        },
        maxLines: null, // Allow multiline input
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          hintText: widget.hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
