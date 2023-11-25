import 'package:simulator/screens/route_manager.dart';

String buildRouteXML(Scenario scenario) {
  final xml = StringBuffer();

xml.writeln('<PropertyList>');
xml.writeln('   <version type="int">2</version>');
xml.writeln('   <flight-rules type="string">V</flight-rules>');
xml.writeln('   <flight-type type="string">X</flight-type>');
xml.writeln('   <estimated-duration-minutes type="int">0</estimated-duration-minutes>');
xml.writeln('   <route>');
for (final entry in scenario.entries) {

xml.writeln('       <wp n="${entry.sno}">');
xml.writeln('         <type>${entry.type}</type>');
xml.writeln('         <ident>${entry.name}</ident>');
xml.writeln('         <lon>${entry.longitude}</lon>');
xml.writeln('         <lat>${entry.latitude}</lat>');
xml.writeln('         <altitude-ft>${entry.altitude}</altitude-ft>');
xml.writeln('       </wp>');
}
xml.writeln('   </route>');
xml.writeln('</PropertyList>');
  return xml.toString();
}
