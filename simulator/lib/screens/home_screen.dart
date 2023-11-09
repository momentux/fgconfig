import 'package:flutter/material.dart';
import 'package:simulator/screens/target_scenario.dart';

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
        title: Text('My Home Screen'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Tab 1'),
            Tab(text: 'Tab 2'),
            Tab(text: 'Tab 3'),
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
            child: Container(
              color: Colors.green,
              child: Center(child: Text('Tab 2 Content')),
            ),
          ),

          // Content for Tab 3
          SingleChildScrollView(
            child: Container(
              color: Colors.blue,
              child: Center(child: Text('Tab 3 Content')),
            ),
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

