import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'fgfsrc.dart';

enum Service {
  flightGear,
  jsApp,
  mil,
  hmds,
  arinc,
}

class ServiceHandler {
  late Process flightGearProcess;
  final Map<Service, bool> _serviceStates = {
    for (var e in Service.values) e: false
  };
  Map<Service, bool> get serviceStates => _serviceStates;
  final String serverUrl = "http://134.32.20.102:5003";

  Future<void> _runFlightGear(launchData) async {
    try {
      flightGearProcess = await Process.start(
        r'C:\Program Files\FlightGear 2020.3\bin\fgfs.exe',
        [],
      );
      _serviceStates[Service.flightGear] = true;
      print('FlightGear process ID: ${flightGearProcess.pid}');
      String json = jsonEncode(launchData);
      await modifyFgSrcFile(json);
    } catch (e) {
      print('Error running FlightGear: $e');
    }
  }

  Future<void> _stopFlightGear() async {
    if (_serviceStates[Service.flightGear]!) {
      await flightGearProcess.kill();
      _serviceStates[Service.flightGear] = false;
      print('FlightGear stopped.');
    } else {
      print('FlightGear is not running.');
    }
  }

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
      _serviceStates[Service.hmds] = true;
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
      _serviceStates[Service.hmds] = false;
    } catch (e) {
      print('Failed to launch mill app: $e');
    }
  }

  Future<void> _runJsApp() async {
    try {
      const executablePath = r'C:\JsApp\X64\Release\JsApp.exe';
      if (Platform.isWindows) {
        await Process.start(
            'cmd', ['/c', 'start', '/min', '""', executablePath]);
        print('Process started in a minimized state');
        _serviceStates[Service.jsApp] = true;
      }
    } catch (e) {
      print('Error starting process: $e');
    }
  }

  Future<void> _stopJsApp() async {
    if (_serviceStates[Service.jsApp]!) {
      Process.run('taskkill', ['/F', '/IM', 'JsApp.exe'])
          .then((ProcessResult results) {
        if (results.exitCode == 0) {
          print('Process JsApp terminated successfully.');
        } else {
          print(
              'Failed to terminate process JsApp. Exit code: ${results.exitCode}');
          print('Error: ${results.stderr}');
        }
      });
      _serviceStates[Service.jsApp] = false;
    }
  }

  Future<void> _runMil() async {
    try {
      await http.post(Uri.parse('$serverUrl/launch'));
      print('mill app launched successfully.');
      _serviceStates[Service.mil] = true;
    } catch (e) {
      print('Failed to launch mill app: $e');
    }
  }

  Future<void> _stopMil() async {
    try {
      await http.post(Uri.parse('$serverUrl/stop'));
      print('mill app stopped successfully.');
      _serviceStates[Service.mil] = false;
    } catch (e) {
      print('Failed to stop mill app: $e');
    }
  }

  Future<void> _runArinc() async {
    try {
      await http.post(Uri.parse('$serverUrl/launcharinc'));
      print('arinc app launched successfully.');
      _serviceStates[Service.arinc] = true;
    } catch (e) {
      print('Failed to launch arinc app: $e');
    }
  }

  Future<void> _stopArinc() async {
    try {
      await http.post(Uri.parse('$serverUrl/stoparinc'));
      print('arinc app stopped successfully.');
      _serviceStates[Service.arinc] = false;
    } catch (e) {
      print('Failed to stop arinc app: $e');
    }
  }

  void runAllServices(Map<String, dynamic> collectData) {
    if (collectData['selectedOption'] == 'FlightGear') {
      _runFlightGear(collectData);
    }
    if (collectData['selectedOption'] == 'JsApp') {
      _runJsApp();
    }
    if (collectData['selectedOption'] == 'MIL') {
      _runMil();
    }
    if (collectData['selectedOption'] == 'HMDs') {
      _runHeadSensor();
    }
    if (collectData['selectedOption'] == 'ARINC') {
      _runArinc();
    }
  }

  void stopAllServices() {
    _stopFlightGear();
    _stopJsApp();
    _stopMil();
    _stopHeadSensor();
    _stopArinc();
  }

}