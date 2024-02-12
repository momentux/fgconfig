import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:simulator/utils/data_load.dart';
import '../utils/components.dart';
import '../utils/file_handlers.dart';
import '../utils/service_handler.dart';
import '../widgets/target_options.dart';

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
const String selectedOptionHint = 'Select Flying Mode';
const String subOptionHint = 'Select Sub Option';

class _LaunchManagementScreenState extends State<LaunchManagementScreen> {
  final ServiceHandler serviceHandler = ServiceHandler();
  final Map<Service, Timer> _timers = {};
  final Map<Service, bool> _visibilityFlags = {
    for (var e in Service.values) e: true
  };
  String? selectedOption = 'Autopilot';
  String? subOption;
  String? targetOption;
  String? typeOfTarget;
  String? targetSubOption;
  double? latitudeValue;
  double? longitudeValue;
  int? altitudeValue = 15000;
  int? headingValue = 120;
  String? airport = DataLoader().getAllAirportCodes()[0];
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
    for (var timer in _timers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controllerlat =
        TextEditingController(text: latitudeValue?.toString() ?? '');
    TextEditingController controllerlong =
        TextEditingController(text: longitudeValue?.toString() ?? '');
    return Column(
      children: [
        buildRouteOptionsCard(controllerlat, controllerlong),
        TargetOptionsCard(
            targetOption: targetOption,
            typeOfTarget: typeOfTarget,
            targetSubOption: targetSubOption,
            onOptionsChanged:
                (newTargetOption, newTypeOfTarget, newTargetSubOption) {
              setState(() {
                targetOption = newTargetOption;
                typeOfTarget = newTypeOfTarget;
                targetSubOption = newTargetSubOption;
              });
            }),
        buildServiceStatusRow(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Launch Button
            ElevatedButton(
              onPressed: () {
                // Add your launch logic here
                print('Launching');

                serviceHandler.runFlightGear(collectData());
              },
              child: Text('Launch'),
            ),

            // Stop Button
            ElevatedButton(
              onPressed: () {
                // Add your stop logic here
                print('Stopping');

                serviceHandler.stopFlightGear();
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

  Card buildRouteOptionsCard(TextEditingController controllerlat,
      TextEditingController controllerlong) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTitle('Route Options'),
            buildRow([
              buildDropdownFormField(
                  selectedOption, ['Autopilot', 'Manual Flying'], (newValue) {
                setState(() {
                  selectedOption = newValue;
                  subOption = 'On Air';
                });
              }, selectedOptionHint),
              if (selectedOption == 'Autopilot')
                buildUploadButton(movefileforautopilot),
              if (selectedOption == 'Manual Flying')
                buildDropdownFormField(subOption, ['On Air', 'On Airport'],
                    (newValue) {
                  setState(() {
                    subOption = newValue;
                  });
                }, subOptionHint),
            ]),
            SizedBox(height: 20.0),  // Add a SizedBox widget here
            buildRow([
              buildDropdownFormField(airport, airports, (value) {
                setState(() {
                  airport = value!;
                  updateLatLongFromAirport(airport!);
                });
              }, "Airport"),
              buildTextFormField(controllerlat, (value) {
                setState(() {
                  latitudeValue = double.tryParse(value);
                });
              }, "Latitude"),
              buildTextFormField(controllerlong, (value) {
                setState(() {
                  longitudeValue = double.tryParse(value);
                });
              }, "Longitude"),
              if (selectedOption == 'Autopilot' || subOption == 'On Air')
                buildTextFormField(
                    TextEditingController(
                        text: altitudeValue?.toString() ?? ''), (value) {
                  setState(() {
                    altitudeValue = int.tryParse(value);
                  });
                }, "Altitude"),
              if (selectedOption == 'Autopilot')
                buildTextFormField(
                    TextEditingController(text: headingValue?.toString() ?? ''),
                    (value) {
                  setState(() {
                    headingValue = int.tryParse(value);
                  });
                }, "Heading"),
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
}
