import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:simulator/utils/data_load.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

import 'dart:typed_data';

List<String> contents = [];

class LaunchManagementScreen extends StatefulWidget {
  @override
  _RouteOptionsCardState createState() => _RouteOptionsCardState();
}

class _RouteOptionsCardState extends State<LaunchManagementScreen> {
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
  String _filePath = '';

  // New variable to track whether UDP transmission is ongoing
  bool socketClosed = false;
  late RawDatagramSocket socket;
  bool bypassStopped = false;

  String? filename;
  bool isServiceUp = false;
  bool isServiceUp2 = false;
  bool isServiceUp3 = false;
  bool isServiceUp4 = false;
  bool isServiceUp5 = false;
  late Timer _timer;
  late Timer _timer2;
  late Timer _timer3;
  late Timer _timer4;
  late Timer _timer5;
  bool _isVisible = true;
  bool _isVisible2 = true;
  bool _isVisible3 = true;
  bool _isVisible4 = true;
  bool _isVisible5 = true;
  late Process flightGearProcess;
  late Process _process;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _isVisible = !_isVisible;
      });
    });

    _timer2 = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _isVisible2 = !_isVisible2;
      });
    });

    _timer3 = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _isVisible3 = !_isVisible3;
      });
    });

    _timer4 = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _isVisible4 = !_isVisible4;
      });
    });
    _timer5 = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _isVisible5 = !_isVisible5;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _timer2.cancel();
    _timer3.cancel();
    _timer4.cancel();
    _timer5.cancel();

    super.dispose();
  }

  // New variable to store the contents of the uploaded file
  List<String> fileContents = [];
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
          child: Card(
            margin: EdgeInsets.all(16.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Route Options',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(children: [
                    Expanded(
                      flex: 1, // Adjust the flex factor if needed for sizing
                      child: DropdownButton<String>(
                        value: selectedOption,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedOption = newValue;
                            subOption = 'Select Sub Option';
                          });
                        },
                        items: <String?>[
                          'Select Flying Mode',
                          'Autopilot',
                          'Manual Flying'
                        ].map<DropdownMenuItem<String>>((String? value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value ?? ''),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    if (selectedOption == 'Manual Flying')
                      Expanded(
                          child: DropdownButton<String>(
                        value: subOption,
                        onChanged: (String? newValue) {
                          setState(() {
                            subOption = newValue;
                          });
                        },
                        items: <String?>[
                          'Select Sub Option',
                          'On Air',
                          'On Airport'
                        ].map<DropdownMenuItem<String>>((String? value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value ?? ''),
                          );
                        }).toList(),
                      )),
                    if (selectedOption == 'Autopilot')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles();

                            if (result != null) {
                              // User picked a file
                              String filePath = result.files.single.path!;
                              print('Selected file: $filePath');

                              // Implement your logic for handling the selected file here
                              // This could involve passing the file path to your FlightGear launch logic
                              await movefileforautopilot(filePath);
                            } else {
                              // User canceled the file picker
                              print('File picking canceled.');
                            }
                          },
                          child: Text('Upload File'),
                        ),
                      ),
                  ]),
                  SizedBox(height: 16.0),
                  if (selectedOption == 'Autopilot')
                    Row(
                      children: [
                        SizedBox(width: 16.0),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: airport,
                            onChanged: (value) {
                              setState(() {
                                airport = value!;
                                // Call the function to update latitude and longitude based on the selected airport
                                updateLatLongFromAirport(airport!);
                              });
                            },
                            items: airports.map((airport) {
                              return DropdownMenuItem<String>(
                                value: airport,
                                child: Text(airport),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: "Airport",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: TextFormField(
                            controller: _controllerlat,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                latitudeValue = double.tryParse(value);
                                // Parse the input to a double
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: "Latitude",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: TextFormField(
                            controller: _controllerlong,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                longitudeValue = double.tryParse(
                                    value); // Parse the input to a double
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: "Longitude",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                altitudeValue = int.tryParse(value);

                                // Parse the input to a double
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: "Altitude",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                headingValue = int.tryParse(value);

                                // Parse the input to a double
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
                  if (subOption == 'On Air')
                    Row(
                      children: [
                        SizedBox(width: 16.0),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: airport,
                            onChanged: (value) {
                              setState(() {
                                airport = value!;
                                // Call the function to update latitude and longitude based on the selected airport
                                updateLatLongFromAirport(airport!);
                              });
                            },
                            items: airports.map((airport) {
                              return DropdownMenuItem<String>(
                                value: airport,
                                child: Text(airport),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: "Airport",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: TextFormField(
                            controller: _controllerlat,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                latitudeValue = double.tryParse(value);
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: "Latitude",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: TextFormField(
                            controller: _controllerlong,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                longitudeValue = double.tryParse(value);
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: "Longitude",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                altitudeValue = int.tryParse(value);
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: "Altitude",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (subOption == 'On Airport')
                    Row(
                      children: [
                        SizedBox(width: 16.0),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: airport,
                            onChanged: (value) {
                              setState(() {
                                airport = value!;
                                // Call the function to update latitude and longitude based on the selected airport
                                updateLatLongFromAirport(airport!);
                              });
                            },
                            items: airports.map((airport) {
                              return DropdownMenuItem<String>(
                                value: airport,
                                child: Text(airport),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: "Airport",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: TextFormField(
                            controller: _controllerlat,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                latitudeValue = double.tryParse(value);
                                // Parse the input to a double
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: "Latitude",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: TextFormField(
                            controller: _controllerlong,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                longitudeValue = double.tryParse(
                                    value); // Parse the input to a double
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: "Longitude",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          child: Card(
            margin: EdgeInsets.all(16.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target Options',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(width: 16.0),
                      Expanded(
                        child: DropdownButton<String>(
                          value: targetOption,
                          onChanged: (String? newValue) {
                            setState(() {
                              targetOption = newValue;
                              targetSubOption = 'Select Sub Option';
                            });
                          },
                          items: <String?>[
                            'Select Target Option',
                            'FG AI Scenario',
                            'Manual AI Scenario'
                          ].map<DropdownMenuItem<String>>((String? value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value ?? ''),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      if (targetOption == 'FG AI Scenario')
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles();

                              if (result != null) {
                                // User picked a file
                                String filePath = result.files.single.path!;
                                print('Selected file: $filePath');

                                // Implement your logic for handling the selected file here
                                // This could involve passing the file path to your FlightGear launch logic
                                await movefileforfgaiscenario(filePath);
                              } else {
                                // User canceled the file picker
                                print('File picking canceled.');
                              }
                            },
                            child: Text('Upload File'),
                          ),
                        ),
                      SizedBox(width: 16.0),
                      if (targetOption == 'Manual AI Scenario' ||
                          targetOption == 'FG AI Scenario')
                        Expanded(
                          child: DropdownButton<String>(
                            value: typeOfTarget,
                            onChanged: (String? newValue) {
                              setState(() {
                                typeOfTarget = newValue;
                              });
                            },
                            items: <String?>[
                              'Select Target',
                              'Air Target',
                              'Sea Target',
                              'Ground Target'
                            ].map<DropdownMenuItem<String>>((String? value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value ?? ''),
                              );
                            }).toList(),
                          ),
                        ),
                      SizedBox(width: 16.0),
                      if (targetOption == 'Manual AI Scenario')
                        Expanded(
                          child: DropdownButton<String>(
                            value: targetSubOption,
                            onChanged: (String? newValue) {
                              setState(() {
                                targetSubOption = newValue;
                              });
                            },
                            items: <String?>[
                              'Select Sub Option',
                              'Replay Recorded Data',
                              'Bypass FG'
                            ].map<DropdownMenuItem<String>>((String? value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value ?? ''),
                              );
                            }).toList(),
                          ),
                        ),
                      SizedBox(width: 16.0),
                      if (targetSubOption == 'Replay Recorded Data')
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles();

                              if (result != null) {
                                // User picked a file
                                String filePath = result.files.single.path!;
                                print('Selected file: $filePath');

                                // Implement your logic for handling the selected file here
                                // This could involve passing the file path to your FlightGear launch logic
                                await movefileformanualai(filePath);
                              } else {
                                // User canceled the file picker
                                print('File picking canceled.');
                              }
                            },
                            child: Text('Upload File'),
                          ),
                        ),
                      SizedBox(width: 16.0),
                      if (targetSubOption == 'Bypass FG')
                        // Bypass FG scenario
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _pickFile,
                            child: Text('Upload Text/CSV File'),
                          ),
                        )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 100.0,
              margin: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Flight Gear',
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
                      color: _isVisible
                          ? (isServiceUp ? Colors.green : Colors.red)
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
            ),
            Container(
              width: 100.0,
              margin: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'FG Devices',
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
                      color: _isVisible2
                          ? (isServiceUp2 ? Colors.green : Colors.red)
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
            ),
            Container(
              width: 100.0,
              margin: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Mil-1553',
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
                      color: _isVisible3
                          ? (isServiceUp3 ? Colors.green : Colors.red)
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
            ),
            Container(
              width: 200.0, // Adjust the width as needed
              margin: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HMCS',
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
                          color: _isVisible4
                              ? (isServiceUp4 ? Colors.green : Colors.red)
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
                  Switch(
                    value: isServiceUp4,
                    onChanged: (value) {
                      setState(() {
                        isServiceUp4 = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            Container(
              width: 100.0,
              margin: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Arinc',
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
                      color: _isVisible4
                          ? (isServiceUp5 ? Colors.green : Colors.red)
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
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Launch Button
            ElevatedButton(
              onPressed: () {
                // Add your launch logic here
                print('Launching');

                // Run headsensor in the background and minimize
                _runHeadSensor();

                _startjsapp();

                // Collect data including latitude, longitude, and altitude values
                Map<String, dynamic> launchData = collectData();

                // Convert data to JSON
                String json = jsonEncode(launchData);

                // Modify the content of the .fgsrc file
                modifyFgSrcFile(json);

                // Run FlightGear in the background and minimize
                _runFlightGear();

                //_sendFileContent();
                //launch mill app
                launchMilApp();
                launcharinc();
              },
              child: Text('Launch'),
            ),

            // Stop Button
            ElevatedButton(
              onPressed: () {
                // Add your stop logic here
                print('Stopping');
                _stopjsapp('JsApp.exe');
                _stopHeadSensor();
                // Stop FlightGear and update state
                _stopFlightGear();
                // stop mill app
                stopMilApp();
                stoparinc();
                stopByPass();
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

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path!;
      });
    }
  }

  void reverse2Byte(List<int> data, int number) {
    int b1, b2;
    for (int i = 0; i < number; ++i) {
      b1 = data[i] >> 8;
      b2 = data[i] & 0x00ff;
      data[i] = b2 << 8 | b1;
    }
  }

  void reverse4Byte(List<int> data, int number) {
    int w1, w2;
    for (int i = 0; i < number; ++i) {
      w1 = data[i] >> 16;
      w2 = data[i] & 0x0000ffff;
      reverse2Byte([w1], 1);
      reverse2Byte([w2], 1);
      data[i] = w2 << 16 | w1;
    }
  }

  void reverse8Byte(List<int> data, int number) {
    int w1, w2;
    for (int i = 0; i < number; ++i) {
      w1 = data[i] >> 32;
      w2 = data[i] & 0x00000000ffffffff;
      reverse4Byte([w1], 1);
      reverse4Byte([w2], 1);
      data[i] = w2 | (w1 << 32);
    }
  }

  Future<void> _sendFileContent() async {
    if (_filePath.isNotEmpty) {
      // Read the CSV file
      List<String> csvLines = File(_filePath).readAsStringSync().split('\n');

      // Process each row
      List<List<num>> processedRows = [];
      for (String line in csvLines) {
        if (line.isNotEmpty) {
          List<num> row = parseRow(line);
          processRow(row);
          print(row);
          //processedRows.add(row);
        }
      }
      // Convert the processed rows to binary format
      print(processedRows);
      List<List<int>> binaryRows =
          processedRows.map((row) => convertToBinary(row)).toList();

      // Print or save the binary data as needed
      for (List<int> binaryRow in binaryRows) {
        print(binaryRow);
      }
    }
  }

  List<num> parseRow(String line) {
    List<String> values = line.split(',');
    return values.map((value) => num.parse(value)).toList();
  }

  void processRow(List<num> row) {
    // Determine the size of each value in bytes and apply the corresponding reverse function
    for (int i = 0; i < row.length; i++) {
      int byteSize = calculateByteSize(row[i]);
      switch (byteSize) {
        case 2:
          reverse2Byte([row[i].toInt()], 1);
          break;
        case 4:
          reverse4Byte([row[i].toInt()], 1);
          break;
        case 8:
          if (row[i] is double) {
            reverse8ByteDouble([row[i].toDouble()], 1);
          } else {
            reverse8Byte([row[i].toInt()], 1);
          }
          break;
        // Add more cases if needed for other byte sizes
      }
    }
  }

  int calculateByteSize(num value) {
    // Calculate the byte size of the value
    return (value is int) ? (value.bitLength / 8).ceil() : 8;
  }

  List<int> convertToBinary(List<num> row) {
    // Convert each value to its binary representation
    List<String> binaryValues = row
        .map((value) =>
            (value is int) ? value.toRadixString(2) : value.toStringAsFixed(6))
        .toList();

    // Join the binary values and convert the result to bytes
    String binaryString = binaryValues.join('');
    List<int> binaryData = utf8.encode(binaryString);

    return binaryData;
  }

  void reverse8ByteDouble(List<double> data, int number) {
    int d1, d2;
    for (int i = 0; i < number; ++i) {
      // Convert double to 8-byte integer representation
      int intValue = data[i].toInt();
      ByteData byteData = ByteData(8);
      byteData.setFloat64(0, data[i], Endian.little);
      d1 = byteData.getInt32(0);
      d2 = byteData.getInt32(4);

      // Reverse the byte order of each 4-byte integer
      reverse4Byte([d1], 1);
      reverse4Byte([d2], 1);

      // Combine the reversed 4-byte integers back into an 8-byte integer
      int reversedValue = d2 << 32 | d1;

      // Create a new ByteData instance to store the reversed value
      ByteData reversedByteData = ByteData(8);
      reversedByteData.setInt64(0, reversedValue);

      // Set the reversed value back to the original double
      data[i] = reversedByteData.getFloat64(0, Endian.little);
    }
  }

  void stopByPass() {
    bypassStopped = true;
    // if (socket != null && !socketClosed) {
    //   socket.close();
    //   socketClosed = true;
    // }
  }

  final String serverUrl = "http://134.32.20.102:5003";
  void launchMilApp() async {
    try {
      await http.post(Uri.parse('$serverUrl/launch'));
      print('mill app launched successfully.');
      setState(() {
        isServiceUp3 = true;
      });
    } catch (e) {
      print('Failed to launch mill app: $e');
    }
  }

  void stopMilApp() async {
    try {
      await http.post(Uri.parse('$serverUrl/stop'));
      print('mill app stopped successfully.');
      setState(() {
        isServiceUp3 = false;
      });
    } catch (e) {
      print('Failed to stop mill app: $e');
    }
  }

  void launcharinc() async {
    try {
      await http.post(Uri.parse('$serverUrl/launcharinc'));
      print('arinc app launched successfully.');
      setState(() {
        isServiceUp5 = true;
      });
    } catch (e) {
      print('Failed to launch arinc app: $e');
    }
  }

  void stoparinc() async {
    try {
      await http.post(Uri.parse('$serverUrl/stoparinc'));
      print('arinc app stopped successfully.');
      setState(() {
        isServiceUp5 = false;
      });
    } catch (e) {
      print('Failed to stop arinc app: $e');
    }
  }

  // Function to update latitude and longitude based on the selected airport
  void updateLatLongFromAirport(String selectedAirport) {
    // Find the airport data based on the selected code
    Airport temp = DataLoader().getAirport(selectedAirport)!;
    print(temp.latitude);
    print(temp.longitude);

    setState(() {
      latitudeValue = temp.latitude;
      longitudeValue = temp.longitude;
    });
  }

  // Update the collectData method
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
      'isServiceUp': isServiceUp,
      'isServiceUp2': isServiceUp2,
      'isServiceUp3': isServiceUp3,
      'isServiceUp4': isServiceUp4,
      'filename': filename,
    };
    print(data);
    // Conditionally add entry based on the value of 'subOption'
    if (subOption == 'On Air' || subOption == 'On Airport') {
      data['state'] = 'cruise';
    } else {
      data['state'] = 'cruise';
    }

    return data;
  }

  late String destinationPath;
  // Add this method to move the uploaded file to the desired location
  Future<void> movefileforautopilot(String filePath) async {
    try {
      // Specify the desired location
      String desiredLocation = r'C:\Users\scl\Flightgear\config';

      // Create the desired location directory if it doesn't exist
      await Directory(desiredLocation).create(recursive: true);

      // Extract the file name from the path
      String fileName = path.basename(filePath);

      // Build the destination path in the desired location
      destinationPath = path.join(desiredLocation, fileName);

      // Move the file to the desired location
      await File(filePath).copy(destinationPath);

      print('File moved to: $destinationPath');

      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          // Capture the context before the async gap
          final currentContext = context;

          return AlertDialog(
            title: const Text(" XML uploaded"),
            content: const Text("Route XML file uploaded successfully!"),
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
      print('Error moving file: $e');
    }
  }

  late String destinationPathforscenario;
  // Add this method to move the uploaded file to the desired location
  Future<void> movefileforfgaiscenario(String filePath) async {
    try {
      // Specify the desired location
      String desiredLocation =
          r'C:\Users\scl\Flightgear\Aircrafts\f16\Scenarios\';

      // Create the desired location directory if it doesn't exist
      await Directory(desiredLocation).create(recursive: true);

      // Extract the file name from the path
      String fileName = path.basename(filePath);
      String fileNameWithoutExtension = path.basenameWithoutExtension(fileName);

      setState(() {
        filename = fileNameWithoutExtension;
      });

      // Build the destination path in the desired location
      destinationPathforscenario = path.join(desiredLocation, fileName);

      // Move the file to the desired location
      await File(filePath).copy(destinationPathforscenario);
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          // Capture the context before the async gap
          final currentContext = context;

          return AlertDialog(
            title: const Text(" XML uploaded"),
            content: const Text("Scenario XML file uploaded successfully!"),
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

      print('File moved to: $destinationPathforscenario');
    } catch (e) {
      print('Error moving file: $e');
    }
  }

  late String destinationPathformanualaiscenario;
  // Add this method to move the uploaded file to the desired location
  Future<void> movefileformanualai(String filePath) async {
    try {
      // Specify the desired location
      String desiredLocation =
          r'C:\Users\scl\Flightgear\Aircrafts\f16\Scenarios\';

      // Create the desired location directory if it doesn't exist
      await Directory(desiredLocation).create(recursive: true);

      // Extract the file name from the path
      String fileName = path.basename(filePath);

      // Build the destination path in the desired location
      destinationPathformanualaiscenario = path.join(desiredLocation, fileName);

      // Move the file to the desired location
      await File(filePath).copy(destinationPathforscenario);
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          // Capture the context before the async gap
          final currentContext = context;

          return AlertDialog(
            title: const Text(" XML uploaded"),
            content: const Text("Scenario XML file uploaded successfully!"),
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

      print('File moved to: $destinationPathformanualaiscenario');
    } catch (e) {
      print('Error moving file: $e');
    }
  }

  void modifyFgSrcFile(json) {
    // Specify the path to your .fgsrc file
    String fgSrcFilePath = r'C:\Users\scl\.fgfsrc';
    Map<String, dynamic> jsonData = jsonDecode(json);

    try {
      // Read the existing content of the .fgsrc file
      String existingContent = File(fgSrcFilePath).readAsStringSync();

      // Update latitude, longitude, and altitude values in the existing content
      existingContent = existingContent.replaceAll(
        RegExp(r'--lat=.*'),
        '--lat=${jsonData["latitudeValue"]}',
      );
      existingContent = existingContent.replaceAll(
        RegExp(r'--lon=.*'),
        '--lon=${jsonData["longitudeValue"]}',
      );
      existingContent = existingContent.replaceAll(
        RegExp(r'--altitude=.*'),
        '--altitude=${jsonData["altitudeValue"]}',
      );
      // Update the aircraft state
      existingContent = existingContent.replaceAll(
        RegExp(r'--state=.*'),
        '--state=${jsonData["state"]}',
      );
      existingContent = existingContent.replaceAll(
        RegExp(r'--heading=.*'),
        '--heading=${jsonData["headingValue"]}',
      );
      existingContent = existingContent.replaceAll(
        RegExp(r'--prop:/instrumentation/heading-indicator/heading-bug-deg=.*'),
        '--prop:/instrumentation/heading-indicator/heading-bug-deg=${jsonData["headingValue"]}',
      );
      // Check if uploadautopilot is true
      if (jsonData["selectedOption"] == "Autopilot") {
        //on air to autopilot
        if (existingContent.contains('#--altitude=') &&
            existingContent.contains('#--in-air') &&
            existingContent.contains('#--vc=')) {
          existingContent = existingContent.replaceAll(
            RegExp(r'#--altitude=.*'),
            '#--altitude=${jsonData["altitudeValue"]}',
          );
          existingContent = existingContent.replaceAll(
            RegExp(r'#--lat=.*'),
            '#--lat=${jsonData["latitudeValue"]}',
          );
          existingContent = existingContent.replaceAll(
            RegExp(r'#--lon=.*'),
            '#--lon=${jsonData["longitudeValue"]}',
          );
          print("fgrrh");
        }
        //on airport to autopilot
        if (existingContent.contains('#--altitude=') &&
            existingContent.contains('#--in-air') &&
            existingContent.contains('#--vc=') &&
            existingContent.contains('--runway=')) {
          existingContent = existingContent.replaceAll(
            RegExp(r'--lat=.*'),
            '#--lat=${jsonData["latitudeValue"]}',
          );
          existingContent = existingContent.replaceAll(
            RegExp(r'--lon=.*'),
            '#--lon=${jsonData["longitudeValue"]}',
          );
          existingContent = existingContent.replaceAll(
            RegExp(r'--altitude=.*'),
            '#--altitude=${jsonData["altitudeValue"]}',
          );
          existingContent = existingContent.replaceAll(
            RegExp(r'#--vc=.*'),
            '--vc=600',
          );
          existingContent = existingContent.replaceAll(
            RegExp(r'--runway=.*'),
            '#--runway=active',
          );
          existingContent = existingContent.replaceAll(
            RegExp(r'#--in-air'),
            '--in-air',
          );
        }
        //autopilot to autopilot
        if (existingContent.contains('--lat=') &&
            existingContent.contains('#--runway=')) {
          print("nochange");
        }
        // Uncomment the Autopilot block
        if (existingContent.contains('#### Autopilot')) {
          existingContent = existingContent.replaceAllMapped(
            RegExp(r'#### Autopilot([\s\S]*?)####'),
            (match) => match.group(0)!.split('\n').map((line) {
              // Remove '#' from the beginning of each line
              if (line.startsWith('#')) {
                return line.substring(1);
              }
              return line;
            }).join('\n'),
          );
        }
//         else {
//           // If Autopilot block doesn't exist, add the entire Autopilot block
//           existingContent += '''
// ### Autopilot
// --prop:/f16/fcs/switch-pitch-block20=1
// --prop:/f16/fcs/switch-roll-block20=-1
// --prop:/instrumentation/heading-indicator/heading-bug-deg=120
// ###
// ''';
//         }
      } else {
        if (existingContent.contains('### Autopilot')) {
          // Check if the Autopilot block is not already commented
          if (!existingContent.contains('#### Autopilot')) {
            // Comment out the Autopilot block
            existingContent = existingContent.replaceAllMapped(
              RegExp(r'### Autopilot([\s\S]*?)###'),
              (match) => match
                  .group(0)!
                  .split('\n')
                  .map((line) => '#$line')
                  .join('\n'),
            );
          }
          if (jsonData["subOption"] == "On Air") {
            //autopilot to on air
            if (existingContent.contains('--lat=') &&
                existingContent.contains('--lon=') &&
                existingContent.contains('--altitude=')) {
              existingContent = existingContent.replaceAll(
                RegExp(r'--lat=.*'),
                '--lat=${jsonData["latitudeValue"]}',
              );
              existingContent = existingContent.replaceAll(
                RegExp(r'--lon=.*'),
                '--lon=${jsonData["longitudeValue"]}',
              );
              existingContent = existingContent.replaceAll(
                RegExp(r'--altitude=.*'),
                '--altitude=${jsonData["altitudeValue"]}',
              );
              existingContent = existingContent.replaceAll(
                RegExp(r'#--runway=.*'),
                '#--runway=active',
              );
              print("manual on air activated");
            }
            // on air to on air
            else if (existingContent.contains('--altitude=') &&
                existingContent.contains('--in-air') &&
                existingContent.contains('--vc=') &&
                existingContent.contains('#--runway=')) {
              print("nochange");
            }
            //on airport to on air
            else if (existingContent.contains('#--altitude=') &&
                existingContent.contains('#--in-air') &&
                existingContent.contains('#--vc=') &&
                existingContent.contains('--runway=')) {
              existingContent = existingContent.replaceAll(
                RegExp(r'#--altitude=.*'),
                '--altitude=${jsonData["altitudeValue"]}',
              );
              existingContent = existingContent.replaceAll(
                RegExp(r'--runway=.*'),
                '#--runway=active',
              );
              existingContent = existingContent.replaceAll(
                RegExp(r'#--vc=.*'),
                '--vc=600',
              );
              existingContent = existingContent.replaceAll(
                RegExp(r'#--in-air'),
                '--in-air',
              );
              print("manual flying on air");
            }
            //
            else {}
          }
          if (jsonData["subOption"] == "On Airport") {
            //autopilot to on airport
            if (existingContent.contains('--lat=') &&
                existingContent.contains('--lon=') &&
                existingContent.contains('--altitude=')) {
              existingContent = existingContent.replaceAll(
                RegExp(r'#--lat=.*'),
                '--lat=${jsonData["latitudeValue"]}',
              );
              existingContent = existingContent.replaceAll(
                RegExp(r'--lon=.*'),
                '--lon=${jsonData["longitudeValue"]}',
              );
              existingContent = existingContent.replaceAll(
                RegExp(r'--altitude=.*'),
                '#--altitude=${jsonData["altitudeValue"]}',
              );
              existingContent = existingContent.replaceAll(
                RegExp(r'#--runway=.*'),
                '--runway=active',
              );
              existingContent = existingContent.replaceAll(
                RegExp(r'--vc=.*'),
                '#--vc=600',
              );
              existingContent = existingContent.replaceAll(
                RegExp(r'--in-air'),
                '#--in-air',
              );
              print("manual flying on airport");
            }
            //on airport to on airport
            else if (existingContent.contains('--altitude=') &&
                existingContent.contains('#--in-air') &&
                existingContent.contains('#--vc=') &&
                existingContent.contains('--runway=')) {
              print("nochange");
            }
            //on air to airport
            else if (existingContent.contains('--altitude=') &&
                existingContent.contains('--in-air') &&
                existingContent.contains('#--runway') &&
                existingContent.contains('--vc')) {
              existingContent = existingContent.replaceAll(
                RegExp(r'--altitude=.*'),
                '#--altitude=${jsonData["altitudeValue"]}',
              );
              existingContent = existingContent.replaceAll(
                RegExp(r'--vc=.*'),
                '#--vc=600',
              );
              existingContent = existingContent.replaceAll(
                RegExp(r'--in-air'),
                '#--in-air',
              );
              existingContent = existingContent.replaceAll(
                RegExp(r'#--runway=.*'),
                '--runway=active',
              );
              print("gbbrtrn");
            } else {}
          }
        } else {
          print("fgegg");
        }
      }

      if (jsonData["targetOption"] == "FG AI Scenario") {
        existingContent = existingContent.replaceAll(
          RegExp(r'--ai-scenario=.*'),
          '--ai-scenario=${jsonData["filename"]}',
        );
        if (jsonData["typeOfTarget"] == "Air Target") {
          // Replace "AIRCSV" in the first generic line
          existingContent = existingContent.replaceAll(
            RegExp(r'--generic=file,out,10,C:\\Users\\scl\\Flightgear\\.*'),
            '--generic=file,out,10,C:\\Users\\scl\\Flightgear\\airtarget.csv,AIRCSV',
          );

          // Replace "AIR" in the second generic line
          existingContent = existingContent.replaceAll(
            RegExp(r'--generic=socket,out,10,134.32.255.255,5505,udp,.*'),
            '--generic=socket,out,10,134.32.255.255,5505,udp,AIR',
          );
        }

        if (jsonData["typeOfTarget"] == "Sea Target") {
          // Replace "AIRCSV" in the first generic line
          existingContent = existingContent.replaceAll(
            RegExp(r'--generic=file,out,10,C:\\Users\\scl\\Flightgear\\.*'),
            '--generic=file,out,10,C:\\Users\\scl\\Flightgear\\shiptarget.csv,SHIPCSV',
          );

          // Replace "AIR" in the second generic line
          existingContent = existingContent.replaceAll(
            RegExp(r'--generic=socket,out,10,134.32.255.255,5505,udp,.*'),
            '--generic=socket,out,10,134.32.255.255,5505,udp,SHIP',
          );
        }
        if (jsonData["typeOfTarget"] == "Ground Target") {
          // Replace "AIRCSV" in the first generic line
          existingContent = existingContent.replaceAll(
            RegExp(r'--generic=file,out,10,C:\\Users\\scl\\Flightgear\\.*'),
            '--generic=file,out,10,C:\\Users\\scl\\Flightgear\\airtarget.csv,GROUNDCSV',
          );

          // Replace "AIR" in the second generic line
          existingContent = existingContent.replaceAll(
            RegExp(r'--generic=socket,out,10,134.32.255.255,5505,udp,.*'),
            '--generic=socket,out,10,134.32.255.255,5505,udp,GROUND',
          );
        }
      } else {
        if (jsonData["targetSubOption"] == "Replay Recorded Data") {
          // Comment out existing --prop lines between "### Scenarios" and "##"

          // Add the new scenario line under the "### Scenarios" section
          existingContent += '\n### Scenarios\n';
          existingContent +=
              '--prop:/sim/ai/scenario="$destinationPathformanualaiscenario"\n';
          existingContent +=
              '##\n'; // Assuming "##" marks the end of the "### Scenarios" section}
        }

        if (jsonData["targetSubOption"] == "Bypass FG") {
          if (existingContent.contains(
              '#--generic=file,out,10,C:\\Users\\scl\\Flightgear\\airtarget.csv,AIRCSV')) {
            print("nochange");
          } else {
            // Comment out the generic lines
            existingContent = existingContent.replaceAll(
              '--generic=file,out,10,C:\\Users\\scl\\Flightgear\\airtarget.csv,AIRCSV',
              '#--generic=file,out,10,C:\\Users\\scl\\Flightgear\\airtarget.csv,AIRCSV',
            );

            existingContent = existingContent.replaceAll(
              '--generic=file,out,10,C:\\Users\\scl\\Flightgear\\shiptarget.csv,SHIPCSV',
              '#--generic=file,out,10,C:\\Users\\scl\\Flightgear\\shiptarget.csv,SHIPCSV',
            );

            existingContent = existingContent.replaceAll(
              '--generic=file,out,10,C:\\Users\\scl\\Flightgear\\groundtarget.csv,GROUNDCSV',
              '#--generic=file,out,10,C:\\Users\\scl\\Flightgear\\groundtarget.csv,GROUNDCSV',
            );

            existingContent = existingContent.replaceAllMapped(
              RegExp(r'(.*--generic=socket,out,.*?udp,AIR.*)', multiLine: true),
              (match) => '#${match.group(1)}',
            );

            existingContent = existingContent.replaceAllMapped(
              RegExp(r'(.*--generic=socket,out,.*?udp,SHIP.*)',
                  multiLine: true),
              (match) => '#${match.group(1)}',
            );

            existingContent = existingContent.replaceAllMapped(
              RegExp(r'(.*--generic=socket,out,.*?udp,GROUND.*)',
                  multiLine: true),
              (match) => '#${match.group(1)}',
            );
          }
        }
      }
      // Write the modified content back to the .fgsrc file
      File(fgSrcFilePath).writeAsStringSync(existingContent);
    } catch (e) {
      print('Error modifying .fgsrc file: $e');
    }
  }

  void _startjsapp() async {
    try {
      const executablePath =
          r'C:\JsApp\X64\Release\JsApp.exe'; // Update with your executable path

      // For Windows, minimize the window using native command
      if (Platform.isWindows) {
        _process = await Process.start(
            'cmd', ['/c', 'start', '/min', '""', executablePath]);
        print('Process started in a minimized state');
        setState(() {
          isServiceUp2 = true;
        });
      }
    } catch (e) {
      print('Error starting process: $e');
    }
  }

  Future<void> _runFlightGear() async {
    try {
      // Replace 'C:/Path/To/FlightGear/fgfs.exe' with the actual path to your FlightGear executable
      flightGearProcess = await Process.start(
        r'C:\Program Files\FlightGear 2020.3\bin\fgfs.exe',
        [], // Add any additional command-line options as needed
      );
      //Update state to indicate FG-1 is running
      setState(() {
        isServiceUp = true;
      });
      print('FlightGear process ID: ${flightGearProcess.pid}');
    } catch (e) {
      print('Error running FlightGear: $e');
    }
  }

  final String headsensorserverUrl = "http://127.0.0.1:5004";
  Future<void> _runHeadSensor() async {
    try {
      final result = await Process.run(
          r'C:\Users\scl\AppData\Local\Programs\Python\Python38\python.exe',
          [r'C:\Users\scl\Flightgear\HMCS\HeadSensorReciever.py']);
      int pid = result.pid;
      print('Process ID (PID): $pid');
      print('Exit code: ${result.exitCode}');
      print('Stdout: ${result.stdout}');
      print('Stderr: ${result.stderr}');
      //await http.post(Uri.parse('$headsensorserverUrl/start'));
      //print('head sensor app start successfully.');

      setState(() {
        isServiceUp4 = true;
      });
    } catch (e) {
      print('Failed to launch mill app: $e');
    }
  }

  Future<void> _stopHeadSensor() async {
    try {
      final result = await Process.run(
          r'C:\Users\scl\AppData\Local\Programs\Python\Python38\python.exe',
          [r'C:\Users\scl\Flightgear\joystick\killscripts.py']);
      int pid = result.pid;
      print('Process ID (PID): $pid');
      print('Exit code: ${result.exitCode}');
      print('Stdout: ${result.stdout}');
      print('Stderr: ${result.stderr}');

      //await http.post(Uri.parse('$headsensorserverUrl/stop'));
      //print('head sensor app stop successfully.');
      setState(() {
        isServiceUp4 = false;
      });
    } catch (e) {
      print('Failed to launch mill app: $e');
    }
  }

  // Future<void> runPythonScript() async {
  //   final result = await Process.run(
  //       r'C:\Users\scl\AppData\Local\Programs\Python\Python38\python.exe',
  //       [r'C:\Users\scl\Flightgear\joystick\runscripts.py']);
  //   int pid = result.pid;
  //   print('Process ID (PID): $pid');
  //   print('Exit code: ${result.exitCode}');
  //   print('Stdout: ${result.stdout}');
  //   print('Stderr: ${result.stderr}');
  //   // Update state to indicate FG-1 is not running
  //   setState(() {
  //     isServiceUp2 = true;
  //   });
  // }

  Future<void> _stopFlightGear() async {
    // Check if the FlightGear process is running
    if (isServiceUp) {
      // Kill the FlightGear process
      await flightGearProcess.kill();

      // Update state to indicate FG-1 is not running
      setState(() {
        isServiceUp = false;
      });

      print('FlightGear stopped.');
    } else {
      print('FlightGear is not running.');
    }
  }

  Future<void> _stopjsapp(String processName) async {
    if (isServiceUp2) {
      Process.run('taskkill', ['/F', '/IM', processName])
          .then((ProcessResult results) {
        if (results.exitCode == 0) {
          print('Process $processName terminated successfully.');
        } else {
          print(
              'Failed to terminate process $processName. Exit code: ${results.exitCode}');
          print('Error: ${results.stderr}');
        }
      });
      setState(() {
        isServiceUp2 = false;
      });
    }
  }

  Future<void> _stopRunScripts() async {
    // Check if the FlightGear process is running
    if (isServiceUp4) {
      final result = await Process.run(
          r'C:\Users\scl\AppData\Local\Programs\Python\Python38\python.exe',
          [r'C:\Users\scl\Flightgear\joystick\killscripts.py']);
      int pid = result.pid;
      print('Process ID (PID): $pid');
      print('Exit code: ${result.exitCode}');
      print('Stdout: ${result.stdout}');
      print('Stderr: ${result.stderr}');
      setState(() {
        isServiceUp4 = false;
      });

      print('Head Mount Calibiration Sensor stopped.');
    } else {
      print('Head Mount Calibiration Sensor is not running.');
    }
  }
}
