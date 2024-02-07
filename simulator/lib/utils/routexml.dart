import 'package:simulator/screens/route_generator.dart';

String buildRouteXML(Route route) {
  final xml = StringBuffer();
  xml.writeln('<?xml version="1.0"?>');
  xml.writeln('<PropertyList>');
  xml.writeln('    <version type="int">2</version>');
  xml.writeln('    <flight-rules type="string">V</flight-rules>');
  xml.writeln('    <flight-type type="string">X</flight-type>');
  xml.writeln(
      '    <estimated-duration-minutes type="int">0</estimated-duration-minutes>');
  xml.writeln('    <route>');
  for (final entry in route.entries) {
    xml.writeln('       <wp n="${entry.sno}">');
    xml.writeln('           <type type="string">${entry.type}</type>');
    xml.writeln('           <altitude-ft>${entry.altitude}</altitude-ft>');
    xml.writeln('          <speed>${entry.speed}</speed>');
    xml.writeln('          <ident type="string">${entry.name}</ident>');
    xml.writeln('          <lon>${entry.longitude}</lon>');
    xml.writeln('          <lat>${entry.latitude}</lat>');
    xml.writeln('       </wp>');
  }

  xml.writeln('    </route>');
  xml.writeln('</PropertyList>');

  return xml.toString();
}
