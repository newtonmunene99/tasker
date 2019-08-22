import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './services/router.dart';
import './database/database.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  kiwi.Container _container = kiwi.Container();
  AppDatabase _appDatabase = AppDatabase();

  @override
  void initState() {
    _container.registerSingleton((c) => _appDatabase);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(
          value: _appDatabase,
        ),
      ],
      child: MaterialApp(
        title: 'Tasker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          accentColor: Colors.lightBlue,
          brightness: Brightness.light,
        ),
        onGenerateRoute: Router.generateRoute,
        initialRoute: "/",
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
