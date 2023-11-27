import 'package:flutter/material.dart';
import 'package:simulator/utils/data_load.dart';
import 'package:simulator/models/scenario.dart';

class Waypoint {
  String airport;
  double speed;
  double roll;
  bool isExpand;

  Waypoint({required this.airport, this.speed = 0.0, this.roll = 0.0, this.isExpand = true});
}

class RouteManagementScreen extends StatefulWidget {
  const RouteManagementScreen({super.key});

  @override
  State<RouteManagementScreen> createState() => _RouteManagementScreenState();
}

class _RouteManagementScreenState extends State<RouteManagementScreen> {
  TextEditingController scenarioNameController = TextEditingController();
  List<String> airports = DataLoader().getAllAirportCodes();
  List<Waypoint> _waypoints = []; // List to store waypoints

  @override
  void initState() {
    super.initState();
    addWaypoint();
  }

  Widget buildRouteEntryCard(Waypoint w) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1, // Adjust the flex factor if needed for sizing
                  child: DropdownButtonFormField<String>(
                    value: w.airport,
                    onChanged: (value) {
                      setState(() {
                        w.airport = value!;
                      });
                    },
                    items: airports.map((airport) {
                      return DropdownMenuItem<String>(
                        value: airport,
                        child: Text(airport),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: _waypoints.length == 1 ? "Source Airport" : "Waypoint",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 16), // Optional: for spacing between dropdowns
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        w.speed = double.tryParse(value) ?? w.speed;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Speed",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        w.roll = double.tryParse(value) ?? w.roll;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Roll",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // isExpanded: isScenarioExpanded,
    );
  }

// Inside the _ScenarioManagementScreenState class

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Create a Routes",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          ExpansionPanelList(
            elevation: 3,
            // Controlling the expansion behavior
            expansionCallback: (index, isExpanded) {
              setState(() {});
            },
            animationDuration: Duration(milliseconds: 600),
            children: _waypoints
                .map(
                  (item) => ExpansionPanel(
                    canTapOnHeader: false,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: const Text("Routes Waypoints"),
                      );
                    },
                    body: buildRouteEntryCard(item),
                    isExpanded: true,
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: addWaypoint,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            child: const Text("Add Waypoint"),
          ),

          // Display waypoint containers
          const SizedBox(height: 24),

          Row(
            children: [
              ElevatedButton(
                onPressed: generateScenarioXML,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text("Create Routes"),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  // Handle XML upload functionality
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text("Upload XML"),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  // _launchFlightGear();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text("Launch"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void addWaypoint() {
    setState(() {
      _waypoints.add(Waypoint(airport: "BLR"));
    });
  }

  generateScenarioXML() {
    final List<ScenarioEntry> scenarioEntries = [];

    for (int i = 0; i < _waypoints.length; i++) {
      ScenarioEntry route = ScenarioEntry(
        type: 'navaid',
        name: 'test',
        model: 'ship',
        latitude: 1.1,
        longitude: 1.2,
        speed: _waypoints[i].speed,
        roll: _waypoints[i].roll,
      );
      scenarioEntries.add(route);
    }

    final scenario = Scenario(
      name: scenarioNameController.text,
      description: "Description goes here",
      entries: scenarioEntries,
    );

    final xmlContent = PropertyList(scenario: scenario).toXmlDocument();
    // var filePath =
    //     // ignore: prefer_interpolation_to_compose_strings
    //     r'C:\Users\enggr\Desktop\pp\fgconfig\config\'
    //     'routes'
    //     '.xml';

    // final xmlFile = File(filePath);
    print(xmlContent.toXmlString(pretty: true));
  }
}
