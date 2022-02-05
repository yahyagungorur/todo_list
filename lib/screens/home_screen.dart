// ignore_for_file: prefer_const_constructors, avoid_print, void_checks

import 'package:flutter/material.dart';
import 'package:todo_list/helpers/drawer_navigation.dart';
import 'package:todo_list/models/category.dart';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/screens/todo_screen.dart';
import 'package:todo_list/services/category_service.dart';
import 'package:todo_list/services/todo_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Todo> _todoList = <Todo>[];
  final _todoService = TodoService();
  final _categoryService = CategoryService();
  var val = -1;
  final _globalKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    getTodos();
  }

  _showSuccessSnackBar(message) {
    var _snackBar = SnackBar(
      content: message,
      duration: Duration(seconds: 1),
    );
    _globalKey.currentState!.showSnackBar(_snackBar);
  }

  _deleteFormDialog(BuildContext context, id) {
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
                    var result = await _todoService.deleteTodo(id);
                    if (result > 0) {
                      print(result);
                      Navigator.pop(context);
                      getTodos();
                      _showSuccessSnackBar(Text('Deleted'));
                    }
                  },
                  child: Text('Delete'))
            ],
            title: Text('Are you sure to delete this todo ?'),
          );
        });
  }

  getTodos() async {
    var todos = await _todoService.getAllTodos();
    setState(() {
      _todoList = todos;
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _globalKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Todo List'),
        ),
        body: _todoList.isEmpty
            ? Center(
                child: Text("Empty todo list"),
              )
            : ListView.builder(
                itemCount: _todoList.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      setState(() {
                        _deleteFormDialog(context, _todoList[index].id);
                      });
                    },
                    background: Container(
                      color: Colors.red,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      alignment: Alignment.centerRight,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                      child: Card(
                        elevation: 8.0,
                        child: ListTile(
                          leading: Radio<dynamic>(
                              value: 1,
                              groupValue: _todoList[index].isDone,
                              onChanged: (value) async {
                                setState(() {
                                  _todoList[index].isDone = value ?? 0;
                                });
                                var result = await _todoService
                                    .updateTodo(_todoList[index]);
                                if (result > 0 &&
                                    _todoList[index].isDone == 1) {
                                  _showSuccessSnackBar(Text('Done'));
                                }
                              },
                              toggleable: true,
                              activeColor: Colors.green),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                _todoList[index].title.toString(),
                                style: TextStyle(
                                    decoration: _todoList[index].isDone == 1
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none),
                              ),
                            ],
                          ),
                          subtitle:
                              Text(_todoList[index].description.toString()),
                          trailing: Text(_todoList[index].todoDate.toString()),
                          onTap: () {
                            _showFormDialog(context, _todoList[index]);
                          },
                        ),
                      ),
                    ),
                  );
                }),
        drawer: DrawerNavigation(),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              List<Category> _categoryList =
                  await _categoryService.getAllCategories();
              if (_categoryList.isNotEmpty) {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => TodoScreen()));
              } else {
                _showSuccessSnackBar(Text("Add a Category"));
              }
            },
            child: const Icon(Icons.add)),
      ),
    );
  }
}
