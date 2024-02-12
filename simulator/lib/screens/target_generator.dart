// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../widgets/ai_scenario/air_targets.dart';
import '../widgets/ai_scenario/ground_targets.dart';
import '../widgets/ai_scenario/sea_targets.dart';

class ScenarioManagementScreen extends StatefulWidget {
  @override
  _ScenarioManagementScreenState createState() =>
      _ScenarioManagementScreenState();
}

class _ScenarioManagementScreenState extends State<ScenarioManagementScreen> {
  int? roll;
  int? heading;
  int? speed;
  int? altitude;
  int? rudder;
  bool isFileUploaded = false;
  bool isgeneratescenario = false;
  String type = "";
  String model = "";
  String classi = "";

  final TextEditingController scenarioDescriptionController =
      TextEditingController();
  TextEditingController scenarioNameController = TextEditingController();
  String selectedScenarioType = 'Select';

  String filePath = '';

  // Global arrays to store coordinates
  List<double> latitudes = [];
  List<double> longitudes = [];
  List<double> altitudes = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: scenarioNameController,
                  decoration: InputDecoration(
                    labelText: "Scenario Name",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: scenarioDescriptionController,
                  decoration: InputDecoration(
                    labelText: "Scenario Description",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DropdownButton<String>(
                  value: selectedScenarioType,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedScenarioType = newValue;
                      });
                      // Update the selected value when the user selects a new one
                      selectedScenarioType = newValue;
                    }
                  },
                  items: <String>['Select', 'Air', 'Sea', 'Ground']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (selectedScenarioType == 'Air')
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        type = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Type",
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
                        classi = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Class",
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
                        model = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Model",
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
                        speed = int.tryParse(value);
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Speed",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          if (selectedScenarioType == 'Sea')
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        type = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Type",
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
                        model = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Model",
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
                        speed = int.tryParse(value);
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
                        rudder = int.tryParse(value);
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Rudder",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          if (selectedScenarioType == 'Ground')
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        type = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Type",
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
                        model = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Model",
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
                        speed = int.tryParse(value);
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
                        rudder = int.tryParse(value);
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Rudder",
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
                        heading = int.tryParse(value);
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Heading",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              if (result != null) {
                setState(() {
                  filePath = result.files.first.path!;
                  isFileUploaded = true;
                });
              }
            },
            child: Text('Select Txt File'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                isFileUploaded ? () => uploadCoordinates(filePath) : null,
            child: Text('Upload Coordinates'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: isgeneratescenario ? () => generateScenario() : null,
            child: Text('Generate Scenario'),
          ),
        ],
      ),
    );
  }

  String generateXml(String groupName, List<List<double>> coordinates) {
    final StringBuffer xml = StringBuffer('<?xml version="1.0"?>');

    xml.writeln('<PropertyList>');
    xml.writeln(' <flightplan>');
    for (int i = 1; i < coordinates.length; i++) {
      var coord = coordinates[i - 1];
      xml.writeln('  <wpt>');
      xml.writeln('   <name>WPT$i</name>');
      xml.writeln('   <lat>${coord[0]}</lat>');
      xml.writeln('   <lon>${coord[1]}</lon>');
      xml.writeln('   <alt>${coord[2]}</alt>');
      xml.writeln('   <ktas>$speed</ktas>');
      xml.writeln('  </wpt>');
    }

    // Handle the last coordinate separately
    if (coordinates.isNotEmpty) {
      var lastCoord = coordinates.last;
      xml.writeln('  <wpt>');
      xml.writeln('   <name>END</name>');
      xml.writeln('   <lat>${lastCoord[0]}</lat>');
      xml.writeln('   <lon>${lastCoord[1]}</lon>');
      xml.writeln('   <alt>${lastCoord[2]}</alt>');
      xml.writeln('   <ktas>$speed</ktas>');
      xml.writeln('  </wpt>');
    }

    xml.writeln(' </flightplan>');
    xml.writeln('</PropertyList>');

    return xml.toString();
  }

  late int rows;
  late int interval;
  void uploadCoordinates(String filePath) async {
    try {
      if (filePath.isNotEmpty) {
        File file = File(filePath);
        String content = await file.readAsString();
        List<String> lines = content.split('\n');

        // Clear arrays before adding new coordinates
        latitudes.clear();
        longitudes.clear();
        altitudes.clear();

        for (String line in lines) {
          List<String> coordinates = line.split('\t');
          print(coordinates);
          if (coordinates.length >= 3) {
            double latitude = double.parse(coordinates[0]);
            double longitude = double.parse(coordinates[1]);
            double altitude = double.parse(coordinates[2]);

            // Store coordinates in global arrays
            latitudes.add(latitude);
            longitudes.add(longitude);
            altitudes.add(altitude);
          } else {
            // Invalid coordinate format
            // Handle or inform the user about the issue
          }
        }
        // Remove the first element from each array
        if (latitudes.isNotEmpty) {
          latitudes.removeAt(0);
        }
        if (longitudes.isNotEmpty) {
          longitudes.removeAt(0);
        }
        if (altitudes.isNotEmpty) {
          altitudes.removeAt(0);
        }
        // Set the flag to true when the file is successfully uploaded
        setState(() {
          isgeneratescenario = true;
        });

        // Read the text file content (lat, long, altitude)
        List<String> contents = File(filePath).readAsStringSync().split('\n');

        // Check if there is at least one row
        if (contents.isNotEmpty) {
          // Remove the first element (1st row) and keep the rest
          //contents = contents.sublist(1);

          print(contents);
        } else {
          print("File is empty.");
          // Handle the case when the file is empty
        }

        // Calculate the number of rows
        rows = contents.length;
        print("Number of rows: $rows");

        // Rows interval for each target
        interval = 5; //waypionts

        // Calculate the number of targets
        int targets = (rows / interval).ceil(); //50/5 = 10

        if (selectedScenarioType == 'Air') {
          // Create empty maps for target arrays
          Map<String, List<String>> targetArrays = {
            for (int i = 0; i < targets; i++) "airtgt${i + 1}": [],
          };

          // Populate the target arrays
          for (int i = 0; i < rows; i++) {
            int targetIndex = (i / interval).floor();
            print(targetIndex);
            targetArrays["airtgt${targetIndex + 1}"]?.add(contents[i].trim());
          }
          print(targetArrays);

          // Print the target arrays
          targetArrays.forEach((target, data) {
            print("$target: $data");
          });
          print(targetArrays);
          // Create and save XML files
          targetArrays.forEach((target, data) {
            final coordinates = _parseCoordinates(data);
            final xmlString = generateXml(target, coordinates);
            final fileName = '$target.xml';
            final file = File(
                r'C:\Program Files\FlightGear 2020.3\data\AI\Flightplans\' +
                    '$fileName');
            file.writeAsStringSync(xmlString);
          });
        }
      } else {
        // No file selected
        // Handle or inform the user about the issue
        // Set the flag to true when the file is successfully uploaded
        setState(() {
          isgeneratescenario = false;
        });
      }
    } catch (e) {
      // Handle errors
      print('Error reading file: $e');
      // Set the flag to false in case of an error
      setState(() {
        isgeneratescenario = false;
      });
      // Show a user-friendly error message to the UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error reading file: $e'),
        ),
      );
    }
  }

  List<List<double>> _parseCoordinates(List<String> data) {
    List<List<double>> coordinates = [];

    for (var entry in data) {
      final parts = entry.split('\t');
      if (parts.length >= 3) {
        final coordinate =
            parts.map((value) => double.tryParse(value) ?? 0.0).toList();
        coordinates.add(coordinate);
      } else {
        // Handle invalid coordinate format
      }
    }

    return coordinates;
  }

  void generateScenario() {
    // Use the global arrays latitudes, longitudes, and altitudes to generate scenarios
    final List<ScenarioEntry3> scenarioEntries3 = [];
    final List<ScenarioEntry2> scenarioEntries2 = [];
    final List<ScenarioEntry1> scenarioEntries1 = [];

    //final List<ProtocolEntry> protocolEntries = [];
    int targets = (rows / interval).ceil();
    if (selectedScenarioType == "Air") {
      for (int i = 0; i < targets; i++) {
        // Create a ScenarioEntry for the current scenarioEntry
        ScenarioEntry1 air = ScenarioEntry1(
          type: type != "" ? type : 'aircraft',
          model: model != "" ? model : 'AI/Aircraft/F-15/Models/F-15.xml',
          callsign: 'AIRTGT${i + 1}',
          classi: classi != "" ? classi : 'ufo',
          flightplan: 'airtgt${i + 1}.xml',
        );
        // Add the ScenarioEntry to the scenarioEntries list
        scenarioEntries1.add(air);
      }
      // Create a ProtocolEntry for the current protocolEntry
      //ProtocolEntry ptm = ProtocolEntry(
      //name: 'PARAM$i',
      //format: '%lf',
      //type: 'double',
      //node: 'ai/models/aircraft[$i]/velocities/true-airspeed-kt',
      //);
      // // Add the ScenarioEntry to the scenarioEntries list
      //protocolEntries.add(ptm);

      // Create the Scenario object
      final scenario = Scenario1(
        scenarioName: scenarioNameController.text,
        description: scenarioDescriptionController.text,
        searchOrder: "DATA_ONLY",
        entries: scenarioEntries1,
      );

      print(scenario);
      // Generate the XML content
      final xmlContent = buildAirScenarioXML(scenario);
      // Save XML to file
      saveXMLToFile(xmlContent);
    }

    if (selectedScenarioType == "Sea") {
      for (int i = 0; i < targets; i++) {
        print(
            'Scenario $i: Latitude: ${latitudes[i]}, Longitude: ${longitudes[i]}, Altitude: ${altitudes[i]}');

        // Create a ScenarioEntry for the current scenarioEntry
        ScenarioEntry2 sea = ScenarioEntry2(
          type: type != "" ? type : 'ship',
          model:
              model != "" ? model : 'Models/Maritime/Military/Carrier_A01.xml',
          name: 'ship_$i',
          latitude: '${latitudes[i]}',
          longitude: '${longitudes[i]}',
          speed: speed.toString(),
          rudder: rudder.toString(),
        );
        // Add the ScenarioEntry to the scenarioEntries list
        scenarioEntries2.add(sea);
      }
      // Create a ProtocolEntry for the current protocolEntry
      //ProtocolEntry ptm = ProtocolEntry(
      //name: 'PARAM$i',
      //format: '%lf',
      //type: 'double',
      //node: 'ai/models/aircraft[$i]/velocities/true-airspeed-kt',
      //);
      // // Add the ScenarioEntry to the scenarioEntries list
      //protocolEntries.add(ptm);

      // Create the Scenario object
      final scenario = Scenario2(
        scenarioName: scenarioNameController.text,
        description: scenarioDescriptionController.text,
        searchOrder: "DATA_ONLY",
        entries: scenarioEntries2,
      );

      print(scenario);
      // Generate the XML content
      final xmlContent = buildSeaScenarioXML(scenario);
      // Save XML to file
      saveXMLToFile(xmlContent);
    }

    if (selectedScenarioType == "Ground") {
      for (int i = 0; i < targets; i++) {
        print(
            'Scenario $i: Latitude: ${latitudes[i]}, Longitude: ${longitudes[i]}, Altitude: ${altitudes[i]}');

        // Create a ScenarioEntry for the current scenarioEntry
        ScenarioEntry3 ground = ScenarioEntry3(
          type: type != "" ? type : 'ship',
          model: model != ""
              ? model
              : 'Models/Military/humvee-pickup-odrab-low-poly.ac',
          speedktas: speed.toString(),
          name: 'Hamvee_$i',
          latitude: '${latitudes[i]}',
          longitude: '${longitudes[i]}',
          heading: heading.toString(),
          altitude: altitude.toString(),
        );
        // Add the ScenarioEntry to the scenarioEntries list
        scenarioEntries3.add(ground);
      }
      // Create a ProtocolEntry for the current protocolEntry
      //ProtocolEntry ptm = ProtocolEntry(
      //name: 'PARAM$i',
      //format: '%lf',
      //type: 'double',
      //node: 'ai/models/aircraft[$i]/velocities/true-airspeed-kt',
      //);
      // // Add the ScenarioEntry to the scenarioEntries list
      //protocolEntries.add(ptm);
      // Create the Scenario object
      final scenario = Scenario3(
        scenarioName: scenarioNameController.text,
        description: scenarioDescriptionController.text,
        searchOrder: "DATA_ONLY",
        entries: scenarioEntries3,
      );

      print(scenario);
      // Generate the XML content
      final xmlContent = buildGroundScenarioXML(scenario);
      // Save XML to file
      saveXMLToFile(xmlContent);
    }
  }

  // Create the Scenario object
  //final protocol = Protocol(
  //scenarioName: scenarioNameController.text,
  //description: scenarioDescriptionController.text,
  //searchOrder: "DATA_ONLY",
  //entries: protocolEntries,
  //);

  //print(protocol);

  // Specify the desired file paths for saving XML content
  //String protocolXmlFilePath =
  //r'C:\Program Files\FlightGear 2020.3\data\Protocol\TARGET.xml';

  // Generate the XML content
  //final xmlContentptm = buildProtocolXML(protocol);

  // Save XML to file
  //saveXMLToFileptm(xmlContentptm, protocolXmlFilePath);

  // void saveXMLToFileptm(String xmlContentptm, String filePath) {
  //   File file = File(filePath);
  //   file.writeAsStringSync(xmlContentptm);
  //   print('XML content saved to file: $filePath');
  // }

  void saveXMLToFile(String xmlContent) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      // ignore: prefer_interpolation_to_compose_strings
      String filePath = '$appDocPath/' + scenarioNameController.text + '.xml';

      File file = File(filePath);
      await file.writeAsString(xmlContent);

      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          // Capture the context before the async gap
          final currentContext = context;

          return AlertDialog(
            title: const Text("Scenario Created"),
            content: const Text(
                "Scenario XML file generated successfully! and moved to documents directory"),
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
    } catch (e) {
      print('Error saving XML file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving XML file: $e'),
        ),
      );
    }
  }
}

class Scenario1 {
  String scenarioName;
  String description;
  String searchOrder;
  List<ScenarioEntry1> entries;

  Scenario1({
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

class Scenario2 {
  String scenarioName;
  String description;
  String searchOrder;
  List<ScenarioEntry2> entries;

  Scenario2({
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

class Scenario3 {
  String scenarioName;
  String description;
  String searchOrder;
  List<ScenarioEntry3> entries;

  Scenario3({
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

class Protocol {
  String scenarioName;
  String description;
  String searchOrder;
  List<ProtocolEntry> entries;

  Protocol({
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

class ProtocolEntry {
  final String name;
  final String format;
  final String type; // Auto-generated
  final String node;

  ProtocolEntry({
    required this.type,
    required this.name,
    required this.format,
    required this.node,
  });
  @override
  String toString() {
    return 'ProtocolEntry(type: $type, name: $name, format: $format, node: $node)';
  }
}

class ScenarioEntry3 {
  final String type;
  final String model;
  final String name; // Auto-generated
  final String speedktas;
  final String latitude; // Auto-generated based on sourceAirport
  final String longitude; // Auto-generated based on sourceAirport
  final String heading;
  final String altitude;

  ScenarioEntry3({
    required this.type,
    required this.model,
    required this.speedktas,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.heading,
    required this.altitude,
  });
  @override
  String toString() {
    return 'ScenarioEntry(type: $type, model: $model,  speedktas: $speedktas, name: $name, latitude: $latitude, longitude: $longitude,  heading: $heading, altitude: $altitude)';
  }
}

class ScenarioEntry2 {
  final String type;
  final String model;
  final String name; // Auto-generated
  final String latitude; // Auto-generated based on sourceAirport
  final String longitude; // Auto-generated based on sourceAirport
  final String speed;
  final String rudder;

  ScenarioEntry2({
    required this.type,
    required this.model,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.rudder,
  });
  @override
  String toString() {
    return 'ScenarioEntry(type: $type, model: $model, name: $name, latitude: $latitude, longitude: $longitude, speed: $speed, rudder: $rudder)';
  }
}

class ScenarioEntry1 {
  final String type;
  final String model;
  final String callsign;
  final String classi;

  final String flightplan;

  ScenarioEntry1({
    required this.type,
    required this.model,
    required this.callsign,
    required this.classi,
    required this.flightplan,
  });
  @override
  String toString() {
    return 'ScenarioEntry1(type: $type, model: $model, callsign: $callsign, classi: $classi, flightplan:$flightplan)';
  }
}
