import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:simulator/utils/data_load.dart';
import 'package:path/path.dart' as path;
import '../utils/file_handlers.dart';
import '../utils/service_handler.dart';

class LaunchManagementScreen extends StatefulWidget {
  @override
  _LaunchManagementScreenState createState() => _LaunchManagementScreenState();
}

final _serviceDisplayNames = {
  Service.flightGear: 'Flight Gear',
  Service.jsApp: 'Joystick',
  Service.mil: 'MIL',
  Service.hmds: 'HMDS',
  Service.arinc: 'ARINC',
};

class _LaunchManagementScreenState extends State<LaunchManagementScreen> {
  final ServiceHandler serviceHandler = ServiceHandler();
  final Map<Service, Timer> _timers = {};
  final Map<Service, bool> _visibilityFlags = {
    for (var e in Service.values) e: true
  };

  String? selectedOption = 'Select Flying Mode';
  String? subOption = 'Select Sub Option';
  String? targetOption = 'Select Target Option';
  String? targetSubOption = 'Select Sub Option';
  String? typeOfTarget = 'Select Target';
  String? airport;
  double? latitudeValue;
  double? longitudeValue;
  int? altitudeValue = 15000;
  int? headingValue = 120;
  List<String> airports = DataLoader().getAllAirportCodes();

  bool socketClosed = false;
  late RawDatagramSocket socket;

  String? filename;

  @override
  void initState() {
    super.initState();
    for (var service in Service.values) {
      _timers[service] = Timer.periodic(Duration(seconds: 1), (Timer timer) {
        setState(() {
          _visibilityFlags[service] = !(_visibilityFlags[service] ?? false);
        });
      });
    }
  }

  @override
  void dispose() {
    _timers.values.forEach((timer) => timer.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _controllerlat =
        TextEditingController(text: latitudeValue?.toString() ?? '');
    TextEditingController _controllerlong =
        TextEditingController(text: longitudeValue?.toString() ?? '');
    return Column(
      children: [
        Container(
          width: double.infinity,
          child: buildRouteOptionsCard(_controllerlat, _controllerlong),
        ),
        Container(
          width: double.infinity,
          child: buildTargetOptionsCard(),
        ),
        buildServiceStatusRow(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Launch Button
            ElevatedButton(
              onPressed: () {
                // Add your launch logic here
                print('Launching');

                serviceHandler.runAllServices(collectData());
              },
              child: Text('Launch'),
            ),

            // Stop Button
            ElevatedButton(
              onPressed: () {
                // Add your stop logic here
                print('Stopping');

                serviceHandler.stopAllServices();
                // stopByPass();
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Set button color to red
              ),
              child: Text('Stop'),
            ),
          ],
        ),
      ],
    );
  }

  Row buildServiceStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: Service.values.map((service) {
        return _buildServiceStatusContainer(service);
      }).toList(),
    );
  }

  Container _buildServiceStatusContainer(Service service) {
    return Container(
      width: 100.0,
      margin: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _serviceDisplayNames[service]!,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _visibilityFlags[service]!
                  ? serviceHandler.serviceStates[service]!
                      ? Colors.green
                      : Colors.red
                  : Colors.transparent,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.brightness_1,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Card buildTargetOptionsCard() {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTitle('Target Options'),
            buildRow([
              buildDropdownButton(targetOption, [
                'Select Target Option',
                'FG AI Scenario',
                'Manual AI Scenario'
              ], (newValue) {
                setState(() {
                  targetOption = newValue;
                  targetSubOption = 'Select Sub Option';
                });
              }),
              if (targetOption == 'FG AI Scenario')
                buildUploadButton(movefileforfgaiscenario),
              if (targetOption == 'Manual AI Scenario' ||
                  targetOption == 'FG AI Scenario')
                buildDropdownButton(typeOfTarget, [
                  'Select Target',
                  'Air Target',
                  'Sea Target',
                  'Ground Target'
                ], (newValue) {
                  setState(() {
                    typeOfTarget = newValue;
                  });
                }),
              if (targetOption == 'Manual AI Scenario')
                buildDropdownButton(targetSubOption, [
                  'Select Sub Option',
                  'Replay Recorded Data',
                  'Bypass FG'
                ], (newValue) {
                  setState(() {
                    targetSubOption = newValue;
                  });
                }),
              if (targetSubOption == 'Replay Recorded Data')
                buildUploadButton(movefileformanualai),
              // if (targetSubOption == 'Bypass FG') buildUploadButton(_pickFile),
            ]),
          ],
        ),
      ),
    );
  }

  Widget buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget buildRow(List<Widget> children) {
    return Row(
      children: children
          .expand((child) => [SizedBox(width: 16.0), Expanded(child: child)])
          .toList(),
    );
  }

  Widget buildDropdownButton(
      String? value, List<String?> items, ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      value: value,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String? value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value ?? ''),
        );
      }).toList(),
    );
  }

  Widget buildDropdownFormField(String? value, List<String> items,
      ValueChanged<String?> onChanged, String labelText) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget buildUploadButton(Future<void> Function(String filePath) onPressed) {
    return ElevatedButton(
      onPressed: () async {
        FilePickerResult? result = await FilePicker.platform.pickFiles();
        if (result != null) {
          String filePath = result.files.single.path!;
          print('Selected file: $filePath');
          await onPressed(filePath);
        } else {
          print('File picking canceled.');
        }
      },
      child: Text('Upload File'),
    );
  }

  Widget buildTextFormField(TextEditingController controller,
      ValueChanged<String> onChanged, String labelText) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
    );
  }

  Card buildRouteOptionsCard(TextEditingController _controllerlat,
      TextEditingController _controllerlong) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTitle('Route Options'),
            buildRow([
              buildDropdownButton(selectedOption, [
                'Select Flying Mode',
                'Autopilot',
                'Manual Flying'
              ], (newValue) {
                setState(() {
                  selectedOption = newValue;
                  subOption = 'Select Sub Option';
                });
              }),
              SizedBox(width: 16.0),
              if (selectedOption == 'Manual Flying')
                buildDropdownButton(
                    subOption, ['Select Sub Option', 'On Air', 'On Airport'],
                    (newValue) {
                  setState(() {
                    subOption = newValue;
                  });
                }),
              if (selectedOption == 'Autopilot')
                buildUploadButton(movefileforautopilot),
            ]),
            SizedBox(height: 16.0),
            if (selectedOption == 'Autopilot')
              buildRow([
                buildDropdownFormField(airport, airports, (value) {
                  setState(() {
                    airport = value!;
                    updateLatLongFromAirport(airport!);
                  });
                }, "Airport"),
                buildTextFormField(_controllerlat, (value) {
                  setState(() {
                    latitudeValue = double.tryParse(value);
                  });
                }, "Latitude"),
                buildTextFormField(_controllerlong, (value) {
                  setState(() {
                    longitudeValue = double.tryParse(value);
                  });
                }, "Longitude"),
                buildTextFormField(
                    TextEditingController(
                        text: altitudeValue?.toString() ?? ''), (value) {
                  setState(() {
                    altitudeValue = int.tryParse(value);
                  });
                }, "Altitude"),
                buildTextFormField(
                    TextEditingController(text: headingValue?.toString() ?? ''),
                    (value) {
                  setState(() {
                    headingValue = int.tryParse(value);
                  });
                }, "Heading"),
              ]),
            if (subOption == 'On Air' || subOption == 'On Airport')
              buildRow([
                buildDropdownFormField(airport, airports, (value) {
                  setState(() {
                    airport = value!;
                    updateLatLongFromAirport(airport!);
                  });
                }, "Airport"),
                buildTextFormField(_controllerlat, (value) {
                  setState(() {
                    latitudeValue = double.tryParse(value);
                  });
                }, "Latitude"),
                buildTextFormField(_controllerlong, (value) {
                  setState(() {
                    longitudeValue = double.tryParse(value);
                  });
                }, "Longitude"),
              ]),
          ],
        ),
      ),
    );
  }

  void updateLatLongFromAirport(String selectedAirport) {
    Airport temp = DataLoader().getAirport(selectedAirport)!;
    setState(() {
      latitudeValue = temp.latitude;
      longitudeValue = temp.longitude;
    });
  }

  Map<String, dynamic> collectData() {
    Map<String, dynamic> data = {
      'selectedOption': selectedOption,
      'subOption': subOption,
      'targetOption': targetOption,
      'typeOfTarget': typeOfTarget,
      'targetSubOption': targetSubOption,
      'airport': airport,
      'latitudeValue': latitudeValue,
      'longitudeValue': longitudeValue,
      'altitudeValue': altitudeValue,
      'headingValue': headingValue,
      'serviceStates': serviceHandler.serviceStates,
      'filename': filename,
    };
    if (subOption == 'On Air' || subOption == 'On Airport') {
      data['state'] = 'cruise';
    } else {
      data['state'] = 'cruise';
    }
    return data;
  }

  Future<void> movefileforautopilot(String filePath) async {
    moveFile(filePath, r'C:\Users\scl\Flightgear\config', null, (message) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> movefileforfgaiscenario(String filePath) async {
    moveFile(filePath, r'C:\Users\scl\Flightgear\Aircrafts\f16\Scenarios\',
        (fileName) {
      setState(() {
        filename = path.basenameWithoutExtension(fileName);
      });
    }, (message) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> movefileformanualai(String filePath) async {
    moveFile(filePath, r'C:\Users\scl\Flightgear\config', null, (message) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    });
  }
}
