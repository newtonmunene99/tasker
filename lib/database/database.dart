import 'package:flutter/material.dart' as material;
import 'package:moor_flutter/moor_flutter.dart';
import 'package:tasker/models/taskwithtag.dart';

part 'database.g.dart';

@UseMoor(tables: [Tasks, Tags], daos: [TaskDao, TagDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(FlutterQueryExecutor.inDatabaseFolder(
            path: 'db.sqlite', logStatements: true));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await into(tags).insert(
            TagsCompanion(
              name: Value("General"),
              color: Value(material.Colors.blue.value),
            ),
            orReplace: true,
          );
          await into(tags).insert(
            TagsCompanion(
              name: Value("Important"),
              color: Value(material.Colors.red.value),
            ),
            orReplace: true,
          );
        },
      );
}

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  BoolColumn get completed => boolean().withDefault(Constant(false))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get tag =>
      text().nullable().customConstraint('NULL REFERENCES tags(name)')();
}

class Tags extends Table {
  TextColumn get name => text().withLength(min: 1, max: 20)();
  IntColumn get color => integer()();

  // Making name as the primary key of a tag requires names to be unique
  @override
  Set<Column> get primaryKey => {name};
}

@UseDao(tables: [Tasks, Tags])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  final AppDatabase db;

  TaskDao(this.db) : super(db);

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

  Future<int> insertTask(Insertable<Task> task) => into(tasks).insert(task);
  Future<bool> updateTask(Insertable<Task> task) => update(tasks).replace(task);
  Future<int> deleteTask(Insertable<Task> task) => delete(tasks).delete(task);
}

@UseDao(tables: [Tags])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  final AppDatabase db;

  TagDao(this.db) : super(db);

  Stream<List<Tag>> watchAllTags() => select(tags).watch();
  Future<List<Tag>> getAllTags() => select(tags).get();
  Future<Tag> getTag(String name) =>
      (select(tags)..where((t) => t.name.equals(name))).getSingle();
  Future<int> insertTag(Insertable<Tag> tag) => into(tags).insert(tag);
  Future<bool> updateTag(Insertable<Tag> tag) => update(tags).replace(tag);
  Future<int> deleteTag(Insertable<Tag> tag) => delete(tags).delete(tag);
}
