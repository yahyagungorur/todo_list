// ignore_for_file: prefer_const_constructors, avoid_print, void_checks

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_list/helpers/drawer_navigation.dart';
import 'package:todo_list/models/category.dart';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/providers/theme_provider.dart';
import 'package:todo_list/screens/todo_screen.dart';
import 'package:todo_list/services/category_service.dart';
import 'package:todo_list/services/todo_service.dart';
import '../helpers/notification_helper.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NotificationHelper notificationHelper = NotificationHelper();
  List<Todo> _todoList = <Todo>[];
  List<Todo> _todoListCategory = <Todo>[];
  final _todoService = TodoService();
  final _categoryService = CategoryService();
  var val = -1;
  final _globalKey = GlobalKey<ScaffoldMessengerState>();
  List<Category> _categoryList = <Category>[];
  bool checkedValue = false;
  bool toogle = false;
  DateTime pre_backpress = DateTime.now();

  @override
  void initState() {
    super.initState();
    getTodos();
    getCategories();
    notificationHelper.setOnNotificationClick(onNotificationClick);
  }

  onNotificationClick(String payload) async {
    print('onNotificationClick, Payload $payload');
    Todo todo = await _todoService.readTodoById(payload);
    _showFormDialog(context, todo);
  }

  getCategories() async {
    List<Category> catList = await _categoryService.getAllCategories();
    if (catList.isNotEmpty) {
      setState(() {
        Category cat = Category();
        cat.name = "All";
        cat.description = "All";
        _categoryList.add(cat);
        _categoryList.addAll(catList);
      });
    }
  }

  _showSuccessSnackBar(String message, todo) {
    var _snackBar;
    if (todo != null) {
      _snackBar = SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () async {
            var result = await _todoService.saveTodo(todo);
            print(result);
            setState(() {
              getTodos();
            });
          },
        ),
      );
    } else {
      _snackBar =
          SnackBar(content: Text(message), duration: Duration(seconds: 1));
    }
    _globalKey.currentState!.showSnackBar(_snackBar);
  }

  _deleteFormDialog(BuildContext context, Todo todo) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    var result = await _todoService.deleteTodo(todo.id);
                    if (result > 0) {
                      print(result);
                      Navigator.pop(context);
                      getTodos();
                      _showSuccessSnackBar("Deleted", todo);
                      await notificationHelper.cancelNotification(todo.id);
                    }
                  },
                  child: Text('Delete'))
            ],
            title: Text('Are you sure to delete this todo ?'),
          );
        });
  }

  getTodosByCategory(categoryName) {
    setState(() {
      if (categoryName != "All") {
        _todoList =
            _todoListCategory.where((x) => x.category == categoryName).toList();
      } else {
        _todoList = _todoListCategory;
      }
    });
  }

  getTodos() async {
    var todos = await _todoService.getAllTodos();
    setState(() {
      _todoList = todos;
      _todoListCategory = todos;
    });
  }

  _showFormDialog(BuildContext context, Todo todo) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Todo Detail'),
                  CloseButton(
                      color: Colors.grey,
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ]),
            content: SingleChildScrollView(
              child: Column(
                // ignore: prefer_const_literals_to_create_immutables
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Title:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(todo.title.toString()),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Description:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(todo.description.toString()),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Date:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(todo.todoDate.toString()),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Category:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(todo.category.toString()),
                ],
              ),
            ),
          );
        });
  }

  Future<bool> _onBackPressed() async {
    final timegap = DateTime.now().difference(pre_backpress);
    final cantExit = timegap >= Duration(seconds: 1);
    pre_backpress = DateTime.now();
    if (cantExit) {
      _showSuccessSnackBar("Press again Back Button exit", null);
      return false;
    } else {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: ScaffoldMessenger(
        key: _globalKey,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Todo List'),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Ink(
                    width: 48.0,
                    height: 48.0,
                    decoration: ShapeDecoration(
                      shape: const CircleBorder(
                          side: BorderSide(color: Colors.transparent)),
                    ),
                    child: IconButton(
                        padding: EdgeInsets.zero,
                        splashRadius: 24.0,
                        iconSize: 24.0,
                        icon: themeProvider.isDarkMode
                            ? Icon(Icons.wb_sunny_rounded)
                            : Icon(Icons
                                .nightlight_round_outlined), //BedTime -- wbSunny
                        onPressed: () {
                          final provider = Provider.of<ThemeProvider>(context,
                              listen: false);
                          provider.toogleTheme(themeProvider.isDarkMode);
                        }),
                  ),
                ],
              )
            ],
          ),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _categoryList.isEmpty
                  ? Center(
                      child: SizedBox(),
                    )
                  : SizedBox(
                      height: 40,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: _categoryList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                              padding: EdgeInsets.only(
                                  top: 8.0, left: 8.0, right: 8.0, bottom: 8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                onPressed: () {
                                  getTodosByCategory(_categoryList[index].name);
                                },
                                child:
                                    Text(_categoryList[index].name.toString()),
                              ));
                        },
                      ),
                    ),
              _todoList.isEmpty
                  ? Center(
                      child: Text("Empty todo list"),
                    )
                  : Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _todoList.length,
                          itemBuilder: (context, index) {
                            return Dismissible(
                              key: UniqueKey(),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) {
                                setState(() {
                                  _deleteFormDialog(context, _todoList[index]);
                                });
                              },
                              background: Container(
                                color: Colors.red,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 8.0, left: 16.0, right: 16.0),
                                child: Card(
                                  elevation: 8.0,
                                  child: ListTile(
                                    leading: Radio<dynamic>(
                                        value: 1,
                                        groupValue: _todoList[index].isDone,
                                        onChanged: (value) async {
                                          setState(() {
                                            _todoList[index].isDone =
                                                value ?? 0;
                                          });
                                          var result = await _todoService
                                              .updateTodo(_todoList[index]);
                                          if (result > 0 &&
                                              _todoList[index].isDone == 1) {
                                            _showSuccessSnackBar("Done", null);
                                            await notificationHelper
                                                .cancelNotification(
                                                    _todoList[index].id);
                                          }
                                        },
                                        toggleable: true,
                                        activeColor: Colors.green),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          _todoList[index].title.toString(),
                                          style: TextStyle(
                                              decoration:
                                                  _todoList[index].isDone == 1
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : TextDecoration.none),
                                        ),
                                      ],
                                    ),
                                    subtitle: Text(_todoList[index]
                                        .description
                                        .toString()),
                                    isThreeLine: true,
                                    trailing: Text(
                                        _todoList[index].todoDate.toString()),
                                    onTap: () {
                                      _showFormDialog(
                                          context, _todoList[index]);
                                    },
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
            ],
          ),
          drawer: DrawerNavigation(),
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => TodoScreen()));
              },
              child: const Icon(Icons.add)),
        ),
      ),
    );
  }
}
