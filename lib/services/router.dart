import 'package:flutter/material.dart';
import 'package:tasker/pages/add_task.dart';
import 'package:tasker/pages/home.dart';
import 'package:tasker/pages/splash.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => SplashPage());

      case '/home':
        return MaterialPageRoute(builder: (_) => HomePage());

      case '/task/new':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              AddTaskPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(0.0, 1.0);
            var end = Offset.zero;
            var curve = Curves.bounceInOut;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                'No route defined for ${settings.name}',
              ),
            ),
          ),
        );
    }
  }
}
