import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './services/router.dart';
import './database/database.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(
          value: AppDatabase(),
        ),
      ],
      child: MaterialApp(
        title: 'Tasker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
        ),
        onGenerateRoute: Router.generateRoute,
        initialRoute: "/",
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
