// ignore_for_file: prefer_const_constructors, avoid_print, void_checks

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/screens/home_screen.dart';
import 'package:todo_list/services/category_service.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/services/todo_service.dart';
import '../api/speech_api.dart';
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
  bool hasNotification = false, hasSound = false, isListening = false;
  double _value = 0;

  final _categories = <DropdownMenuItem>[];
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    super.dispose();
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => HomeScreen()));
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create Todo'),
        ),
        body: Form(
          key: formGlobalKey,
          child: (Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
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
                    controller: _todoDescriptionController,
                    decoration: InputDecoration(
                        hintText: 'Write Todo Description',
                        labelText: 'Description'),
                  ),
                  TextFormField(
                    validator: (_todoDateController) {
                      try {
                        DateFormat('dd/MM/yyy - HH:mm')
                            .parse(_todoDateController!);
                        return null;
                      } catch (e) {
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
                  CheckboxListTile(
                    secondary: const Icon(Icons.alarm),
                    title: const Text(
                        ' Do you want reminder notification before your todo?'),
                    value: hasNotification,
                    onChanged: (value) {
                      setState(() {
                        hasNotification = value!;
                      });
                    },
                  ),
                  hasNotification
                      ? Slider(
                          min: 0.0,
                          max: 60.0,
                          value: _value,
                          divisions: 12,
                          label: '${_value.round()} mins',
                          onChanged: (value) {
                            setState(() {
                              _value = value;
                            });
                          },
                        )
                      : SizedBox(),
                  CheckboxListTile(
                    secondary: const Icon(Icons.mic),
                    title:
                        const Text(' Do you want record with voice your todo?'),
                    value: hasSound,
                    onChanged: (value) {
                      setState(() {
                        hasSound = value!;
                      });
                    },
                  ),
                  hasSound
                      ? AvatarGlow(
                          animate: isListening,
                          endRadius: 75,
                          glowColor: Theme.of(context).primaryColor,
                          child: FloatingActionButton(
                            child: Icon(
                              isListening ? Icons.mic : Icons.mic_none,
                              size: 36,
                            ),
                            onPressed: toggleRecording,
                          ),
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (formGlobalKey.currentState!.validate()) {
                          formGlobalKey.currentState!.save();
                          var todoObject = Todo();
                          todoObject.title = _todoTitleController.text;
                          todoObject.description =
                              _todoDescriptionController.text;
                          todoObject.category = _selectedValue.toString();
                          todoObject.todoDate = _todoDateController.text;
                          todoObject.isDone = 0;
                          todoObject.notify = _value.toInt();
                          var result = await _todoService.saveTodo(todoObject);
                          if (result > 0) {
                            print(result);
                            todoObject.id = result;
                            if (DateFormat('dd/MM/yyy - HH:mm')
                                    .parse(_todoDateController.text)
                                    .difference(DateTime.now().add(Duration(
                                        minutes: todoObject.notify!))) >
                                Duration(seconds: 0)) {
                              await notificationHelper
                                  .showNotification(todoObject);
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()),
                            );
                          }
                        }
                      },
                      child: Text('Save'))
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }

  Future toggleRecording() => SpeechApi.toggleRecording(
        onResult: ((text) => setState(() => _todoTitleController.text = text)),
        onListening: (isListening) =>
            setState(() => this.isListening = isListening),
      );
}
