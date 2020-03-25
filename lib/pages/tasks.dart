import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:moor_flutter/moor_flutter.dart' as moor;
import 'package:provider/provider.dart';
import 'package:tasker/database/database.dart';
import 'package:tasker/models/taskwithtag.dart';
import 'package:tasker/widgets/bottom_sheet.dart';
import 'package:tasker/widgets/checkbox.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

TextEditingController _taskFieldController;
DateTime _today;
DateTime _dueDate;
Tag _selectedTag;

class TasksPage extends StatefulWidget {
  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final kiwi.Container _container = kiwi.Container();
  AppDatabase _appDatabase;

  @override
  void initState() {
    _appDatabase = _container.resolve<AppDatabase>();
    super.initState();
    _taskFieldController = TextEditingController();
    _today = DateTime.now();
    _dueDate = null;
    _setInitialTag();
  }

  void _setInitialTag() async {
    _selectedTag = await _appDatabase.tagDao.getTag("General");
  }

  @override
  Widget build(BuildContext context) {
    AppDatabase _db = Provider.of<AppDatabase>(context);
    return Scaffold(
      body: StreamBuilder<List<TaskWithTag>>(
        stream: _db.taskDao.watchAllTasks(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isNotEmpty) {
              return ListView.separated(
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(snapshot.data[index].task.id.toString()),
                    onDismissed: (direction) async {
                      await _db.taskDao.deleteTask(snapshot.data[index].task);
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: const Text("Deleted"),
                        duration: const Duration(seconds: 5),
                        action: SnackBarAction(
                          label: "Undo",
                          onPressed: () async {
                            await _db.taskDao.insertTask(
                              snapshot.data[index].task.copyWith(),
                            );
                          },
                        ),
                      ));
                    },
                    child: ListTile(
                      leading: CircularCheckBox(
                        color: Color(snapshot.data[index].tag.color),
                        uncheckedColor: Color(snapshot.data[index].tag.color),
                        checked: snapshot.data[index].task.completed,
                        onChange: (value) async {
                          await _db.taskDao.updateTask(
                            snapshot.data[index].task
                                .copyWith(completed: value),
                          );
                        },
                      ),
                      title: Text(
                        snapshot.data[index].task.name,
                        style: TextStyle(
                          decoration: snapshot.data[index].task.completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          fontWeight: FontWeight.w500,
                          color: snapshot.data[index].task.completed
                              ? Colors.black54
                              : Colors.black87,
                        ),
                      ),
                      subtitle: Builder(
                        builder: (context) {
                          final DateTime _date =
                              snapshot.data[index].task.dueDate;
                          if (_date != null) {
                            final Duration _due = _date.difference(_today);
                            if (_due.inDays > 0) {
                              return Text("Due in ${_due.inDays.abs()} day(s)");
                            } else if (_due.inDays == 0) {
                              if (_due.inHours < 0) {
                                return Text(
                                    "Due ${_due.inHours.abs()} hours ago");
                              } else if (_due.inHours > 0) {
                                return Text(
                                    "Due in ${_due.inHours.abs()} hours");
                              } else {
                                return const Text("Due today");
                              }
                            } else if (_due.inDays < 0) {
                              return Text("Due ${_due.inDays.abs()} days ago");
                            } else {
                              return const Text("Not sure when it's due");
                            }
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                      trailing: Icon(
                        FontAwesome.tag,
                        color: Color(snapshot.data[index].tag.color),
                      ),
                      onLongPress: () {
                        _editTask(context, _db, snapshot.data[index]);
                      },
                    ),
                  );
                },
                itemCount: snapshot.data.length,
              );
            } else {
              return const Center(
                child: Text("No tasks yet"),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.pushNamed(context, "/task/new");
          _addTask(context, _db);
        },
        child: Icon(Feather.plus),
      ),
    );
  }

  void _addTask(BuildContext context, AppDatabase db) {
    showModalBottomSheetApp(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          color: const Color(0xFF737373),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            child: TaskAdder(
              db: db,
            ),
          ),
        );
      },
    );
  }

  void _editTask(BuildContext context, AppDatabase db, TaskWithTag task) {
    setState(() {
      _taskFieldController.text = task.task.name;
      _dueDate = task.task.dueDate;
      _selectedTag = task.tag;
    });

    showModalBottomSheetApp(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          color: const Color(0xFF737373),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            child: TaskEditor(
              db: db,
              task: task,
            ),
          ),
        );
      },
    );
  }
}

class TaskAdder extends StatefulWidget {
  final AppDatabase db;

  TaskAdder({@required this.db});

  @override
  _TaskAdderState createState() => _TaskAdderState();
}

class _TaskAdderState extends State<TaskAdder> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                _dueDate != null
                    ? "Due on ${_dueDate.day}/${_dueDate.month}"
                    : "No due date",
              ),
              Text("${_selectedTag?.name ?? ""}"),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
            bottom: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ButtonBar(
                mainAxisSize: MainAxisSize.min,
                alignment: MainAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Feather.calendar,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () async {
                      final DateTime due = await showDatePicker(
                        context: context,
                        firstDate: DateTime(
                          _today.year,
                          _today.month,
                          _today.day,
                        ),
                        lastDate: DateTime(_today.year + 2, 12, 31),
                        initialDate: _today,
                        builder: (BuildContext context, Widget child) {
                          return Theme(
                            data: ThemeData.light(),
                            child: child,
                          );
                        },
                      );

                      if (due != null) {
                        final TimeOfDay time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: TimeOfDay.now().hour + 1,
                            minute: 00,
                          ),
                        );

                        if (time != null) {
                          setState(() {
                            _dueDate = DateTime(due.year, due.month, due.day,
                                time.hour, time.minute);
                          });
                        } else {
                          setState(() {
                            _dueDate = DateTime(due.year, due.month, due.day);
                          });
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      FontAwesome.tag,
                      color: _selectedTag != null
                          ? Color(_selectedTag?.color)
                          : Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      showDialog<Tag>(
                        context: context,
                        builder: (context) => TagDialog(db: widget.db),
                      ).then((value) {
                        setState(() {});
                      }).catchError((error) {
                        print(error);
                      });
                    },
                  )
                ],
              ),
              ButtonBar(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 70,
                    child: FlatButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        _taskFieldController.clear();
                        _dueDate = null;
                        final Tag selectedTag =
                            await widget.db.tagDao.getTag("General");
                        setState(() {
                          _selectedTag = selectedTag;
                        });
                      },
                      child: const Text("Cancel"),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: FlatButton(
                      onPressed: () async {
                        if (_taskFieldController.value.text.isNotEmpty) {
                          try {
                            await widget.db.taskDao.insertTask(
                              TasksCompanion(
                                name:
                                    moor.Value(_taskFieldController.value.text),
                                completed: const moor.Value(false),
                                dueDate: moor.Value(_dueDate),
                                tag: moor.Value(_selectedTag?.name),
                              ),
                            );
                            Navigator.pop(context);
                            _taskFieldController.clear();
                            _dueDate = null;
                            final Tag selectedTag =
                                await widget.db.tagDao.getTag("General");
                            setState(() {
                              _selectedTag = selectedTag;
                            });
                          } catch (e) {
                            print(e);
                          }
                        }
                      },
                      child: Text(
                        "Save",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}

class TaskEditor extends StatefulWidget {
  final AppDatabase db;
  final TaskWithTag task;

  TaskEditor({@required this.db, this.task});

  @override
  _TaskEditorState createState() => _TaskEditorState();
}

class _TaskEditorState extends State<TaskEditor> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                _dueDate != null
                    ? "Due on ${_dueDate.day}/${_dueDate.month}"
                    : "No due date",
              ),
              Text("${_selectedTag?.name ?? ""}"),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
            bottom: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ButtonBar(
                mainAxisSize: MainAxisSize.min,
                alignment: MainAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Feather.calendar,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () async {
                      final DateTime due = await showDatePicker(
                        context: context,
                        firstDate: DateTime(
                          _today.year,
                          _today.month,
                          _today.day,
                        ),
                        lastDate: DateTime(_today.year + 2, 12, 31),
                        initialDate: _dueDate ?? _today,
                        builder: (BuildContext context, Widget child) {
                          return Theme(
                            data: ThemeData.light(),
                            child: child,
                          );
                        },
                      );

                      if (due != null) {
                        final TimeOfDay time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: TimeOfDay.now().hour + 1,
                            minute: 00,
                          ),
                        );

                        if (time != null) {
                          setState(() {
                            _dueDate = DateTime(due.year, due.month, due.day,
                                time.hour, time.minute);
                          });
                        } else {
                          setState(() {
                            _dueDate = DateTime(due.year, due.month, due.day);
                          });
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      FontAwesome.tag,
                      color: _selectedTag != null
                          ? Color(_selectedTag?.color)
                          : Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      showDialog<Tag>(
                        context: context,
                        builder: (context) => TagDialog(db: widget.db),
                      ).then((value) {
                        setState(() {});
                      }).catchError((error) {
                        print(error);
                      });
                    },
                  )
                ],
              ),
              ButtonBar(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 70,
                    child: FlatButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        _taskFieldController.clear();
                        _dueDate = null;
                        final Tag selectedTag =
                            await widget.db.tagDao.getTag("General");
                        setState(() {
                          _selectedTag = selectedTag;
                        });
                      },
                      child: const Text("Cancel"),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: FlatButton(
                      onPressed: () async {
                        if (_taskFieldController.value.text.isNotEmpty) {
                          try {
                            await widget.db.taskDao.updateTask(
                              widget.task.task.copyWith(
                                name: _taskFieldController.value.text,
                                dueDate: _dueDate,
                                tag: _selectedTag.name,
                              ),
                            );
                            Navigator.pop(context);
                            _taskFieldController.clear();
                            _dueDate = null;
                            final Tag selectedTag =
                                await widget.db.tagDao.getTag("General");
                            setState(() {
                              _selectedTag = selectedTag;
                            });
                          } catch (e) {
                            print(e);
                          }
                        }
                      },
                      child: Text(
                        "Update",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}

class TagDialog extends StatefulWidget {
  final AppDatabase db;

  TagDialog({@required this.db});
  @override
  _TagDialogState createState() => _TagDialogState();
}

class _TagDialogState extends State<TagDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Tag your task"),
      content: StreamBuilder<List<Tag>>(
        stream: widget.db.tagDao.watchAllTags(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemBuilder: (context, index) {
                return RadioListTile<Tag>(
                  value: snapshot.data[index],
                  title: Text("${snapshot.data[index].name}"),
                  secondary: Icon(
                    FontAwesome.tag,
                    color: Color(snapshot.data[index].color),
                  ),
                  groupValue: _selectedTag,
                  onChanged: (tag) {
                    setState(() {
                      _selectedTag = tag;
                    });
                  },
                );
              },
              itemCount: snapshot.data.length,
            );
          } else {
            return const Center(
              child: Text("No tags found. Add one in the tags page"),
            );
          }
        },
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: Text(
            "Cancel",
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pop(context, _selectedTag);
          },
          child: const Text("Tag"),
        )
      ],
    );
  }
}
