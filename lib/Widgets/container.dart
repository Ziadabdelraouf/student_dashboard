import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:student_dashboard/screens/start_screen.dart';
import 'package:student_dashboard/screens/welcome_screen.dart';

class CustomContainer extends StatefulWidget {
  const CustomContainer({super.key, required this.firsttime});
  final bool firsttime;
  @override
  State<StatefulWidget> createState() {
    return _CustomContainerState();
  }
}

class _CustomContainerState extends State<CustomContainer> {
  void _changescreen(String name) {
    content = StartScreen(name:name);
  }

  Widget content = StartScreen(name: '-1');
  @override
  void initState() {
    if (widget.firsttime) {
      content = WelcomeScreen(press: _changescreen);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return content;
    // Center(
    //   child: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //       Container(
    //         alignment: Alignment.center,
    //         decoration: BoxDecoration(
    //           color: Colors.white,
    //           borderRadius: BorderRadius.circular(25),
    //         ),
    //         height: MediaQuery.of(context).size.height * 0.6,
    //         width: MediaQuery.of(context).size.width * 0.8,
    //         child: Image.asset(
    //           "assets/homepage.jpg",
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
