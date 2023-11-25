// ignore_for_file: unnecessary_string_escapes

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
  double latitude = 0.0;
  double longitude = 0.0;

  List<String> airports = []; // List to store source airports
  List<Waypoint> waypoints = []; // List to store waypoints
  List<String> latitudes = []; // List to store source airports
  List<String> longitudes = []; // List to store source airports
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

      final List<String> lat =
          List<String>.from(parsedJson.map((latitude) => latitude['latitude']));

      final List<String> long = List<String>.from(
          parsedJson.map((longitude) => longitude['longitude']));

      setState(() {
        airports = airportCodes;
        latitudes = lat;
        longitudes = long;
      });

      print(latitudes);
      print(longitudes);
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
                  _launchFlightGear();
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

  final String flightGearExecutablePath =
      r'C:\Program Files\FlightGear 2020.3\bin\fgfs.exe';

  _launchFlightGear() async {
    try {
      await Process.start(
        flightGearExecutablePath,
        ['/min'], // Add any other arguments if needed
        mode: ProcessStartMode.detached,
      );
    } catch (e) {
      print('Error launching FlightGear: $e');
    }
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
        'numberOfGroundTargets': waypoints[i].numberofgroundtargets,
        'seaTargets': waypoints[i].numberofseatargets,
        'speed': waypoints[i].speed,
        'roll': waypoints[i].roll,
      });
    }
    inputs.add({'scenarioEntry': entries});

    print(inputs);

    // Add your XML generation logic here
    // Create a Scenario object with the entered parameters
    // Find the map containing the 'scenarioEntry' key
    Map<String, dynamic>? scenarioEntryMap = inputs.firstWhere(
      (map) => map.containsKey('scenarioEntry'),
    );
    List<dynamic> scenarioEntryList = scenarioEntryMap['scenarioEntry'];
    print(scenarioEntryList);

    final List<ScenarioEntry> scenarioEntries = [];

    for (int i = 0; i < scenarioEntryList.length; i++) {
      // Outer loop: Iterate over scenarioEntryList

      Map<String, dynamic> currentEntry = scenarioEntryList[i];
      var a = currentEntry['sourceAirport']; //kxta
      var b = latitudes;
      var c = longitudes;
      var d = airports; //kxta,goa,blr

      for (int j = 0; j < airports.length; j++) {
        if (a == d[j]) {
          for (int k = 0; k < currentEntry['numberOfAirTargets']; k++) {
            // Inner loop 1: Iterate over numberOfAirTargets for the current scenarioEntry
            print('Inner loop 1: i = $i, k = $k');

            // Create a ScenarioEntry for the current scenarioEntry
            ScenarioEntry air = ScenarioEntry(
              type: 'ship',
              model: 'Models/Military/humvee-pickup-odrab-low-poly.ac',
              name: 'aircraft_$k',
              latitude: double.parse(latitudes[j]),
              longitude: double.parse(longitudes[j]),
              speed: currentEntry['speed'],
              rudder: currentEntry['roll'],
              heading: 0.0,
              altitude: 1500.0,
            );
            // Add the ScenarioEntry to the scenarioEntries list
            scenarioEntries.add(air);
          }

          for (int l = 0; l < currentEntry['numberOfGroundTargets']; l++) {
            // Inner loop 2: Iterate over numberOfGroundTargets for the current scenarioEntry

            ScenarioEntry ground = ScenarioEntry(
              type: 'ship',
              model: 'Models/Military/humvee-pickup-odrab-low-poly.ac',
              name: 'tanker_$l',
              latitude: double.parse(latitudes[j]),
              longitude: double.parse(longitudes[j]),
              speed: currentEntry['speed'],
              rudder: currentEntry['roll'],
              heading: 0.0,
              altitude: 1500.0,
            );

            // Add the ScenarioEntry to the scenarioEntries list
            scenarioEntries.add(ground);
          }

          for (int m = 0; m < currentEntry['seaTargets']; m++) {
            // Inner loop 2: Iterate over numberOfGroundTargets for the current scenarioEntry

            ScenarioEntry sea = ScenarioEntry(
              type: 'ship',
              model: 'Models/Military/humvee-pickup-odrab-low-poly.ac',
              name: 'ship_$m',
              latitude: double.parse(latitudes[j]),
              longitude: double.parse(longitudes[j]),
              speed: currentEntry['speed'],
              rudder: currentEntry['roll'],
              heading: 0.0,
              altitude: 1500.0,
            );

            // Add the ScenarioEntry to the scenarioEntries list
            scenarioEntries.add(sea);
          }
        }
      }
    }

// Create the Scenario object
    final scenario = Scenario(
      scenarioName: scenarioNameController.text,
      description: "Description goes here",
      searchOrder: "DATA_ONLY",
      entries: scenarioEntries,
    );

    print(scenario);

    // Generate the XML content
    final xmlContent = buildScenarioXML(scenario);

    // Save the XML to a file (you can specify the file path)
    var filePath =
        // ignore: prefer_interpolation_to_compose_strings
        r'C:\Users\enggr\Desktop\pp\fgconfig\Aircrafts\f16\Scenarios\' +
            scenario.scenarioName +
            '.xml';

    final xmlFile = File(filePath);
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
  @override
  String toString() {
    return 'Scenario(scenarioName: $scenarioName, description: $description, searchOrder: $searchOrder, entries: $entries)';
  }
}

class ScenarioEntry {
  final String type;
  final String model;
  final String name; // Auto-generated
  final double latitude; // Auto-generated based on sourceAirport
  final double longitude; // Auto-generated based on sourceAirport
  final double speed;
  final double rudder;
  final double heading;
  final double altitude;

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
  @override
  String toString() {
    return 'ScenarioEntry(type: $type, model: $model, name: $name, latitude: $latitude, longitude: $longitude, speed: $speed, rudder: $rudder, heading: $heading, altitude: $altitude)';
  }
}
