import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:simulator/models/fg_args.dart';

import 'fg_telnet.dart';

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
  final FlightGearTelnet _flightGearTelnet = FlightGearTelnet();

  Future<void> runFlightGear(FGArgs args) async {
    try {
      String fgfsPath;
      if (Platform.isWindows) {
        fgfsPath = r'C:\Program Files\FlightGear 2020.3\bin\fgfs.exe';
      } else if (Platform.isMacOS) {
        fgfsPath = '/Applications/FlightGear.app/Contents/MacOS/fgfs';
      } else {
        throw Exception('Unsupported operating system');
      }
      var argString = args.getArgString();
      print(argString.join(' '));

      flightGearProcess = await Process.start(fgfsPath,argString );
      _serviceStates[Service.flightGear] = true;
      print('FlightGear process ID: ${flightGearProcess.pid}');

      // If serviceOption is "Autopilot", send a command to FlightGear via telnet
      if (args.autoPilot!) {
        bool connected = false;
        while (!connected) {
          try {
            await _flightGearTelnet.connect(
                'localhost', findTelnetPort(argString));
            _flightGearTelnet.sendCommand(
                'set /f16/fcs/switch-pitch-block20 1');
            connected = true;
          } catch (e) {
            print(
                'Failed to connect to telnet server. Retrying in 2 seconds...');
            await Future.delayed(Duration(seconds: 2));
          }
        }
      }
    } catch (e) {
      print('Error running FlightGear: $e');
    }
  }

  Future<void> stopFlightGear() async {
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

  void runAllServices(FGArgs args) {
    runFlightGear(args);
    _runJsApp();
    _runMil();
    _runHeadSensor();
    _runArinc();
  }

  void stopAllServices() {
    stopFlightGear();
    _stopJsApp();
    _stopMil();
    _stopHeadSensor();
    _stopArinc();
  }

  int findTelnetPort(List<String> argString) {
    String telnetLine = argString.firstWhere((line) => line.startsWith('--telnet='));
    String portString = telnetLine.split('=')[1];
    int port = int.parse(portString);
    return port;
  }
}

