class Scenario1 {
  String scenarioName;
  String description;
  String searchOrder;
  List<ScenarioEntry1> entries;

  Scenario1({
    required this.scenarioName,
    required this.description,
    required this.searchOrder,
    required this.entries,
  });

  @override
  String toString() {
    return 'Scenario(scenarioName: $scenarioName, description: $description, searchOrder: $searchOrder, entries: $entries)';
  }
}

class Scenario2 {
  String scenarioName;
  String description;
  String searchOrder;
  List<ScenarioEntry2> entries;

  Scenario2({
    required this.scenarioName,
    required this.description,
    required this.searchOrder,
    required this.entries,
  });

  @override
  String toString() {
    return 'Scenario(scenarioName: $scenarioName, description: $description, searchOrder: $searchOrder, entries: $entries)';
  }
}

class Scenario3 {
  String scenarioName;
  String description;
  String searchOrder;
  List<ScenarioEntry3> entries;

  Scenario3({
    required this.scenarioName,
    required this.description,
    required this.searchOrder,
    required this.entries,
  });

  @override
  String toString() {
    return 'Scenario(scenarioName: $scenarioName, description: $description, searchOrder: $searchOrder, entries: $entries)';
  }
}

class Protocol {
  String scenarioName;
  String description;
  String searchOrder;
  List<ProtocolEntry> entries;

  Protocol({
    required this.scenarioName,
    required this.description,
    required this.searchOrder,
    required this.entries,
  });

  @override
  String toString() {
    return 'Scenario(scenarioName: $scenarioName, description: $description, searchOrder: $searchOrder, entries: $entries)';
  }
}

class ProtocolEntry {
  final String name;
  final String format;
  final String type; // Auto-generated
  final String node;

  ProtocolEntry({
    required this.type,
    required this.name,
    required this.format,
    required this.node,
  });

  @override
  String toString() {
    return 'ProtocolEntry(type: $type, name: $name, format: $format, node: $node)';
  }
}

class ScenarioEntry3 {
  final String type;
  final String model;
  final String name; // Auto-generated
  final String speedktas;
  final String latitude; // Auto-generated based on sourceAirport
  final String longitude; // Auto-generated based on sourceAirport
  final String heading;
  final String altitude;

  ScenarioEntry3({
    required this.type,
    required this.model,
    required this.speedktas,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.heading,
    required this.altitude,
  });

  @override
  String toString() {
    return 'ScenarioEntry(type: $type, model: $model,  speedktas: $speedktas, name: $name, latitude: $latitude, longitude: $longitude,  heading: $heading, altitude: $altitude)';
  }
}

class ScenarioEntry2 {
  final String type;
  final String model;
  final String name; // Auto-generated
  final String latitude; // Auto-generated based on sourceAirport
  final String longitude; // Auto-generated based on sourceAirport
  final String speed;
  final String rudder;

  ScenarioEntry2({
    required this.type,
    required this.model,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.rudder,
  });

  @override
  String toString() {
    return 'ScenarioEntry(type: $type, model: $model, name: $name, latitude: $latitude, longitude: $longitude, speed: $speed, rudder: $rudder)';
  }
}

class ScenarioEntry1 {
  final String type;
  final String model;
  final String callsign;
  final String classi;

  final String flightplan;

  ScenarioEntry1({
    required this.type,
    required this.model,
    required this.callsign,
    required this.classi,
    required this.flightplan,
  });

  @override
  String toString() {
    return 'ScenarioEntry1(type: $type, model: $model, callsign: $callsign, classi: $classi, flightplan:$flightplan)';
  }
}

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
    xml.writeln('    <node>${entry.node}</node>');
    xml.writeln('</chunk>');
  }
  xml.writeln('</output>');
  xml.writeln('</generic>');
  xml.writeln('</PropertyList>');
  return xml.toString();
}
