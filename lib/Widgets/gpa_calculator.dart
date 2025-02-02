import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:student_dashboard/screens/add_sem.dart';

class GpaCalculator extends StatefulWidget {
  const GpaCalculator({super.key, required this.db});
  final Database? db;
  @override
  State<StatefulWidget> createState() {
    return _GpaCalculatorState();
  }
}

class _GpaCalculatorState extends State<GpaCalculator> {
  Future<void> updateAllGPAs() async {
    await widget.db!.rawUpdate('''
    UPDATE GPA 
    SET GPA = (
        SELECT SUM(c.credit * g.score) / SUM(c.credit)
        FROM courses c
        JOIN grade g ON c.grade = g.gradeid
        WHERE c.sid = GPA.semesterid
        GROUP BY c.sid
    )
  ''');
  }

  List<Map<String, dynamic>> gpa = [];
  Future<void> _getgpa() async {
    gpa = await widget.db!.rawQuery(
        'select semester_name,total_credit,Gpa,semesterid from semesters join GPA on semesters.semid = GPA.semesterid ');
    setState(() {});
    final List<Map<String, dynamic>> response =
        await widget.db!.rawQuery('SELECT * FROM GPA');
    final List<Map<String, dynamic>> response1 =
        await widget.db!.rawQuery('SELECT * FROM semesters');
    print(response1);
    print(response);
    await updateAllGPAs();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _getgpa();
      updateAllGPAs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          spacing: 20,
          children: [
            Text(
              'GPA Calculator',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Text('This is the GPA Calculator page'),
            SizedBox(
              height: 300,
              child: gpa.isEmpty
                  ? Center(
                      child: Text(
                        'nothing to show',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: gpa.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            onTap: () async {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AddSem(
                                    db: widget.db!,
                                    id: gpa[index]['semesterid'],
                                  ),
                                ),
                              );
                            },
                            title: Text(gpa[index]['semester_name']),
                            subtitle: Text(
                              gpa[index]['GPA'] == null
                                  ? '0'
                                  : double.parse(
                                      double.parse(gpa[index]['GPA'].toString())
                                          .toStringAsFixed(3),
                                    ).toString(),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              spacing: 20,
              children: [
                ElevatedButton.icon(
                  style: ButtonStyle(
                    iconColor: WidgetStatePropertyAll(Colors.white),
                    foregroundColor: WidgetStatePropertyAll(Colors.white),
                    backgroundColor: WidgetStatePropertyAll(Colors.red),
                  ),
                  onPressed: () async {
                    await widget.db!.rawQuery('drop table courses');
                    await widget.db!.rawQuery('drop table GPA ');
                    await widget.db!.rawQuery('drop table semesters');
                    await widget.db!.rawQuery(
                        'create table if not exists semesters (semid INTEGER PRIMARY KEY, semester_name Text)');
                    await widget.db!.rawQuery(
                        'create table if not exists courses (courseid INTEGER PRIMARY KEY, sid INTEGER, course_name TEXT, grade id, credit INTEGER, foreign key (sid) references semesters on delete cascade,foreign key (grade) references grade on update cascade) ');
                    await widget.db!.rawQuery(
                        'create table if not exists GPA (Gid INTEGER PRIMARY KEY,semesterid integer, GPA REAL,CGPA real,total_credit INTEGER,foreign key (semesterid) references semesters on delete cascade)');
                    _getgpa();
                  },
                  label: Text('delete all'),
                ),
                ElevatedButton.icon(
                    onPressed: () async {
                      int sem = 0;
                      final List<Map<String, dynamic>> response = await widget
                          .db!
                          .rawQuery('SELECT semid FROM semesters');
                      if (response.isNotEmpty) {
                        sem = await response.last['semid'];
                      }
                      await widget.db!.execute(
                          'insert into semesters (semester_name) values ("Semester ${sem + 1}")');
                      await widget.db!.execute(
                          'insert into GPA (semesterid,GPA,CGPA,total_credit) values (${sem + 1},0,0,0)');
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddSem(
                            db: widget.db!,
                            id: (sem + 1),
                          ),
                        ),
                      );
                      await updateAllGPAs();
                      await _getgpa();
                      print(gpa);
                    },
                    label: Text('Add Semester'),
                    icon: Icon(Icons.add)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
