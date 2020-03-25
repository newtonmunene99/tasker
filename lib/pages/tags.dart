import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:random_color/random_color.dart';
import 'package:tasker/database/database.dart';
import 'package:tasker/widgets/bottom_sheet.dart';
import 'package:moor_flutter/moor_flutter.dart' as moor;

TextEditingController _tagFieldController;
Color _tagColor;
RandomColor _randomColor = RandomColor();

class TagsPage extends StatefulWidget {
  @override
  _TagsPageState createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {
  @override
  void initState() {
    super.initState();
    _tagFieldController = TextEditingController();
    _tagColor = _randomColor.randomColor();
  }

  @override
  Widget build(BuildContext context) {
    final AppDatabase _db = Provider.of<AppDatabase>(context);
    return Scaffold(
      body: StreamBuilder<List<Tag>>(
        stream: _db.tagDao.watchAllTags(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isNotEmpty) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 1.0,
                  mainAxisSpacing: 1.0,
                ),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: GridTile(
                        header: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: Text(
                              snapshot.data[index].name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 2.0,
                                  color: Color(
                                    snapshot.data[index].color,
                                  ),
                                )),
                            child: Center(
                              child: Icon(
                                FontAwesome.tag,
                                color: Color(snapshot.data[index].color),
                              ),
                            ),
                          ),
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
        onPressed: () {
          // Navigator.pushNamed(context, "/task/new");
          _addTag(context, _db);
        },
        child: Icon(Feather.plus),
      ),
    );
  }

  void _addTag(BuildContext context, AppDatabase db) {
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
            child: TagAdder(
              context: context,
              db: db,
            ),
          ),
        );
      },
    );
  }
}

class TagAdder extends StatefulWidget {
  final BuildContext context;
  final AppDatabase db;

  TagAdder({@required this.context, @required this.db});

  @override
  _TagAdderState createState() => _TagAdderState();
}

class _TagAdderState extends State<TagAdder> {
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
            controller: _tagFieldController,
            autofocus: true,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: "Tag",
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
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ButtonBar(
                mainAxisSize: MainAxisSize.min,
                alignment: MainAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                        color: _tagColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child: SingleChildScrollView(
                              child: MaterialPicker(
                                pickerColor: _tagColor,
                                onColorChanged: (color) {
                                  setState(() {
                                    _tagColor = color;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      FontAwesome.tag,
                      color: _tagColor,
                    ),
                    onPressed: null,
                  )
                ],
              ),
              ButtonBar(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 70,
                    child: FlatButton(
                      onPressed: () {
                        _tagFieldController.clear();
                        Navigator.pop(context);
                        setState(() {
                          _tagColor = _randomColor.randomColor();
                        });
                      },
                      child: const Text("Cancel"),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: FlatButton(
                      onPressed: () async {
                        if (_tagFieldController.value.text.isNotEmpty) {
                          try {
                            await widget.db.tagDao.insertTag(
                              TagsCompanion(
                                name:
                                    moor.Value(_tagFieldController.value.text),
                                color: moor.Value(_tagColor.value),
                              ),
                            );
                            Navigator.pop(context);
                            _tagFieldController.clear();

                            setState(() {
                              _tagColor = _randomColor.randomColor();
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
