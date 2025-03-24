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
  int credits = 0;
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
    await widget.db!.rawUpdate('''
    UPDATE GPA 
    SET total_credit = (
        SELECT SUM(c.credit)
        FROM courses c
        WHERE c.sid = GPA.semesterid
        GROUP BY c.sid
    )
  ''');
    await widget.db!.rawUpdate('''
    UPDATE GPA 
    SET CGPA = (
        SELECT SUM(GPA * total_credit) / SUM(total_credit)
        FROM GPA
    )
  ''');
    setState(() {});
  }

  List<Map<String, dynamic>> gpa = [];
  Future<void> _getgpa() async {
    gpa = await widget.db!.rawQuery(
        'select total_credit,semester_name,Gpa,semesterid,CGPA from semesters join GPA on semesters.semid = GPA.semesterid ');
    List<Map> gpa1 = await widget.db!
        .rawQuery('select SUM(total_credit) AS total_credit from GPA');
    credits = gpa1.first['total_credit'] ?? 0;
    setState(() {});
    final List<Map<String, dynamic>> response =
        await widget.db!.rawQuery('SELECT * FROM GPA');
    final List<Map<String, dynamic>> response1 =
        await widget.db!.rawQuery('SELECT * FROM semesters');
    print(response1);
    print(gpa);
    print(response);
    await updateAllGPAs();
  }

  @override
  void initState() {
    setState(() {
      _getgpa();
      updateAllGPAs();
      super.initState();
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
            SizedBox(
              height: kToolbarHeight,
            ),
            Text(
              'GPA Calculator',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              spacing: 20,
              children: [
                Text(
                  gpa.isEmpty || gpa.last['CGPA'].toString() == 'null'
                      ? 'gpa: ' + '0'
                      : 'gpa: ' +
                          double.parse(
                            double.parse(gpa.last['CGPA'].toString())
                                .toStringAsFixed(2),
                          ).toString(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total Credits: ' + credits.toString(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            gpa.isEmpty
                ? Center(
                    child: Text(
                      'nothing to show',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(0),
                      itemCount: gpa.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          secondaryBackground: Container(
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
                          key: Key(
                            gpa[index]['semesterid'].toString(),
                          ),
                          onDismissed: (direction) async {
                            await widget.db!.rawDelete(
                                'delete from semesters where semid = ${gpa[index]['semesterid']}');
                            await widget.db!.rawDelete(
                                'delete from GPA where semesterid = ${gpa[index]['semesterid']}');
                            await widget.db!.rawDelete(
                                'delete from courses where sid = ${gpa[index]['semesterid']}');
                            await updateAllGPAs();
                            await _getgpa();
                            setState(() {});
                          },
                          child: Card(
                            child: ListTile(
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AddSem(
                                      name: gpa[index]['semester_name'],
                                      db: widget.db!,
                                      id: gpa[index]['semesterid'],
                                    ),
                                  ),
                                );
                                _getgpa();
                                setState(() {});
                              },
                              title: Text(
                                  gpa[index]['semester_name'] ?? 'unknown'),
                              subtitle: Text(
                                gpa[index]['GPA'] == null
                                    ? '0'
                                    : double.parse(
                                        double.parse(
                                                gpa[index]['GPA'].toString())
                                            .toStringAsFixed(3),
                                      ).toString(),
                              ),
                              trailing: Text(
                                gpa[index]['total_credit'].toString() == 'null'
                                    ? ' credits: ' + '0'
                                    : ' credits: ' +
                                        gpa[index]['total_credit'].toString(),
                              ),
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
                    iconColor: WidgetStatePropertyAll(
                      Colors.white,
                    ),
                    foregroundColor: WidgetStatePropertyAll(
                      Colors.white,
                    ),
                    backgroundColor: WidgetStatePropertyAll(
                      Colors.red,
                    ),
                  ),
                  onPressed: () async {
                    await widget.db!.rawQuery(
                      'drop table courses',
                    );
                    await widget.db!.rawQuery(
                      'drop table GPA ',
                    );
                    await widget.db!.rawQuery(
                      'drop table semesters',
                    );
                    await widget.db!.rawQuery(
                      'create table if not exists semesters (semid INTEGER PRIMARY KEY, semester_name Text)',
                    );
                    await widget.db!.rawQuery(
                      'create table if not exists courses (courseid INTEGER PRIMARY KEY, sid INTEGER, course_name TEXT, grade id, credit INTEGER, foreign key (sid) references semesters on delete cascade,foreign key (grade) references grade on update cascade) ',
                    );
                    await widget.db!.rawQuery(
                      'create table if not exists GPA (Gid INTEGER PRIMARY KEY,semesterid integer, GPA REAL,CGPA real,total_credit INTEGER,foreign key (semesterid) references semesters on delete cascade)',
                    );
                    _getgpa();
                  },
                  label: Text('delete all'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    int sem = 0;
                    final List<Map<String, dynamic>> response = await widget.db!
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
                          name: 'Semester ${sem + 1}',
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
                  icon: Icon(Icons.add),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
