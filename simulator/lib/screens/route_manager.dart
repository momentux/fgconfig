import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/route.dart';

class RouteManagementScreen extends StatefulWidget {
  @override
  _RouteManagementScreenState createState() => _RouteManagementScreenState();
}

class _RouteManagementScreenState extends State<RouteManagementScreen> {
  int? roll;
  int? heading;
  int? speed;
  int? altitude;
  bool isFileUploaded = false;
  bool isgeneratescenario = false;

  final TextEditingController scenarioDescriptionController = TextEditingController();
  TextEditingController scenarioNameController = TextEditingController();

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
          const SizedBox(height: 16),
          Row(
            children: [
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
                      altitude = int.tryParse(value);
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "altitude",
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
            onPressed: isFileUploaded ? () => uploadCoordinates(filePath) : null,
            child: Text('Upload Coordinates'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: isgeneratescenario ? () => generateScenario() : null,
            child: Text('Generate Route'),
          ),
        ],
      ),
    );
  }

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
          if (coordinates.length >= 3) {
            double latitude = double.parse(coordinates[0]);
            double longitude = double.parse(coordinates[1]);
            double altitude = double.parse(coordinates[2]);

            // Store coordinates in global arrays
            latitudes.add(latitude);
            longitudes.add(longitude);
            altitudes.add(altitude);
          }
        }
        setState(() {
          isgeneratescenario = true;
        });
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

  void generateScenario() {
    // Use the global arrays latitudes, longitudes, and altitudes to generate scenarios
    final List<ScenarioEntry> scenarioEntries = [];

    for (int i = 0; i < latitudes.length; i++) {
      ScenarioEntry air = ScenarioEntry(
        sno: '$i',
        type: 'navaid',
        name: 'route-$i',
        latitude: latitudes[i],
        longitude: longitudes[i],
        speed: speed!.toDouble(),
        altitude: altitude!,
      );
      scenarioEntries.add(air);
    }
    final route = FgRoute(
      scenarioName: scenarioNameController.text,
      description: scenarioDescriptionController.text,
      searchOrder: "DATA_ONLY",
      entries: scenarioEntries,
    );

    final xmlContent = buildRouteXML(route);
    saveXMLToFile(xmlContent);
  }

  void saveXMLToFile(String xmlContent) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      // ignore: prefer_interpolation_to_compose_strings
      String filePath = '$appDocPath/' + 'route.xml';

      File file = File(filePath);
      await file.writeAsString(xmlContent);

      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          // Capture the context before the async gap
          final currentContext = context;

          return AlertDialog(
            title: const Text("Route Created"),
            content: const Text("Route XML file generated successfully! and moved to documents directory"),
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
