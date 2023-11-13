import 'package:flutter/material.dart';
import 'package:simulator/screens/target_scenario.dart';
import 'package:simulator/utils/app_sytels.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
        child: Column(children: [
          const ScenarioManagementScreen(),
          Row(
            children: [
              _mainButton(() => null, 'Launch'),
              Row(children: [_actionButton(() => null, Icons.folder)])
            ],
            
          )
        ]),
      ),
    );
  }

  ElevatedButton _mainButton(Function()? onPressed, String text) {
    return ElevatedButton(
        onPressed: onPressed, style: AppTheme.buttonStyle(), child: Text(text));
  }

  IconButton _actionButton(Function()? onPressed, IconData icon) {
    return IconButton(
      onPressed: onPressed,
      splashRadius: 20,
      splashColor: AppTheme.accent,
      icon: Icon(
        icon,
        color: AppTheme.meduim,
      ),
    );
  }
}
