import 'package:flutter/material.dart';

import '../utils/components.dart';
import '../utils/file_handlers.dart';

class TargetOptionsCard extends StatefulWidget {
  final String? targetOption;
  final String? typeOfTarget;
  final String? targetSubOption;
  final Function(String? targetOption, String? typeOfTarget, String? targetSubOption) onOptionsChanged;

  TargetOptionsCard({
    this.targetOption,
    this.typeOfTarget,
    this.targetSubOption,
    required this.onOptionsChanged,
  });

  @override
  _TargetOptionsCardState createState() => _TargetOptionsCardState();
}

const String targetOptionHint = 'Select Target Option';
const String typeOfTargetHint = 'Select Type of Target';
const String targetSubOptionHint = 'Select Target Sub Option';

class _TargetOptionsCardState extends State<TargetOptionsCard> {
  String? targetOption = 'FG AI Scenario';
  String? typeOfTarget;
  String? targetSubOption;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.all(16.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleText('Target Options'),
              sizedRow([
                dropdownFormField(
                    targetOption, ['FG AI Scenario', 'Manual AI Scenario'],
                    (newValue) {
                  setState(() {
                    targetOption = newValue;
                    if (targetOption == 'Manual AI Scenario'){
                      typeOfTarget = 'Air Target';
                    } else {
                      typeOfTarget = null;
                    }
                    widget.onOptionsChanged(targetOption, typeOfTarget, targetSubOption);
                  });
                }, targetOptionHint),
                if (targetOption == 'FG AI Scenario')
                  fileUploadButton(movefileforfgaiscenario),
                if (targetOption == 'Manual AI Scenario')
                  dropdownFormField(
                      typeOfTarget, ['Air Target', 'Sea Target', 'Ground Target'],
                      (newValue) {
                    setState(() {
                      typeOfTarget = newValue;
                      widget.onOptionsChanged(targetOption, typeOfTarget, targetSubOption);
                    });
                  }, typeOfTargetHint),
                if (targetOption == 'Manual AI Scenario')
                  dropdownFormField(
                      targetSubOption, ['Replay Recorded Data', 'Bypass FG'],
                      (newValue) {
                    setState(() {
                      targetSubOption = newValue;
                      widget.onOptionsChanged(targetOption, typeOfTarget, targetSubOption);
                    });
                  }, targetSubOptionHint),
                if (targetOption == 'Manual AI Scenario' &&
                    targetSubOption == 'Replay Recorded Data')
                  fileUploadButton(movefileformanualai),
                // if (targetSubOption == 'Bypass FG') buildUploadButton(_pickFile),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> movefileforfgaiscenario(String filePath) async {
    moveFile(filePath, r'C:\Users\scl\Flightgear\Aircrafts\f16\Scenarios\',
        (fileName) {
      setState(() {
        // filename = path.basenameWithoutExtension(fileName);
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
