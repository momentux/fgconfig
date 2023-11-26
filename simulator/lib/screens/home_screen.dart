import 'package:flutter/material.dart';
import 'package:simulator/screens/route_manager.dart';
import 'package:simulator/screens/target_generator.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Momentux FG Simulator'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Scenario Planner'),
              Tab(text: 'Route Manager'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(child: ScenarioManagementScreen()),
            SingleChildScrollView(child: RouteManagementScreen()),
          ],
        ),
      ),
    );
  }
}
