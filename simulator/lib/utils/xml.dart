import 'package:simulator/screens/target_scenario.dart';

String buildScenarioXML(Scenario scenario) {
  final xml = StringBuffer();

  xml.writeln('<PropertyList>');
  xml.writeln('  <scenario>');
  xml.writeln('    <name>${scenario.scenarioName}</name>');
  xml.writeln('    <description>${scenario.description}</description>');
  xml.writeln('    <search-order>${scenario.searchOrder}</search-order>');

  for (final entry in scenario.entries) {
    xml.writeln('    <entry>');
    xml.writeln('      <type>${entry.type}</type>');
    xml.writeln('      <model>${entry.model}</model>');
    xml.writeln('      <name>${entry.name}</name>');
    xml.writeln('      <latitude type="double">${entry.latitude}</latitude>');
    xml.writeln(
        '      <longitude type="double">${entry.longitude}</longitude>');
    xml.writeln('      <speed type="double">${entry.speed}</speed>');
    xml.writeln('      <rudder type="double">${entry.rudder}</rudder>');
    xml.writeln('      <heading type="double">${entry.heading}</heading>');
    xml.writeln('      <altitude type="double">${entry.altitude}</altitude>');
    xml.writeln('    </entry>');
  }

  xml.writeln('  </scenario>');
  xml.writeln('</PropertyList>');

  return xml.toString();
}
