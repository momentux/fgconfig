import 'package:flutter/material.dart';
import 'package:simulator/screens/route_generator.dart';
import 'package:simulator/screens/target_generator.dart';
import 'package:simulator/screens/launch_manager.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Momentux FG Simulator'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Launch Process'),
              Tab(text: 'Scenario Planner'),
              Tab(text: 'Route Manager'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(child: LaunchManagementScreen()),
            SingleChildScrollView(child: ScenarioManagementScreen()),
            SingleChildScrollView(child: RouteManagementScreen()),
          ],
        ),
      ),
    );
  }
}
