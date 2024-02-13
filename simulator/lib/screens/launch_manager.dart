import 'dart:async';

import 'package:flutter/material.dart';

import '../models/fg_args.dart';
import '../utils/components.dart';
import '../utils/service_handler.dart';
import '../widgets/route_options.dart';
import '../widgets/target_options.dart';

final _serviceDisplayNames = {
  Service.flightGear: 'Flight Gear',
  Service.jsApp: 'Joystick',
  Service.mil: 'MIL',
  Service.hmds: 'HMDS',
  Service.arinc: 'ARINC',
};

class LaunchManagementScreen extends StatefulWidget {
  @override
  _LaunchManagementScreenState createState() => _LaunchManagementScreenState();
}

class _LaunchManagementScreenState extends State<LaunchManagementScreen> {
  final ServiceHandler serviceHandler = ServiceHandler();
  final Map<Service, Timer> _timers = {};
  final Map<Service, bool> _visibilityFlags = {for (var e in Service.values) e: true};
  String? targetOption;
  String? typeOfTarget;
  String? targetSubOption;
  double? latitudeValue;
  double? longitudeValue;
  int? altitudeValue;
  int? headingValue;
  bool? autoPilot;
  String? airport;
  String? filename;
  bool? inAir;

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
    return Column(
      children: [
        RouteOptionsCard(
            onOptionsChanged: (newLatitudeValue, newLongitudeValue, newAltitudeValue, newHeadingValue, isAutoPilot, newAirport, isInAir) {
          setState(() {
            latitudeValue = newLatitudeValue;
            longitudeValue = newLongitudeValue;
            altitudeValue = newAltitudeValue;
            headingValue = newHeadingValue;
            autoPilot = isAutoPilot;
            airport = newAirport;
            inAir = isInAir;
          });
        }),
        TargetOptionsCard(
            targetOption: targetOption,
            typeOfTarget: typeOfTarget,
            targetSubOption: targetSubOption,
            onOptionsChanged: (newTargetOption, newTypeOfTarget, newTargetSubOption) {
              setState(() {
                targetOption = newTargetOption;
                typeOfTarget = newTypeOfTarget;
                targetSubOption = newTargetSubOption;
              });
            }),
        _buildServiceStatusRow(),
        _buildLaunchButtons(),
      ],
    );
  }

  Row _buildServiceStatusRow() {
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

  Widget _buildLaunchButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildButton(
          onPressed: () => serviceHandler.runFlightGear(_collectData()),
          text: 'Launch',
        ),
        buildButton(
          onPressed: () {
            serviceHandler.stopFlightGear();
            setState(() {});
          },
          text: 'Stop',
          color: Colors.red,
        ),
      ],
    );
  }

  FGArgs _collectData() {
    return FGArgs(
      autoPilot: autoPilot,
      targetOption: targetOption,
      typeOfTarget: typeOfTarget,
      targetSubOption: targetSubOption,
      airport: airport,
      latitudeValue: latitudeValue,
      longitudeValue: longitudeValue,
      altitudeValue: altitudeValue,
      headingValue: headingValue,
      serviceStates: serviceHandler.serviceStates,
      filename: filename,
      state: 'cruise',
      inAir: inAir,
    );
  }
}
