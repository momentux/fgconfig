import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:simulator/data/airports.dart';
import 'dart:io';

import 'package:simulator/utils/xml.dart';

class ScenarioManagementScreen extends StatefulWidget {
  const ScenarioManagementScreen({Key? key}) : super(key: key);

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
      ('Error loading airports from JSON: $e');
    }
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
          Column(
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
              const Text("Number of Air Targets"),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    numberOfAirTargets = int.tryParse(value) ?? 0;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Number of Ground Targets"),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    numberOfGroundTargets = int.tryParse(value) ?? 0;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Sea Targets"),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    seaTargets = int.tryParse(value) ?? 0;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Speed"),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    speed = double.tryParse(value) ?? 0.0;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Roll"),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    roll = double.tryParse(value) ?? 0.0;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              generateScenarioXML(); // Call the function to generate XML
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            child: const Text("Create Scenario"),
          ),
        ],
      ),
    );
  }

  Future<void> generateScenarioXML() async {
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
