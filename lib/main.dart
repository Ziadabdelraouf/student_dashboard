import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:student_dashboard/Widgets/container.dart';
import 'package:student_dashboard/Widgets/gpa_calculator.dart';
import 'package:student_dashboard/screens/add_sem.dart';
import 'package:student_dashboard/screens/welcome_screen.dart';
import 'package:student_dashboard/screens/start_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //check if it is the first time to open the app
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'student.db');
  final db = await openDatabase(
    path,
    version: 1,
    onCreate: (Database dtb, int version) async {
      await dtb.execute(
          'CREATE TABLE firsttime (id INTEGER PRIMARY KEY, name TEXT)');
    },
  );
  // await db.execute('drop table students');
  await db.execute(
      'CREATE TABLE if not exists firsttime  (id INTEGER PRIMARY KEY, name TEXT)');

  final List<Map<String, dynamic>> response =
      await db.rawQuery('SELECT * FROM firsttime');
  bool isTableEmpty = response.isEmpty;
  if (isTableEmpty) {
    await db.insert(
      'firsttime',
      {'id': 1, 'name': 'firsttime'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
  const MyApp({super.key, required this.firsttime, required this.db});
  final bool firsttime;
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
    screens = [
      GpaCalculator(db: widget.db),
      CustomContainer(firsttime: false),
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
                  _currentIndex = index;
                }),
              ),
              body: _currentIndex == 1
                  ? CustomContainer(
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
