import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:moor_flutter/moor_flutter.dart' as moor;
import 'package:provider/provider.dart';
import 'package:tasker/database/database.dart';
import 'package:tasker/widgets/bottom_sheet.dart';
import 'package:tasker/widgets/checkbox.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _taskFieldController = TextEditingController();
  final DateTime _today = DateTime.now();
  final Map<int, String> _months = {
    1: "Jan",
    2: "Feb",
    3: "Mar",
    4: "Apr",
    5: "May",
    6: "Jun",
    7: "Jul",
    8: "Aug",
    9: "Sep",
    10: "Oct",
    11: "Nov",
    12: "Dec",
  };
  final Map<int, String> _weekdays = {
    1: "Monday",
    2: "Tuesday",
    3: "Wednesday",
    4: "Thursday",
    5: "Friday",
    6: "Saturday",
    7: "Sunday",
  };

  @override
  Widget build(BuildContext context) {
    AppDatabase _db = Provider.of<AppDatabase>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tasker",
          style: TextStyle(
            fontSize: 40,
            letterSpacing: 1.0,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: Container(
            height: 100.0,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _today.day.toString(),
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _months[_today.month].toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _today.year.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  child: Text(
                    _weekdays[_today.weekday].toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Task>>(
        stream: _db.taskDao.watchAllTasks(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0) {
              return ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(snapshot.data[index].id.toString()),
                    onDismissed: (direction) async {
                      await _db.taskDao.deleteTask(snapshot.data[index]);
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Deleted"),
                        duration: Duration(seconds: 5),
                        action: SnackBarAction(
                          label: "Undo",
                          onPressed: () async {
                            await _db.taskDao.insertTask(
                              TasksCompanion(
                                task: moor.Value(snapshot.data[index].task),
                                completed:
                                    moor.Value(snapshot.data[index].completed),
                              ),
                            );
                          },
                        ),
                      ));
                    },
                    child: ListTile(
                      leading: CircularCheckBox(
                        checked: snapshot.data[index].completed,
                        onChange: (value) async {
                          print(value);
                          await _db.taskDao.updateTask(
                            snapshot.data[index].copyWith(completed: value),
                          );
                        },
                      ),
                      title: Text(
                        snapshot.data[index].task,
                        style: TextStyle(
                          decoration: snapshot.data[index].completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          fontWeight: FontWeight.w500,
                          color: snapshot.data[index].completed
                              ? Colors.black54
                              : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
                itemCount: snapshot.data.length,
              );
            } else {
              return Container();
            }
          } else {
            return Container();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Feather.plus),
        onPressed: () {
          // Navigator.pushNamed(context, "/task/new");
          _addTask(context, _db);
        },
      ),
    );
  }

  void _addTask(BuildContext context, AppDatabase db) {
    showModalBottomSheetApp(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          color: Color(0xFF737373),
          child: Container(
            decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(10.0),
                topRight: const Radius.circular(10.0),
              ),
            ),
            child: Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: TextField(
                    controller: _taskFieldController,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: "Task",
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.black54,
                      ),
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom: 8.0,
                    left: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Icon(
                        Feather.plus_circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      ButtonBar(
                        children: <Widget>[
                          FlatButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                              _taskFieldController.clear();
                            },
                          ),
                          FlatButton(
                            child: Text(
                              "Save",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            onPressed: () async {
                              if (_taskFieldController.value.text.isNotEmpty) {
                                try {
                                  await db.taskDao.insertTask(
                                    TasksCompanion(
                                      task: moor.Value(
                                          _taskFieldController.value.text),
                                      completed: moor.Value(false),
                                    ),
                                  );
                                  Navigator.pop(context);
                                  _taskFieldController.clear();
                                } catch (e) {
                                  print(e);
                                }
                              } else {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text("Please input something"),
                                  duration: Duration(
                                    seconds: 5,
                                  ),
                                ));
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
