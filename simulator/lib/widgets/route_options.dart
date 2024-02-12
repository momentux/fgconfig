import 'package:flutter/material.dart';

import '../utils/components.dart';
import '../utils/data_load.dart';
import '../utils/file_handlers.dart';

const String selectedOptionHint = 'Select Flying Mode';
const String subOptionHint = 'Select Sub Option';

class RouteOptionsCard extends StatefulWidget {
  final Function(double? latitudeValue, double? longitudeValue, int? altitudeValue, int? headingValue, bool? autoPilot, String? airport) onOptionsChanged;
  RouteOptionsCard({
    required this.onOptionsChanged,
  });

  @override
  _RouteOptionsCardState createState() => _RouteOptionsCardState();
}

class _RouteOptionsCardState extends State<RouteOptionsCard> {
  String? selectedOption = 'Autopilot';
  String? subOption;
  double? latitudeValue;
  double? longitudeValue;
  int? altitudeValue = 15000;
  int? headingValue = 120;
  String? airport = DataLoader().getAllAirportCodes()[0];
  List<String> airports = DataLoader().getAllAirportCodes();

  @override
  Widget build(BuildContext context) {
    TextEditingController _latController =
    TextEditingController(text: latitudeValue?.toString() ?? '');
    TextEditingController _longController =
    TextEditingController(text: longitudeValue?.toString() ?? '');
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleText('Route Options'),
            sizedRow([
              dropdownFormField(
                  selectedOption, ['Autopilot', 'Manual Flying'], (newValue) {
                setState(() {
                  selectedOption = newValue;
                  subOption = 'On Air';
                  widget.onOptionsChanged(latitudeValue, longitudeValue, altitudeValue, headingValue,selectedOption=='Autopilot', airport);
                });
              }, selectedOptionHint),
              if (selectedOption == 'Autopilot')
                fileUploadButton(movefileforautopilot),
              if (selectedOption == 'Manual Flying')
                dropdownFormField(subOption, ['On Air', 'On Airport'],
                    (newValue) {
                  setState(() {
                    subOption = newValue;
                    widget.onOptionsChanged(latitudeValue, longitudeValue, altitudeValue, headingValue,selectedOption=='Autopilot', airport);
                  });
                }, subOptionHint),
            ]),
            SizedBox(height: 20.0),  // Add a SizedBox widget here
            sizedRow([
              dropdownFormField(airport, airports, (value) {
                setState(() {
                  airport = value!;
                  updateLatLongFromAirport(airport!);
                });
              }, "Airport"),
              textFormField(_latController, (value) {
                setState(() {
                  latitudeValue = double.tryParse(value);
                  widget.onOptionsChanged(latitudeValue, longitudeValue, altitudeValue, headingValue,selectedOption=='Autopilot', airport);
                });
              }, "Latitude"),
              textFormField(_longController, (value) {
                setState(() {
                  longitudeValue = double.tryParse(value);
                  widget.onOptionsChanged(latitudeValue, longitudeValue, altitudeValue, headingValue,selectedOption=='Autopilot', airport);
                });
              }, "Longitude"),
              if (selectedOption == 'Autopilot' || subOption == 'On Air')
                textFormField(
                    TextEditingController(
                        text: altitudeValue?.toString() ?? ''), (value) {
                  setState(() {
                    altitudeValue = int.tryParse(value);
                    widget.onOptionsChanged(latitudeValue, longitudeValue, altitudeValue, headingValue,selectedOption=='Autopilot', airport);
                  });
                }, "Altitude"),
              if (selectedOption == 'Autopilot')
                textFormField(
                    TextEditingController(text: headingValue?.toString() ?? ''),
                    (value) {
                  setState(() {
                    headingValue = int.tryParse(value);
                    widget.onOptionsChanged(latitudeValue, longitudeValue, altitudeValue, headingValue,selectedOption=='Autopilot', airport);
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