import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:simulator/data/airports.dart';
import 'dart:io';

import 'package:simulator/utils/xml.dart';

class Waypoint {
  var airport;
  int numberofgroundtargets;
  int numberofseatargets;
  int numberofairtargets;
  double speed;
  double roll;

  Waypoint(
      {required this.airport,
      required this.numberofgroundtargets,
      required this.numberofseatargets,
      required this.numberofairtargets,
      required this.speed,
      required this.roll});
}

class ScenarioManagementScreen extends StatefulWidget {
  const ScenarioManagementScreen({super.key});

  @override
  State<ScenarioManagementScreen> createState() =>
      _ScenarioManagementScreenState();
}

class _ScenarioManagementScreenState extends State<ScenarioManagementScreen> {
  TextEditingController scenarioNameController = TextEditingController();
  String sourceAirport = "KXTA"; // Initial value for source airport
  int numberOfAirTargets = 0;
  int numberOfGroundTargets = 0;
  int seaTargets = 0;
  double speed = 0.0;
  double roll = 0.0;

  List<String> airports = []; // List to store source airports
  List<Waypoint> waypoints = []; // List to store waypoints

  @override
  void initState() {
    super.initState();
    loadAirportsFromJson();
  }

  Future<void> loadAirportsFromJson() async {
    try {
      final parsedJson = json.decode(airportsJson);
      final List<String> airportCodes = List<String>.from(
          parsedJson.map((airport) => airport['airportCode']));
      setState(() {
        airports = airportCodes;
      });
    } catch (e) {
      print('Error loading airports from JSON: $e');
    }
  }

  bool isScenarioExpanded = true;

  Widget buildScenarioInputContainer() {
    return Card(
      elevation: 3,
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            isScenarioExpanded = !isExpanded;
          });
        },
        children: [
          ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: const Text("Scenario Settings"),
              );
            },
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Source Airport"),
                  DropdownButtonFormField<String>(
                    value: sourceAirport,
                    onChanged: (value) {
                      setState(() {
                        sourceAirport = value!;
                      });
                    },
                    items: airports.map((airport) {
                      return DropdownMenuItem<String>(
                        value: airport,
                        child: Text(airport),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Targets"),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              numberOfAirTargets = int.tryParse(value) ?? 0;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: "Air",
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
                              numberOfGroundTargets = int.tryParse(value) ?? 0;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: "Ground",
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
                              seaTargets = int.tryParse(value) ?? 0;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: "Sea",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Speed and Roll"),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              speed = double.tryParse(value) ?? 0.0;
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
                              roll = double.tryParse(value) ?? 0.0;
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
            isExpanded: isScenarioExpanded,
          ),
        ],
      ),
    );
  }

// Inside the _ScenarioManagementScreenState class

  Widget buildWaypointInputContainer(Waypoint waypoint, int index) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Waypoint"),
              ElevatedButton(
                onPressed: () {
                  // Remove the waypoint at the specified index
                  setState(() {
                    waypoints.removeAt(index);
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  backgroundColor: Colors.red, // You can customize the color
                ),
                child: const Text("Delete"),
              ),
            ]),
            const Text("Source Airport"),
            DropdownButtonFormField<String>(
              value: sourceAirport,
              onChanged: (value) {
                setState(() {
                  waypoint.airport = value!;
                });
              },
              items: airports.map((airport) {
                return DropdownMenuItem<String>(
                  value: airport,
                  child: Text(airport),
                );
              }).toList(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Targets"),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        waypoint.numberofairtargets = int.tryParse(value) ?? 0;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Air",
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
                        waypoint.numberofgroundtargets =
                            int.tryParse(value) ?? 0;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Ground",
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
                        waypoint.numberofseatargets = int.tryParse(value) ?? 0;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Sea",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Speed and Roll"),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        waypoint.speed = double.tryParse(value) ?? 0.0;
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
                        waypoint.roll = double.tryParse(value) ?? 0.0;
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Create a Scenario",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: scenarioNameController,
            decoration: const InputDecoration(
              labelText: "Scenario Name",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),
          buildScenarioInputContainer(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: addWaypoint,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            child: const Text("Add Waypoint"),
          ),
          // Display waypoint containers
          for (int i = 0; i < waypoints.length; i++)
            buildWaypointInputContainer(waypoints[i], i),
          const SizedBox(height: 24),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  generateScenarioXML(); // Call the function to generate XML
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text("Create Scenario"),
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
                  // Replace "notepad.exe" with the actual command to launch Notepad on your system
                  Process.run('notepad.exe', []).then((ProcessResult result) {
                    // Check if the process was successfully started
                    if (result.exitCode == 0) {
                      // Minimize the Notepad window
                      Process.run('powershell.exe', [
                        '-command',
                        '(New-Object -ComObject Shell.Application).MinimizeAll()'
                      ]);
                    } else {
                      // Handle the case where launching Notepad failed
                      print('Failed to launch Notepad: ${result.stderr}');
                    }
                  });
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
      waypoints.add(
        Waypoint(
            airport: "KSTA",
            numberofgroundtargets:
                0, // Set to the default value or adjust as needed
            numberofseatargets: 0,
            numberofairtargets: 0,
            speed: 300.0,
            roll: 20.0),
      );
    });
  }

  Future<void> generateScenarioXML() async {
    List<Map<String, dynamic>> inputs = [];

// Add scenario metadata to the array
    List<Map<String, dynamic>> scenarioMetadata = [];
    scenarioMetadata.add({
      'scenarioName': scenarioNameController.text,
      'description': 'Your scenario description here',
      'searchOrder': 'Your search order here',
    });

    inputs.add({'scenarioMetadata': scenarioMetadata});
    List<Map<String, dynamic>> entries = [];

    // Add scenario data to the array
    entries.add({
      'sourceAirport': sourceAirport,
      'numberOfAirTargets': numberOfAirTargets,
      'numberOfGroundTargets': numberOfGroundTargets,
      'seaTargets': seaTargets,
      'speed': speed,
      'roll': roll,
    });

    // Add waypoints data to the array
    for (int i = 0; i < waypoints.length; i++) {
      entries.add({
        'sourceAirport': waypoints[i].airport,
        'numberOfAirTargets': waypoints[i].numberofairtargets,
        'numberOfGroundTargets':
            waypoints[i].numberofgroundtargets,
        'seaTargets': waypoints[i].numberofseatargets,
        'Speed': waypoints[i].speed,
        'roll': waypoints[i].roll,
      });
    }
    inputs.add({'scenarioEntry': entries});
    // Print the array of objects
    print(inputs);

    // Add your XML generation logic here
        // Create a Scenario object with the entered parameters
    final scenario = Scenario(
      scenarioName: scenarioNameController.text,
      description: "Description goes here", // Replace with a description
      searchOrder: "DATA_ONLY", // Replace with your desired search order
      entries: [
        for (int i = 0; i < 10; i++)
          ScenarioEntry(
            type: "ship",
            model: "Models/Military/humvee-pickup-odrab-low-poly.ac",
            name: sourceAirport, // Auto-generated name based on airport
            latitude: 0.0, // Calculate latitude based on airport
            longitude: 0.0, // Calculate longitude based on airport
            speed: speed,
            rudder: roll,
            heading: 0.0, // Replace with your desired heading
            altitude: 4750.0, // Replace with your desired altitude
          ),
      ],
    );

    // Generate the XML content
    final xmlContent = buildScenarioXML(scenario);

    // Save the XML to a file (you can specify the file path)
    final xmlFile =
        File('/Users/rverma/.fgfs/Aircrafts/f16/Scenarios/scenario.xml');
    await xmlFile.writeAsString(xmlContent);

    // Show a dialog or toast indicating success
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) {
        // Capture the context before the async gap
        final currentContext = context;

        return AlertDialog(
          title: const Text("Scenario Created"),
          content: const Text("Scenario XML file generated successfully!"),
          actions: [
            TextButton(
              onPressed: () {
                // Use the captured context to pop the dialog
                Navigator.of(currentContext).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}

class Scenario {
  String scenarioName;
  String description;
  String searchOrder;
  List<ScenarioEntry> entries;

  Scenario({
    required this.scenarioName,
    required this.description,
    required this.searchOrder,
    required this.entries,
  });
}

class ScenarioEntry {
  String type;
  String model;
  String name; // Auto-generated
  double latitude; // Auto-generated based on sourceAirport
  double longitude; // Auto-generated based on sourceAirport
  double speed;
  double rudder;
  double heading;
  double altitude;

  ScenarioEntry({
    required this.type,
    required this.model,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.rudder,
    required this.heading,
    required this.altitude,
  });
}
