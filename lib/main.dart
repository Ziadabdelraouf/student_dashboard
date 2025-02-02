import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:student_dashboard/Widgets/container.dart';
import 'package:student_dashboard/Widgets/gpa_calculator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //check if it is the first time to open the app
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'student.db');
  final db = await openDatabase(
    path,
    version: 1,
    onCreate: (Database dtb, int version) async {
      await dtb.rawQuery(
          'CREATE TABLE firsttime (id INTEGER PRIMARY KEY, name TEXT)');

      await dtb.rawQuery(
          'CREATE TABLE if not exists firsttime  (id INTEGER PRIMARY KEY, name TEXT)');

      await dtb.rawQuery(
          'CREATE TABLE if not exists students (id INTEGER PRIMARY KEY, name TEXT, Major TEXT, GPA REAL, semesters INTEGER )');
      await dtb.rawQuery(
          'create table if not exists semesters (semid INTEGER PRIMARY KEY, semester_name Text)');
      await dtb.rawQuery(
          'create table if not exists grade (gradeid INTEGER PRIMARY KEY, Grade TEXT, score REAL)');
      await dtb.rawQuery(
          'create table if not exists courses (courseid INTEGER PRIMARY KEY, sid INTEGER, course_name TEXT, grade Integer, credit INTEGER, foreign key (sid) references semesters on delete cascade,foreign key (grade) references grade on update cascade) ');
      await dtb.rawQuery(
          'create table if not exists GPA (Gid INTEGER PRIMARY KEY,semesterid integer, GPA REAL,CGPA real,total_credit INTEGER,foreign key (semesterid) references semesters on delete cascade)');
    },
  );
  // await db.execute('drop table students');

  final List<Map<String, dynamic>> response =
      await db.rawQuery('SELECT * FROM firsttime');
  bool isTableEmpty = response.isEmpty;
  if (isTableEmpty) {
    await db.rawInsert('INSERT INTO firsttime (name) VALUES ("firsttime")');
  }

  // await db.execute('drop table firsttime');
  // await db.execute('drop table students');
  //  await db.execute('drop table grade');
  // await db.execute('drop table GPA');
  // await db.execute('drop table semesters');
  // db.delete('firsttime');
  // db.delete('students');
  // db.close();
  // runApp(text());
  runApp(MyApp(firsttime: isTableEmpty, db: db));
}

class MyApp extends StatefulWidget {
  MyApp({super.key, required this.firsttime, required this.db});
  bool firsttime;
  final Database db;
  @override
  State<MyApp> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  List<Widget> screens = [];
  int _currentIndex = 1;
  @override
  void initState() {
    super.initState();
    // widget.firsttime = false;
    screens = [
      GpaCalculator(db: widget.db),
       CustomContainer(firsttime: false, db: widget.db),
    ];
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Dashboard',
      home: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.lightBlue,
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
                begin: Alignment.bottomLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Scaffold(
              backgroundColor: Colors.transparent,
              bottomNavigationBar: ConvexAppBar(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                elevation: 8,
                activeColor: Colors.white,
                shadowColor: Colors.black.withOpacity(0.1),
                initialActiveIndex: 1,
                items: [
                  TabItem(
                    icon: Icon(Icons.school),
                  ),
                  TabItem(
                    icon: Icon(Icons.home),
                  ),
                  // TabItem(
                  //   icon: Icon(Icons.person),
                  // ),
                ],
                onTap: (index) => setState(() {
                  widget.firsttime = false;
                  _currentIndex = index;
                }),
              ),
              body: _currentIndex == 1
                  ? CustomContainer(
                      db: widget.db,
                      firsttime: widget.firsttime,
                    )
                  : screens[_currentIndex]),
          // StartScreen()
        ],
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.lightBlue, secondary: Colors.white),
      ),
    );
  }
}
