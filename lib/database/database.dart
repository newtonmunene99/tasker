import 'package:flutter/material.dart' as material;
import 'package:moor_flutter/moor_flutter.dart';
import 'package:tasker/models/taskwithtag.dart';

part 'database.g.dart';

/// This class defines our database.
@UseMoor(tables: [Tasks, Tags], daos: [TaskDao, TagDao])
class AppDatabase extends _$AppDatabase {
  /// Will Instantiate or create database at the specified path
  AppDatabase()
      : super(FlutterQueryExecutor.inDatabaseFolder(
            path: 'database.sqlite', logStatements: true));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await into(tags).insert(
            TagsCompanion(
              name: const Value("General"),
              color: Value(material.Colors.blue.value),
            ),
            orReplace: true,
          );
          await into(tags).insert(
            TagsCompanion(
              name: const Value("Important"),
              color: Value(material.Colors.red.value),
            ),
            orReplace: true,
          );
        },
      );
}

/// This class holds table schema for [Tasks]
class Tasks extends Table {
  /// Task Id
  IntColumn get id => integer().autoIncrement()();

  /// Task name
  TextColumn get name => text().withLength(min: 1, max: 50)();

  /// Task completed status
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  /// Task due date
  DateTimeColumn get dueDate => dateTime().nullable()();

  /// Task tag
  TextColumn get tag =>
      text().nullable().customConstraint('NULL REFERENCES tags(name)')();
}

/// This class holds table schema for [Tags]
class Tags extends Table {
  /// Tag name. Has a minimum length of 1 and a maximum length of 20
  TextColumn get name => text().withLength(min: 1, max: 20)();

  /// Tag color
  IntColumn get color => integer()();

  /// Making name as the primary key of a tag requires names to be unique
  @override
  Set<Column> get primaryKey => {name};
}

/// This is a Data Access Object class, it defines different operations to be carried out on the Table
@UseDao(tables: [Tasks, Tags])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  /// Reference to our [AppDatabase] instance;
  final AppDatabase database;

  /// Tasks Data Access Object
  TaskDao(this.database) : super(database);

  /// Fetches all the tasks in the database
  Future<List<TaskWithTag>> getAllTasks() async {
    return (await (select(tasks)
              ..orderBy(
                ([
                  (t) => OrderingTerm(
                      expression: t.dueDate, mode: OrderingMode.asc),
                  (t) => OrderingTerm(expression: t.name),
                ]),
              ))
            .join(
      [
        leftOuterJoin(tags, tags.name.equalsExp(tasks.tag)),
      ],
    ).get())
        .map(
      (row) {
        return TaskWithTag(
          task: row.readTable(tasks),
          tag: row.readTable(tags),
        );
      },
    ).toList();
  }

  /// Streams all the tasks from the database and any changes made to them
  Stream<List<TaskWithTag>> watchAllTasks() {
    return (select(tasks)
          ..orderBy(
            ([
              (t) =>
                  OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc),
              (t) => OrderingTerm(expression: t.name),
            ]),
          ))
        .join(
          [
            leftOuterJoin(tags, tags.name.equalsExp(tasks.tag)),
          ],
        )
        .watch()
        .map(
          (rows) => rows.map(
            (row) {
              return TaskWithTag(
                task: row.readTable(tasks),
                tag: row.readTable(tags),
              );
            },
          ).toList(),
        );
  }

  /// Inserts a [Task] into the database
  Future<int> insertTask(Insertable<Task> task) => into(tasks).insert(task);

  /// Updates a [Task]
  Future<bool> updateTask(Insertable<Task> task) => update(tasks).replace(task);

  /// Deletes a [Task]
  Future<int> deleteTask(Insertable<Task> task) => delete(tasks).delete(task);
}

/// This is a Data Access Object class, it defines different operations to be carried out on the Table
@UseDao(tables: [Tags])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  /// Reference to our [AppDatabase] instance;
  final AppDatabase database;

  /// [Tags] Data Access Object
  TagDao(this.database) : super(database);

  /// Streams all [Tags] from the database and any changes made to them
  Stream<List<Tag>> watchAllTags() => select(tags).watch();

  /// Fetches all [Tags] from the database
  Future<List<Tag>> getAllTags() => select(tags).get();

  /// Fetches a particular [Tag] by name
  Future<Tag> getTag(String name) =>
      (select(tags)..where((t) => t.name.equals(name))).getSingle();

  /// Adds a new [Tag] to the database
  Future<int> insertTag(Insertable<Tag> tag) => into(tags).insert(tag);

  /// Updates a [Tag]
  Future<bool> updateTag(Insertable<Tag> tag) => update(tags).replace(tag);

  /// Deletes a [Tag]
  Future<int> deleteTag(Insertable<Tag> tag) => delete(tags).delete(tag);
}
