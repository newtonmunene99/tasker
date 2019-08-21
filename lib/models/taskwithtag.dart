import 'package:flutter/foundation.dart';
import 'package:tasker/database/database.dart';

class TaskWithTag {
  final Task task;
  final Tag tag;

  TaskWithTag({
    @required this.task,
    @required this.tag,
  });
}
