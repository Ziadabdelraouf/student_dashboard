import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class StartScreen extends StatefulWidget {
  StartScreen({required this.name, super.key});
  String name;
  @override
  State<StatefulWidget> createState() {
    return _StartScreenState();
  }
}

class _StartScreenState extends State<StartScreen> {
  Future<String> _getname() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'student.db');
    final db = await openDatabase(
      path,
      version: 1,
    );
    final List<Map<String, dynamic>> response =
        await db.rawQuery('SELECT * FROM students');
    setState(() {
      widget.name = response.last['name'];
    });
    return response.last['name'];
  }

  @override
  void initState() {
    super.initState();
    if (widget.name == '-1') {
      _getname().then((value) {
        setState(() {
          widget.name = value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(children: [
        SizedBox(
          height: 100,
        ),
        Text(
          'Student Dashboard',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(
          height: 50,
        ),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: widget.name.isEmpty || widget.name == '-1'
              ? Text('')
              : Text(
                  'welcome back, ${widget.name}',
                  key: ValueKey(widget.name),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.italic,
                  ),
                ),
        ),
        SizedBox(
          height: 110,
        ),
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                width: MediaQuery.of(context).size.width * 0.8,
                "assets/homepage.jpg",
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
