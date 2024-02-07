import 'package:simulator/screens/target_generator.dart';

String buildProtocolXML(Protocol protocol) {
  final xml = StringBuffer();
  xml.writeln('<?xml version="1.0"?>');
  xml.writeln('<PropertyList>');
  xml.writeln('<generic>');
  xml.writeln('<output>');
  xml.writeln('<binary_mode>true</binary_mode>');
  xml.writeln('<binary_footer>magic,0x4</binary_footer>');
  for (final entry in protocol.entries) {
    xml.writeln('<chunk>');
    xml.writeln('    <name>${entry.name}</name>');
    xml.writeln('    <format>${entry.format}</format>');
    xml.writeln('    <type>${entry.type}</type>');
    xml.writeln(
        '    <node>${entry.node}</node>');
    xml.writeln('</chunk>');
  }
  xml.writeln('</output>');
  xml.writeln('</generic>');
  xml.writeln('</PropertyList>');
  return xml.toString();
}
