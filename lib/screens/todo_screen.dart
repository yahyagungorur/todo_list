// ignore_for_file: prefer_const_constructors, avoid_print, void_checks

import 'package:flutter/material.dart';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/screens/home_screen.dart';
import 'package:todo_list/services/category_service.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/services/todo_service.dart';

import '../helpers/notification_helper.dart';

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _todoTitleController = TextEditingController();
  final _todoDescriptionController = TextEditingController();
  final _todoDateController = TextEditingController();
  final _todoService = TodoService();
  DateTime _datetime = DateTime.now();
  TimeOfDay _timeOfDay = TimeOfDay(hour: 00, minute: 00);
  NotificationHelper notificationHelper = NotificationHelper();
  var _selectedValue;
  final formGlobalKey = GlobalKey<FormState>();

  final _categories = <DropdownMenuItem>[];
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  _selectedTodoDate(BuildContext context) async {
    var _pickedDate = await showDatePicker(
        context: context,
        initialDate: _datetime,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
    if (_pickedDate != null) {
      setState(() {
        _datetime = _pickedDate;
      });
      final _pickedTime =
          await showTimePicker(context: context, initialTime: _timeOfDay);
      if (_pickedTime != null) {
        setState(() {
          _timeOfDay = _pickedTime;
          _todoDateController.text = DateFormat('dd/MM/yyy - HH:mm').format(
              DateTime(_pickedDate.year, _pickedDate.month, _pickedDate.day,
                  _pickedTime.hour, _pickedTime.minute));
        });
      }
    }
  }

  _loadCategories() async {
    var _categoriesService = CategoryService();
    var categories = await _categoriesService.readCategories();
    categories.forEach((category) {
      setState(() {
        _categories.add(DropdownMenuItem(
            child: Text(category['name']), value: category['name']));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Todo'),
      ),
      body: Form(
        key: formGlobalKey,
        child: (Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                validator: (_todoTitleController) {
                  if (_todoTitleController!.isNotEmpty) {
                    return null;
                  } else {
                    return "Enter a valid Title";
                  }
                },
                controller: _todoTitleController,
                decoration: InputDecoration(
                    hintText: 'Write Todo Title', labelText: 'Title'),
              ),
              TextFormField(
                validator: (_todoDescriptionController) {
                  if (_todoDescriptionController!.isNotEmpty) {
                    return null;
                  } else {
                    return "Enter a valid description";
                  }
                },
                controller: _todoDescriptionController,
                decoration: InputDecoration(
                    hintText: 'Write Todo Description',
                    labelText: 'Description'),
              ),
              TextFormField(
                validator: (_todoDateController) {
                  if (_todoDateController!.isNotEmpty) {
                    return null;
                  } else {
                    return "Enter a valid date and time";
                  }
                },
                controller: _todoDateController,
                decoration: InputDecoration(
                    hintText: 'Pick Todo Date',
                    labelText: 'Date',
                    prefixIcon: InkWell(
                      onTap: () {
                        _selectedTodoDate(context);
                      },
                      child: Icon(Icons.calendar_today),
                    )),
              ),
              DropdownButtonFormField<dynamic>(
                value: _selectedValue,
                items: _categories,
                hint: Text('Category'),
                onChanged: (value) {
                  setState(() {
                    _selectedValue = value;
                  });
                },
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (formGlobalKey.currentState!.validate()) {
                      formGlobalKey.currentState!.save();
                      var todoObject = Todo();
                      todoObject.title = _todoTitleController.text;
                      todoObject.description = _todoDescriptionController.text;
                      todoObject.category = _selectedValue.toString();
                      todoObject.todoDate = _todoDateController.text;
                      todoObject.isDone = 0;
                      var result = await _todoService.saveTodo(todoObject);
                      if (result > 0) {
                        print(result);
                        todoObject.id = result;
                        await notificationHelper.showNotification(todoObject);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      }
                    }
                  },
                  child: Text('Save'))
            ],
          ),
        )),
      ),
    );
  }
}
