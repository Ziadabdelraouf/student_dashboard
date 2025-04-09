import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:student_dashboard/Widgets/editable_text.dart';

class AddSem extends StatefulWidget {
  const AddSem(
      {super.key, required this.db, required this.id, required this.name});
  final Database db;
  final int id;
  final String name;
  @override
  State<StatefulWidget> createState() {
    return _AddSemState();
  }
}

class _AddSemState extends State<AddSem> {
  String name = '';
  int credits = 0;
  List<Map>? grades;
  List<Map<String, dynamic>> semesters = [];
  Future<void> _addCourse(String courseName, int grade, int credit) async {
    await widget.db.rawInsert(
      'INSERT INTO courses(sid,course_name,grade,credit) VALUES(?,?,?,?)',
      [widget.id, courseName, grade, credit],
    );
  }

  Future<void> updateAllGPAs() async {
    await widget.db.rawUpdate('''
    UPDATE GPA 
    SET GPA = (
        SELECT SUM(c.credit * g.score) / SUM(c.credit)
        FROM courses c
        JOIN grade g ON c.grade = g.gradeid
        WHERE c.sid = GPA.semesterid
        GROUP BY c.sid
    )
  ''');
    await widget.db.rawUpdate('''
    UPDATE GPA 
    SET total_credit = (
        SELECT SUM(c.credit)
        FROM courses c
        WHERE c.sid = GPA.semesterid
        GROUP BY c.sid
    )
  ''');
    await widget.db.rawUpdate('''
    UPDATE GPA 
    SET CGPA = (
        SELECT SUM(GPA * total_credit) / SUM(total_credit)
        FROM GPA
    )
  ''');
    setState(() {});
  }

  Future<void> _getgpa() async {
    List<Map> gpa = await widget.db
        .rawQuery('select Gpa from GPA where semesterid = ${widget.id}');
    List<Map> credit = await widget.db.rawQuery(
        'select total_credit from GPA where semesterid = ${widget.id}');
    setState(() {
      if (gpa[0]['GPA'] == null) {
        name = '0.000';
      } else {
        name = double.parse(gpa[0]['GPA'].toString()).toStringAsFixed(3);
      }
      credits = credit[0]['total_credit'] ?? 0;
    });
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

  Future<void> _getSemesters() async {
    List<Map<String, dynamic>> semestersdum = await widget.db.rawQuery(
      'SELECT course_name,grade.grade as grade,credit,courseid,gradeid FROM courses  join grade ON courses.grade=gradeid where sid = ${widget.id}',
    );
    semesters = List<Map<String, dynamic>>.from(semestersdum);
    await updateAllGPAs();
    await _getgpa();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _getgrades();
      updateAllGPAs();
      _getSemesters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: EditableTextWidget(
          changename: _changeName,
          initname: widget.name,
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        padding: EdgeInsets.only(top: kToolbarHeight),
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
            children: [
              SizedBox(
                height: kToolbarHeight,
                width: double.infinity,
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
                      print(grades);
                      showModalBottomSheet(
                        isScrollControlled: true,
                        elevation: 20,
                        useSafeArea: true,
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: Form(
                              child: Container(
                                padding: EdgeInsets.all(20),
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                width: MediaQuery.of(context).size.width,
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
                                      children: [
                                        DropdownMenu(
                                            onSelected: (grade) =>
                                                selectedvalue = grade!.toInt(),
                                            initialSelection: 1,
                                            dropdownMenuEntries: grades!.map(
                                              (grade) {
                                                return DropdownMenuEntry<int>(
                                                    value: grade['gradeid'],
                                                    label: grade['Grade']);
                                              },
                                            ).toList()),
                                        DropdownMenu(
                                          initialSelection: 0,
                                          controller: creditcontroller,
                                          label: Text('Creedit hours'),
                                          dropdownMenuEntries: [
                                            DropdownMenuEntry(
                                                value: 0, label: '0'),
                                            DropdownMenuEntry(
                                                value: 1, label: '1'),
                                            DropdownMenuEntry(
                                                value: 2, label: '2'),
                                            DropdownMenuEntry(
                                                value: 3, label: '3'),
                                            DropdownMenuEntry(
                                                value: 4, label: '4'),
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
                                              Colors.white,
                                            ),
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                              Colors.white,
                                            ),
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                              Colors.red,
                                            ),
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
                                                errorname =
                                                    'enter courses name';
                                              });
                                              return;
                                            }
                                            await _addCourse(
                                                nameController.text,
                                                selectedvalue,
                                                int.parse(
                                                    creditcontroller.text));
                                            widget.db
                                                .rawQuery(
                                                    'SELECT * FROM courses')
                                                .then((value) => print(value));
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
                height: 20,
              ),
              Text(
                'Semester GPA: $name',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              Text(
                'Semester Credit hours:$credits ',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              semesters.isEmpty
                  ? Expanded(
                      child: Center(
                        heightFactor: 2,
                        child: Text(
                          'Add courses!',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(0),
                        itemCount: semesters.length,
                        itemBuilder: (context, index) {
                          return Dismissible(
                            background: Container(
                              color: Colors.red,
                              child: Center(
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              final bool? confirm = await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('Confirm Delete'),
                                  content: Text(
                                      'Are you sure you want to delete "${semesters[index]['course_name']}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                final removedId = semesters[index]['courseid'];

                                await Future.delayed(
                                    Duration(milliseconds: 300));
                                setState(() {
                                  semesters.removeWhere((s) =>
                                      s['coursid'] ==
                                      semesters[index]['courseid']);
                                });
                                await widget.db.rawDelete(
                                    'DELETE FROM courses WHERE courseid = ?',
                                    ['${removedId}']);
                                await updateAllGPAs();
                                await _getSemesters();
                                return true; // allow dismissal
                              } else {
                                return false; // cancel dismissal
                              }
                            },
                            key: Key(semesters[index]['courseid'].toString()),
                            child: Card(
                              elevation: 3,
                              child: ListTile(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        padding: EdgeInsets.all(20),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        color: Colors.white,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              semesters[index]['course_name'],
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                DropdownMenu(
                                                  initialSelection:
                                                      semesters[index]
                                                          ['gradeid'],
                                                  onSelected: (grade) async {
                                                    print(
                                                        semesters[index]['1']);
                                                    await widget.db.rawUpdate(
                                                      "UPDATE courses SET grade = ? WHERE courseid = ?",
                                                      [
                                                        int.parse(
                                                            grade.toString()),
                                                        semesters[index]
                                                            ['courseid']
                                                      ],
                                                    );
                                                  },
                                                  dropdownMenuEntries:
                                                      grades!.map((grade) {
                                                    return DropdownMenuEntry<
                                                        int>(
                                                      value: grade['gradeid'],
                                                      label: grade['Grade'],
                                                    );
                                                  }).toList(),
                                                ),
                                                DropdownMenu(
                                                  initialSelection:
                                                      semesters[index]
                                                          ['credit'],
                                                  onSelected: (credit) async {
                                                    await widget.db.rawUpdate(
                                                        "UPDATE courses SET credit = ? WHERE courseid = ?",
                                                        [
                                                          int.parse(credit
                                                              .toString()),
                                                          semesters[index]
                                                              ['courseid']
                                                        ]);
                                                  },
                                                  dropdownMenuEntries: [
                                                    DropdownMenuEntry(
                                                      value: 1,
                                                      label: '1',
                                                    ),
                                                    DropdownMenuEntry(
                                                      value: 2,
                                                      label: '2',
                                                    ),
                                                    DropdownMenuEntry(
                                                      value: 3,
                                                      label: '3',
                                                    ),
                                                  ],
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    setState(() {});
                                                    await _getSemesters();
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Save'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
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
