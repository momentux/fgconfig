import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

Future<String> getFgFsRcPath() async {
  final directory = await getApplicationDocumentsDirectory();
  return '${directory.path}${Platform.pathSeparator}.fgfsrc';
}

Future<void> modifyFgSrcFile(String json) async {
  try {
    final String fgFsRcPath = await getFgFsRcPath();
    String existingContent = File(fgFsRcPath).readAsStringSync();
    Map<String, dynamic> jsonData = jsonDecode(json);

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
        else {
          // If Autopilot block doesn't exist, add the entire Autopilot block
          existingContent += '''
### Autopilot
--prop:/f16/fcs/switch-pitch-block20=1
--prop:/f16/fcs/switch-roll-block20=-1
--prop:/instrumentation/heading-indicator/heading-bug-deg=120
###
''';
        }
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
        '--prop:/sim/ai/scenario=$jsonData["destinationPathformanualaiscenario"]';
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
    await File(fgFsRcPath).writeAsString(existingContent);
  } catch (e) {
    print('Error modifying .fgsrc file: $e');
  }
}

