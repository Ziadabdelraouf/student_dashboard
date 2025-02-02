import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:student_dashboard/screens/start_screen.dart';

bool containsNumber(String input) {
  final regex = RegExp(r'\d');
  return regex.hasMatch(input);
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({required this.press, super.key});
  final void Function(String) press;
  @override
  State<StatefulWidget> createState() {
    return _WelcomeScreenState();
  }
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isadded = false;
  String? _errorname;
  final _nameController = TextEditingController();

  bool isadding = false;
  Future<void> _register(String name, String major) async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'student.db');
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE if not exists students (id INTEGER PRIMARY KEY, name TEXT, Major TEXT )');
      },
    );
    await db
        .rawInsert('INSERT INTO grade (Grade,score) VALUES (?,?)', ['A+', 4.0]);
    await db
        .rawInsert('INSERT INTO grade (Grade,score) VALUES (?,?)', ['A', 4.0]);
    await db
        .rawInsert('INSERT INTO grade (Grade,score) VALUES (?,?)', ['A-', 3.7]);
    await db
        .rawInsert('INSERT INTO grade (Grade,score) VALUES (?,?)', ['B+', 3.3]);
    await db
        .rawInsert('INSERT INTO grade (Grade,score) VALUES (?,?)', ['B', 3.0]);
    await db
        .rawInsert('INSERT INTO grade (Grade,score) VALUES (?,?)', ['B-', 2.7]);
    await db
        .rawInsert('INSERT INTO grade (Grade,score) VALUES (?,?)', ['C+', 2.3]);
    await db
        .rawInsert('INSERT INTO grade (Grade,score) VALUES (?,?)', ['C', 2.0]);
    await db
        .rawInsert('INSERT INTO grade (Grade,score) VALUES (?,?)', ['C-', 1.7]);
    await db
        .rawInsert('INSERT INTO grade (Grade,score) VALUES (?,?)', ['D+', 1.3]);
    await db
        .rawInsert('INSERT INTO grade (Grade,score) VALUES (?,?)', ['D', 1.0]);
    await db.execute(
        'INSERT INTO students (name,major,GPA, semesters) VALUES (?,?,0,0)',
        [name, major]);
    setState(() {
      isadding = false;
    });
  }

  String? _error;
  final _UniController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return isadded
        ? StartScreen(
            name: _nameController.text,
          )
        : Center(
            child: Container(
              padding: EdgeInsets.all(15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              height: MediaQuery.of(context).size.height * 0.6,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Form(
                child: Column(
                  spacing: 15,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome to Student Dashboard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(
                      height: 70,
                    ),
                    TextFormField(
                      onChanged: (v) {
                        setState(() {
                          _errorname = null;
                        });
                      },
                      validator: (value) {
                        if (value!.isEmpty || containsNumber(value)) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      controller: _nameController,
                      decoration: InputDecoration(
                        errorText: _errorname,
                        contentPadding: EdgeInsets.all(10),
                        icon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'What should we call you ? ',
                        hintText: 'Name',
                      ),
                    ),
                    TextFormField(
                      onChanged: (val) {
                        setState(() {
                          _error = null;
                        });
                      },
                      validator: (value) {
                        if (value!.isEmpty || containsNumber(value)) {
                          return 'Please enter your major';
                        }
                        return null;
                      },
                      controller: _UniController,
                      decoration: InputDecoration(
                        errorText: _error,
                        contentPadding: EdgeInsets.all(10),
                        icon: Icon(Icons.school),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'What\'s your major ?',
                        hintText: 'Major',
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (isadded) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('You are already registered'),
                                  content: Text(
                                      'please wait while we tailor the app for you',
                                      style: TextStyle(fontSize: 15)),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              });
                          return;
                        }
                        if (_nameController.text.isEmpty ||
                            containsNumber(_nameController.text)) {
                          setState(() {
                            _errorname = 'Please enter your name';
                          });
                        }
                        if (_UniController.text.isEmpty ||
                            containsNumber(_UniController.text)) {
                          _error = 'Please enter your major';
                        } else if (_errorname == null && _error == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Welcome, ${_nameController.text}'),
                            ),
                          );
                          setState(() {
                            isadding = true;
                            isadded = true;
                          });
                          await _register(
                              _nameController.text, _UniController.text);

                          widget.press(_nameController.text);
                        }
                      },
                      child: isadding
                          ? CircularProgressIndicator()
                          : isadded
                              ? Text('Registered')
                              : Text('Register'),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
