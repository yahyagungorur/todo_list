// ignore_for_file: prefer_const_constructors, avoid_print, void_checks

import 'package:flutter/material.dart';
import 'package:todo_list/models/category.dart';
import 'package:todo_list/screens/home_screen.dart';
import 'package:todo_list/services/category_service.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _categoryNameController = TextEditingController();
  final _categoryDescriptionController = TextEditingController();
  final _editCategoryNameController = TextEditingController();
  final _editCategoryDescriptionController = TextEditingController();

  final _category = Category();
  final _categoryService = CategoryService();
  var category;
  int val = -1;
  final formGlobalKey = GlobalKey<FormState>();

  List<Category> _categoryList = <Category>[];
  @override
  void initState() {
    super.initState();
    getCategories();
  }

  final _globalKey = GlobalKey<ScaffoldMessengerState>();

  getCategories() async {
    var catList = await _categoryService.getAllCategories();
    setState(() {
      _categoryList = catList;
    });
  }

  _editCategory(BuildContext context, categoryId) async {
    category = await _categoryService.readCategoryById(categoryId);
    setState(() {
      _editCategoryNameController.text = category[0]['name'] ?? 'No Name';
      _editCategoryDescriptionController.text =
          category[0]['description'] ?? 'No description';
    });
    _editFormDialog(context);
  }

  _deleteCategory(BuildContext context, categoryId) async {
    category = await _categoryService.readCategoryById(categoryId);
    setState(() {
      _editCategoryNameController.text = category[0]['name'] ?? 'No Name';
      _editCategoryDescriptionController.text =
          category[0]['description'] ?? 'No description';
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
                      _category.name = _categoryNameController.text;
                      _category.description =
                          _categoryDescriptionController.text;
                      var result =
                          await _categoryService.saveCategory(_category);
                      if (result > 0) {
                        print(result);
                        Navigator.pop(context);
                        _categoryNameController.clear();
                        _categoryDescriptionController.clear();
                        getCategories();
                      }
                    }
                  },
                  child: Text('Save'))
            ],
            title: Text('Categories Form'),
            content: SingleChildScrollView(
                child: Form(
              key: formGlobalKey,
              child: Column(
                // ignore: prefer_const_literals_to_create_immutables
                children: <Widget>[
                  TextFormField(
                    validator: (_categoryNameController) {
                      if (_categoryNameController!.isNotEmpty) {
                        return null;
                      } else {
                        return "Enter a valid name";
                      }
                    },
                    controller: _categoryNameController,
                    decoration: InputDecoration(
                        hintText: 'Write Categories', labelText: 'Category'),
                  ),
                  TextFormField(
                    validator: (_categoryDescriptionController) {
                      if (_categoryDescriptionController!.isNotEmpty) {
                        return null;
                      } else {
                        return "Enter a valid description";
                      }
                    },
                    controller: _categoryDescriptionController,
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
                    _category.id = category[0]['id'];
                    _category.name = _editCategoryNameController.text;
                    _category.description =
                        _editCategoryDescriptionController.text;
                    var result =
                        await _categoryService.updateCategory(_category);
                    if (result > 0) {
                      print(result);
                      Navigator.pop(context);
                      getCategories();
                      _editCategoryNameController.clear();
                      _editCategoryDescriptionController.clear();
                      _showSuccessSnackBar(Text('Updated'));
                    }
                  },
                  child: Text('Update'))
            ],
            title: Text('Edit Categories Form'),
            content: SingleChildScrollView(
              child: Column(
                // ignore: prefer_const_literals_to_create_immutables
                children: <Widget>[
                  TextField(
                    controller: _editCategoryNameController,
                    decoration: InputDecoration(
                        hintText: 'Write Categories', labelText: 'Category'),
                  ),
                  TextField(
                    controller: _editCategoryDescriptionController,
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
                    _category.id = category[0]['id'];
                    var result =
                        await _categoryService.deleteCategory(_category.id);
                    if (result > 0) {
                      print(result);
                      Navigator.pop(context);
                      getCategories();
                      _showSuccessSnackBar(Text('Deleted'));
                    }
                  },
                  child: Text('Delete'))
            ],
            title: Text('Are you sure to delete this category ?'),
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
    return ScaffoldMessenger(
        key: _globalKey,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => HomeScreen())),
              icon: const Icon(
                Icons.arrow_back,
              ),
            ),
            title: const Text('Categories'),
          ),
          body: _categoryList.isEmpty
              ? Center(
                  child: Text("Empty categories list"),
                )
              : ListView.builder(
                  itemCount: _categoryList.length,
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
                                return _editCategory(
                                    context, _categoryList[index].id);
                              }),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(_categoryList[index].name.toString()),
                              IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    return _deleteCategory(
                                        context, _categoryList[index].id);
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
        ));
  }
}
