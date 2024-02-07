import 'package:simulator/screens/target_generator.dart';

String buildGroundScenarioXML(Scenario3 scenario) {
  final xml = StringBuffer();
  xml.writeln('<?xml version="1.0"?>');
  xml.writeln('<PropertyList>');
  xml.writeln('  <scenario>');
  xml.writeln('    <name>${scenario.scenarioName}</name>');
  xml.writeln('    <description>${scenario.description}</description>');
  xml.writeln('    <search-order>${scenario.searchOrder}</search-order>');
  xml.writeln('    <nasal>');
  xml.writeln('     <load>');
  xml.writeln('''        <![CDATA[
          var finish = 0;
          var loop2 = func () {
              foreach( var tanker; props.globals.getNode("/ai/models",1).getChildren("ship") ) {
                var lat = tanker.getNode("position/latitude-deg").getValue();
                var lon = tanker.getNode("position/longitude-deg").getValue();
                var node = tanker.getNode("position/altitude-ft", 1 );
                var alt = geo.elevation(lat, lon);
                node.setDoubleValue(alt==nil?0:alt*M2FT);
              }
              if (finish == 0) {
                settimer(loop2, 20);
                return;
              }
              print("Scenario proper unloaded.");
          }
          loop2();
          finish = 1;
          print('Tonopah target range scenario load 17 targets: complete');
        ]]>''');
  xml.writeln('     </load>');
  xml.writeln('     <unload>');
  xml.writeln('''        <![CDATA[
  finish = 1;

  ]]>''');
  xml.writeln('     </unload>');
  xml.writeln('    </nasal>');

  for (final entry in scenario.entries) {
    xml.writeln('    <entry>');
    xml.writeln('      <type>${entry.type}</type>');
    xml.writeln('      <model>${entry.model}</model>');
    xml.writeln('      <speed-ktas>${entry.speedktas}</speed-ktas>');
    xml.writeln('      <name>${entry.name}</name>');
    xml.writeln('      <latitude>${entry.latitude}</latitude>');
    xml.writeln('      <longitude>${entry.longitude}</longitude>');
    xml.writeln('      <heading>${entry.heading}</heading>');
    xml.writeln('      <altitude>${entry.altitude}</altitude>');
    xml.writeln('    </entry>');
  }

  xml.writeln('  </scenario>');
  xml.writeln('</PropertyList>');

  return xml.toString();
}
