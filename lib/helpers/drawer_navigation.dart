// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:todo_list/models/user.dart';
import 'package:todo_list/screens/cases_screen.dart';
import 'package:todo_list/screens/categories_screen.dart';
import 'package:todo_list/screens/home_screen.dart';
import 'package:todo_list/services/case_service.dart';
import 'package:todo_list/services/user_service.dart';
import 'package:email_validator/email_validator.dart';

class DrawerNavigation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DrawerNavigationState();
}

class _DrawerNavigationState extends State<DrawerNavigation> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final formGlobalKey = GlobalKey<FormState>();
  User logedUser = User();
  List<User> _userList = <User>[];
  final _userService = UserService();
  @override
  void initState() {
    super.initState();
    logedUser.username = "AccountName";
    logedUser.email = "AccountEMail@mail.com";
    logedUser.password = "0000";
    getUser();
  }

  getUser() async {
    _userList = await _userService.getUser();
    if (_userList.isNotEmpty) {
      setState(() {
        logedUser = _userList[0];
      });
    }
  }

  _showFormDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _passwordController.clear();
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    if (formGlobalKey.currentState!.validate()) {
                      formGlobalKey.currentState!.save();
                      if (logedUser.password == _passwordController.text) {
                        print("loged");
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CasesScreen()));
                        _passwordController.clear();
                      }
                    }
                  },
                  child: Text('Login'))
            ],
            title: Text('Sign In Form'),
            content: SingleChildScrollView(
                child: Form(
              key: formGlobalKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    obscureText: true,
                    validator: (_passwordController) {
                      if (_passwordController!.isNotEmpty &&
                          logedUser.password == _passwordController) {
                        return null;
                      } else {
                        return "Enter a valid or right password";
                      }
                    },
                    controller: _passwordController,
                    decoration: InputDecoration(
                        hintText: 'Enter Password', labelText: 'Password'),
                  ),
                ],
              ),
            )),
          );
        });
  }

  _saveFormDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _usernameController.clear();
                    _emailController.clear();
                    _passwordController.clear();
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    logedUser.username = _usernameController.text;
                    logedUser.email = _emailController.text;
                    logedUser.password = _passwordController.text;
                    var result = await _userService.saveUser(logedUser);
                    if (result > 0) {
                      print(result);
                      Navigator.pop(context);
                      getUser();
                      _usernameController.clear();
                      _emailController.clear();
                      _passwordController.clear();
                    }
                  },
                  child: Text('Save'))
            ],
            title: Text('Sing Up Form'),
            content: SingleChildScrollView(
                child: Form(
              key: formGlobalKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    validator: (_usernameController) {
                      if (_usernameController!.isNotEmpty) {
                        return null;
                      } else {
                        return "Enter a valid username";
                      }
                    },
                    controller: _usernameController,
                    decoration: InputDecoration(
                        hintText: 'Enter username', labelText: 'Username'),
                  ),
                  TextFormField(
                    validator: (_emailController) {
                      if (_emailController!.isNotEmpty &&
                          EmailValidator.validate(_emailController)) {
                        return null;
                      } else {
                        return "Enter a valid email";
                      }
                    },
                    controller: _emailController,
                    decoration: InputDecoration(
                        hintText: 'Enter Email', labelText: 'Email'),
                  ),
                  TextFormField(
                    obscureText: true,
                    validator: (_passwordController) {
                      if (_passwordController!.isNotEmpty) {
                        return null;
                      } else {
                        return "Enter a valid or right password";
                      }
                    },
                    controller: _passwordController,
                    decoration: InputDecoration(
                        hintText: 'Enter Password', labelText: 'Password'),
                  ),
                ],
              ),
            )),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.amber,
                radius: 50,
              ),
              accountName: Text(logedUser.username!),
              accountEmail: Text(logedUser.email!),
            ),
            ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HomeScreen()))),
            ListTile(
                leading: Icon(Icons.view_list),
                title: Text('Categories'),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CategoriesScreen()))),
            ListTile(
                leading: Icon(Icons.cases_outlined),
                title: Text('Case'),
                onTap: () {
                  if (_userList.isNotEmpty) {
                    _showFormDialog(context);
                  } else {
                    _saveFormDialog(context);
                  }
                }),
          ],
        ),
      ),
    );
  }
}
