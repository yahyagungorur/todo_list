// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:todo_list/screens/categories_screen.dart';
import 'package:todo_list/screens/home_screen.dart';

class DrawerNavigation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DrawerNavigationState();
}

class _DrawerNavigationState extends State<DrawerNavigation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Drawer(
        child: ListView(
          children: <Widget>[
            const UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.amber,
                radius: 50,
              ),
              accountName: Text('Account Name'),
              accountEmail: Text('Account EMail'),
              decoration: BoxDecoration(color: Colors.blue),
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
          ],
        ),
      ),
    );
  }
}
