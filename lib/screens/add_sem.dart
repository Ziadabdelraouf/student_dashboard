import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:student_dashboard/Widgets/editable_text.dart';

class AddSem extends StatefulWidget {
  const AddSem({super.key, required this.db, required this.id});
  final Database db;
  final int id;
  @override
  State<StatefulWidget> createState() {
    return _AddSemState();
  }
}

class _AddSemState extends State<AddSem> {
  List<Map>? grades;
  List<Map<String, dynamic>> semesters = [];
  Future<void> _addCourse(String courseName, int grade, int credit) async {
    await widget.db.rawInsert(
      'INSERT INTO courses(sid,course_name,grade,credit) VALUES(?,?,?,?)',
      [widget.id, courseName, grade, credit],
    );
  }

  void _getgrades() async {
    grades = await widget.db.rawQuery('select gradeid,grade,score from grade ');
  }

  Future<void> _changeName(String name) async {
    await widget.db.rawUpdate(
      'UPDATE semesters SET semester_name = ? WHERE semid = ?',
      [name, widget.id],
    );
  }

  void _getSemesters() async {
    semesters = await widget.db.rawQuery(
      'SELECT course_name,grade.grade as grade,credit,courseid FROM courses  join grade ON courses.grade=gradeid where sid = ${widget.id}',
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _getgrades();
      _getSemesters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      // alignment: Alignment.center,
      body: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlue,
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.bottomLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 20,
            children: [
              EditableTextWidget(
                changename: _changeName,
                initname: 'Semester ${widget.id}',
              ),
              SizedBox(
                height: 3,
                width: double.infinity,
                child: ColoredBox(
                  color: Colors.white,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final TextEditingController nameController =
                          TextEditingController();
                      int selectedvalue = 4;
                      final TextEditingController creditcontroller =
                          TextEditingController();
                      final formKey = GlobalKey<FormState>();
                      String? errorname;
                      showModalBottomSheet(
                        elevation: 20,
                        context: context,
                        builder: (context) {
                          return Form(
                            child: Container(
                              padding: EdgeInsets.all(20),
                              height: MediaQuery.of(context).size.height * 0.4,
                              width: MediaQuery.of(context).size.height,
                              color: Colors.white,
                              child: Column(
                                spacing: 20,
                                children: [
                                  Form(
                                    key: formKey,
                                    child: TextFormField(
                                      onChanged: (value) {
                                        setState(() {
                                          errorname = null;
                                          formKey.currentState!.validate();
                                        });
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty || value == ' ') {
                                          return 'enter course name';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        errorText: errorname,
                                        contentPadding: EdgeInsets.all(10),
                                        // icon: Icon(Icons.person),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        labelText: 'Course name ',
                                        hintText: 'course name',
                                      ),
                                      controller: nameController,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    // spacing: 20,
                                    children: [
                                      DropdownMenu(
                                          onSelected: (grade) =>
                                              selectedvalue = grade!.toInt(),
                                          initialSelection: 4,
                                          // controller: gradecontroller,
                                          dropdownMenuEntries: grades!.map(
                                            (grade) {
                                              return DropdownMenuEntry<int>(
                                                  value: grade['gradeid'],
                                                  label: grade['grade']);
                                            },
                                          ).toList()),
                                      DropdownMenu(
                                        initialSelection: 2,
                                        controller: creditcontroller,
                                        label: Text('Creedit hours'),
                                        dropdownMenuEntries: [
                                          DropdownMenuEntry(
                                              value: 1, label: '1'),
                                          DropdownMenuEntry(
                                              value: 2, label: '2'),
                                          DropdownMenuEntry(
                                              value: 3, label: '3'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    spacing: 20,
                                    children: [
                                      ElevatedButton.icon(
                                        style: ButtonStyle(
                                          iconColor: WidgetStatePropertyAll(
                                              Colors.white),
                                          foregroundColor:
                                              WidgetStatePropertyAll(
                                                  Colors.white),
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                  Colors.red),
                                        ),
                                        onPressed: () {
                                          _getSemesters();
                                          Navigator.of(context).pop();
                                        },
                                        label: Text('cancel'),
                                        icon: Icon(Icons.cancel),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          print(nameController.text);
                                          if (!formKey.currentState!
                                              .validate()) {
                                            setState(() {
                                              errorname = 'enter courses name';
                                            });
                                            return;
                                          }
                                          await _addCourse(
                                              nameController.text,
                                              selectedvalue,
                                              int.parse(creditcontroller.text));
                                          widget.db
                                              .rawQuery('SELECT * FROM courses')
                                              .then((value) => print(value));
                                          // print();
                                          setState(() {
                                            Navigator.of(context).pop();
                                          });
                                          _getSemesters();
                                        },
                                        label: Text('Add course'),
                                        icon: Icon(Icons.add),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    label: Text('Add Course'),
                    icon: Icon(Icons.add),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await widget.db.rawDelete(
                          'DELETE FROM courses WHERE sid = ${widget.id}');
                      _getSemesters();
                    },
                    label: Text('delete All'),
                    icon: Icon(Icons.remove_circle),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                width: double.infinity,
                child: semesters.isEmpty
                    ? Center(
                        heightFactor: 2,
                        child: Text(
                          'Add courses!',
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: semesters.length,
                        itemBuilder: (context, index) {
                          return Dismissible(
                            onDismissed: (dism) async {
                              await widget.db.rawDelete(
                                  'DELETE FROM courses WHERE courseid = ${semesters[index]['courseid']}');
                              _getSemesters();
                            },
                            key: Key(semesters[index]['semid'].toString()),
                            child: Card(
                              elevation: 3,
                              child: ListTile(
                                title:
                                    Text('${semesters[index]['course_name']}'),
                                subtitle: Text(
                                    'Credit hours :${semesters[index]['credit']}'),
                                trailing: Text('${semesters[index]['grade']}'),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
