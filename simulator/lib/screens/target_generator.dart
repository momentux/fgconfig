import 'dart:io';
import 'package:flutter/material.dart';
import 'package:simulator/models/scenario.dart';
import 'package:simulator/screens/route_manager.dart';
import 'package:simulator/utils/data_load.dart';
import 'package:file_picker/file_picker.dart';
import 'package:xml/xml.dart';

class Target extends Waypoint {
  int numberofTargets;
  String namePrefix;
  String type;

  Target(
      {required this.numberofTargets,
      required super.airport,
      super.speed,
      super.roll,
      this.namePrefix = "ship-",
      this.type = "Air"});
}

class ScenarioMeta {}

class ScenarioManagementScreen extends StatefulWidget {
  const ScenarioManagementScreen({super.key});

  @override
  State<ScenarioManagementScreen> createState() =>
      _ScenarioManagementScreenState();
}

class _ScenarioManagementScreenState extends State<ScenarioManagementScreen> {
  final TextEditingController scenarioNameController = TextEditingController();
  final TextEditingController scenarioDescriptionController =
      TextEditingController();

  List<String> airports = DataLoader().getAllAirportCodes();
  List<Target> _targets = []; // List to store waypoints

  @override
  void initState() {
    super.initState();
    addWaypoint();
  }

  Card buildScenarioEntryCard(Target w, int index) {
    return Card(
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
                      labelText:
                          _targets.length == 1 ? "Source Airport" : "Waypoint",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 16), // Optional: for spacing between dropdowns
                Expanded(
                  flex: 1, // Adjust the flex factor if needed for sizing
                  child: DropdownButtonFormField<String>(
                    value: "Air",
                    onChanged: (value) {
                      setState(() {
                        w.type = value!;
                      });
                    },
                    items: ["Air", "Ground", "Sea"].map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Type',
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
                        var numTargets = int.tryParse(value) ?? 0;
                        if (numTargets > 1) {
                          _targets[index].numberofTargets = numTargets;
                        }
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Number of Targets",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        w.namePrefix = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Call Sign",
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text("Create a Scenario",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: scenarioNameController,
                  decoration: InputDecoration(
                    labelText: "Scenario Name",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: scenarioDescriptionController,
                  decoration: InputDecoration(
                    labelText: "Scenario Description",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 24),
            ],
          ),
          ExpansionPanelList(
            elevation: 3,
            expansionCallback: (index, isExpanded) {
              setState(() {
                // _isExpandedList[index] = !isExpanded;
              });
            },
            animationDuration: Duration(milliseconds: 600),
            children: _targets.asMap().entries.map(
              (entry) {
                int index = entry.key;
                Target item = entry.value;
                return ExpansionPanel(
                  canTapOnHeader: true,
                  headerBuilder: (_, isExpanded) =>
                      ListTile(title: Text("Target ${index + 1}")),
                  body: buildScenarioEntryCard(item, index),
                  isExpanded:
                      true, // You can control this with _isExpandedList[index] if needed
                );
              },
            ).toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: addWaypoint,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            child: const Text("Add Waypoint"),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                onPressed: generateScenarioXML,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text("Create Scenario"),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
               onPressed: uploadXml,
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
      _targets.add(Target(numberofTargets: 1, airport: "BLR"));
    });
  }

  void generateScenarioXML() async {
    final List<ScenarioEntry> scenarioEntries = [];

    for (int i = 0; i < _targets.length; i++) {
      for (int j = 0; j < _targets[i].numberofTargets; j++) {
        Airport temp = DataLoader().getAirport(_targets[i].airport)!;
        var counter = i * j + j;
        ScenarioEntry target = ScenarioEntry(
          type: 'navaid',
          name: "${_targets[i].namePrefix}$counter",
          model: 'Models/Military/humvee-pickup-odrab-low-poly.ac',
          latitude: temp.latitude,
          longitude: temp.longitude,
          speed: _targets[i].speed,
          roll: _targets[i].roll,
        );
        scenarioEntries.add(target);
      }
    }

    final scenario = Scenario(
      name: scenarioNameController.text,
      description: "Description goes here",
      entries: scenarioEntries,
    );

    final xmlContent = PropertyList(scenario: scenario).toXmlDocument();
    var filePath = "/tmp/${scenario.name}.xml";
    // r'C:\Users\scl\Flightgear\Aircrafts\f16\Scenarios\' + scenario.name + '.xml';;

    final xmlFile = File(filePath);
    xmlFile.writeAsString(xmlContent.toXmlString(pretty: true),
        mode: FileMode.write);

    showDialog(
      context: context,
      builder: (context) {
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

  void uploadXml() async {
    File? file = await pickXmlFile();
    if (file != null) {
      String contents = await file.readAsString();
      final document = XmlDocument.parse(contents);
      final rootElement = document.rootElement;
      PropertyList propertyList = PropertyList.fromXmlElement(rootElement);
      Scenario scenario = propertyList.scenario;
      AlertDialog(
          title: const Text("Scenario file loaded"),
          content: const Text("Scenario XML file is valid!"),
          actions: [
            TextButton(
              onPressed: () {
                // Use the captured context to pop the dialog
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
      )
    }
  }


  Future<File?> pickXmlFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xml'],
    );

    if (result != null) {
      return File(result.files.single.path!);
    } else {
      // User canceled the picker
      return null;
    }
  }
}
