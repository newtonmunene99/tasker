import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import './tags.dart';
import './tasks.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DateTime _today = DateTime.now();
  final PageController _controller =
      PageController(initialPage: 0, viewportFraction: 1.0);
  int _currentIndex = 0;
  final List<Map<String, dynamic>> _pages = [
    {
      "name": "Tasks",
      "widget": TasksPage(),
      "icon": FontAwesome.tasks,
    },
    {
      "name": "Tags",
      "widget": TagsPage(),
      "icon": AntDesign.tagso,
    },
  ];
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

  void _navigateTo(int index) {
    setState(() {
      _currentIndex = index;
    });
    _controller.animateToPage(
      index,
      curve: Curves.linear,
      duration: const Duration(milliseconds: 200),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              ..._pages
                  .asMap()
                  .map(
                    (i, page) => MapEntry(
                      i,
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          decoration: BoxDecoration(
                            color: _currentIndex == i
                                ? Colors.grey[200]
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: ListTile(
                            // leading: Icon(
                            //   page["icon"],
                            //   color: Colors.black54,
                            // ),
                            title: Text(
                              page["name"] as String,
                              style: TextStyle(
                                color: _currentIndex == i
                                    ? Theme.of(context).accentColor
                                    : Colors.black54,
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            trailing: _currentIndex == i
                                ? Icon(
                                    Icons.arrow_forward_ios,
                                    color: Theme.of(context).accentColor,
                                  )
                                : null,
                            onTap: () {
                              _navigateTo(i);
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                  .values
                  .toList(),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: ListTile(
                    // leading: Icon(
                    //   Icons.exit_to_app,
                    //   color: Colors.black54,
                    // ),
                    title: Text(
                      "About",
                      style: TextStyle(
                        color: Colors.black54,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onTap: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          "${_currentIndex == 0 ? "Tasker" : _pages[_currentIndex]["name"]}",
          style: const TextStyle(
            fontSize: 40,
            letterSpacing: 1.0,
          ),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Feather.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: Container(
            height: 100.0,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: PageView(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            ..._pages
                .asMap()
                .map(
                  (i, page) =>
                      MapEntry<int, Widget>(i, page["widget"] as Widget),
                )
                .values
                .toList()
          ],
        ),
      ),
    );
  }
}
