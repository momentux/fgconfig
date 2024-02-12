import 'package:simulator/screens/target_generator.dart';

String buildAirScenarioXML(Scenario1 scenario) {
  final xml = StringBuffer();
  xml.writeln('<?xml version="1.0"?>');
  xml.writeln('<PropertyList>');
  xml.writeln('  <scenario>');
  xml.writeln('    <name>${scenario.scenarioName}</name>');

  for (final entry in scenario.entries) {
    xml.writeln('    <entry>');
    xml.writeln('      <type>${entry.type}</type>');
    xml.writeln('      <model>${entry.model}</model>');
    xml.writeln('      <callsign>${entry.callsign}</callsign>');
    xml.writeln('      <class>${entry.classi}</class>');
    xml.writeln('      <flightplan>${entry.flightplan}</flightplan>');
    xml.writeln('    </entry>');
  }

  xml.writeln('  </scenario>');
  xml.writeln('</PropertyList>');

  return xml.toString();
}
