// ignore_for_file: prefer_const_constructors, avoid_print, void_checks

import 'package:flutter/material.dart';
import 'package:todo_list/models/case.dart';
import 'package:todo_list/models/category.dart';
import 'package:todo_list/screens/home_screen.dart';
import 'package:todo_list/services/case_service.dart';
import 'package:todo_list/services/category_service.dart';

class CasesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CasesScreenState();
}

class _CasesScreenState extends State<CasesScreen> {
  final _caseTitleController = TextEditingController();
  final _caseDescriptionController = TextEditingController();
  final _editCaseTitleController = TextEditingController();
  final _editCaseDescriptionController = TextEditingController();

  Case _case = Case();
  final _caseService = CaseService();
  var _cas;
  int val = -1;
  final formGlobalKey = GlobalKey<FormState>();

  List<Case> _caseList = <Case>[];
  @override
  void initState() {
    super.initState();
    getCases();
  }

  final _globalKey = GlobalKey<ScaffoldMessengerState>();

  getCases() async {
    var caseList = await _caseService.getCases();
    setState(() {
      _caseList = caseList;
    });
  }

  _editCase(BuildContext context, caseId) async {
    _cas = await _caseService.readCaseById(caseId);
    setState(() {
      _editCaseTitleController.text = _cas[0]['title'] ?? 'No title';
      _editCaseDescriptionController.text =
          _cas[0]['description'] ?? 'No description';
    });
    _editFormDialog(context);
  }

  _deleteCase(BuildContext context, caseId) async {
    _cas = await _caseService.readCaseById(caseId);
    setState(() {
      _editCaseTitleController.text = _cas[0]['title'] ?? 'No title';
      _editCaseDescriptionController.text =
          _cas[0]['description'] ?? 'No description';
    });
    _deleteFormDialog(context);
  }

  _showFormDialog(BuildContext context) {
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
                    if (formGlobalKey.currentState!.validate()) {
                      formGlobalKey.currentState!.save();
                      _case.title = _caseTitleController.text;
                      _case.description = _caseDescriptionController.text;
                      var result = await _caseService.saveCase(_case);
                      if (result > 0) {
                        print(result);
                        Navigator.pop(context);
                        _caseTitleController.clear();
                        _caseDescriptionController.clear();
                        getCases();
                      }
                    }
                  },
                  child: Text('Save'))
            ],
            title: Text('Cases Form'),
            content: SingleChildScrollView(
                child: Form(
              key: formGlobalKey,
              child: Column(
                // ignore: prefer_const_literals_to_create_immutables
                children: <Widget>[
                  TextFormField(
                    validator: (_caseTitleController) {
                      if (_caseTitleController!.isNotEmpty) {
                        return null;
                      } else {
                        return "Enter a valid name";
                      }
                    },
                    controller: _caseTitleController,
                    decoration: InputDecoration(
                        hintText: 'Write Title', labelText: 'Title'),
                  ),
                  TextFormField(
                    controller: _caseDescriptionController,
                    decoration: InputDecoration(
                        hintText: 'Write Description',
                        labelText: 'Description'),
                  ),
                ],
              ),
            )),
          );
        });
  }

  _editFormDialog(BuildContext context) {
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
                    _case.id = _cas[0]['id'];
                    _case.title = _editCaseTitleController.text;
                    _case.description = _editCaseDescriptionController.text;
                    var result = await _caseService.updateCase(_case);
                    if (result > 0) {
                      print(result);
                      Navigator.pop(context);
                      getCases();
                      _editCaseTitleController.clear();
                      _editCaseDescriptionController.clear();
                      _showSuccessSnackBar(Text('Updated'));
                    }
                  },
                  child: Text('Update'))
            ],
            title: Text('Edit Cases Form'),
            content: SingleChildScrollView(
              child: Column(
                // ignore: prefer_const_literals_to_create_immutables
                children: <Widget>[
                  TextField(
                    controller: _editCaseTitleController,
                    decoration: InputDecoration(
                        hintText: 'Write Title', labelText: 'Title'),
                  ),
                  TextField(
                    controller: _editCaseDescriptionController,
                    decoration: InputDecoration(
                        hintText: 'Write Description',
                        labelText: 'Description'),
                  ),
                ],
              ),
            ),
          );
        });
  }

  _deleteFormDialog(BuildContext context) {
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
                    _case.id = _cas[0]['id'];
                    var result = await _caseService.deleteCase(_case.id);
                    if (result > 0) {
                      print(result);
                      Navigator.pop(context);
                      getCases();
                      _showSuccessSnackBar(Text('Deleted'));
                    }
                  },
                  child: Text('Delete'))
            ],
            title: Text('Are you sure to delete this case ?'),
          );
        });
  }

  _showSuccessSnackBar(message) {
    var _snackBar = SnackBar(
      content: message,
      duration: Duration(seconds: 1),
    );
    _globalKey.currentState!.showSnackBar(_snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => HomeScreen()));
        return true;
      },
      child: ScaffoldMessenger(
          key: _globalKey,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HomeScreen())),
                icon: const Icon(
                  Icons.arrow_back,
                ),
              ),
              title: const Text('Cases'),
            ),
            body: _caseList.isEmpty
                ? Center(
                    child: Text("Empty case list"),
                  )
                : ListView.builder(
                    itemCount: _caseList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding:
                            EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                        child: Card(
                          elevation: 8.0,
                          child: ListTile(
                            leading: IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  return _editCase(
                                      context, _caseList[index].id);
                                }),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(_caseList[index].title.toString()),
                                Text(_caseList[index].description.toString()),
                                IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      return _deleteCase(
                                          context, _caseList[index].id);
                                    })
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showFormDialog(context),
              child: const Icon(Icons.add),
            ),
          )),
    );
  }
}
