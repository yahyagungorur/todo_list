import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/screens/home_screen.dart';
import '../providers/theme_provider.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: ((context) => ThemeProvider()),
        builder: ((context, _) {
          final themeProvider =
              Provider.of<ThemeProvider>(context, listen: true);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: MyThemes.lightTheme,
            darkTheme: MyThemes.darkTheme, // debug bannerı kaldırır
            home: HomeScreen(),
          );
        }),
      );
}
