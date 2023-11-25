import 'package:flutter/material.dart';
import 'package:simulator/screens/target_scenario.dart';
import 'package:simulator/screens/route_manager.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Momentux FG Simulator'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Scenario Planner'),
            Tab(text: 'Route Manager'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Content for Tab 1
          SingleChildScrollView(
            child: const ScenarioManagementScreen(),
          ),

          // Content for Tab 2
          SingleChildScrollView(
            child: const RouteManagementScreen(),
          ),

        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
