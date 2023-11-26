import 'package:flutter/material.dart';
import 'package:simulator/screens/home_screen.dart';
import 'package:simulator/utils/data_load.dart';
// import 'package:simulator/utils/menu_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DataLoader().loadAirportsFromJson();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F16 Simulator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: _themeMode,
      // home: CustomMenu(
      //   themeMode: _themeMode,
      //   onThemeChanged: _changeTheme,
      // ),
      home: HomeScreen(),
    );
  }
}
