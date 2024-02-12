class Waypoint {
  String airport;
  double speed;
  double roll;
  bool isExpand;
  Waypoint({required this.airport, this.speed = 0.0, this.roll = 0.0, this.isExpand = true});
}

class FgRoute {
  String scenarioName;
  String description;
  String searchOrder;
  List<ScenarioEntry> entries;

  FgRoute({
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

class ScenarioEntry {
  final String? sno;
  final String? type;
  final String name; // Auto-generated
  final double latitude; // Auto-generated based on sourceAirport
  final double longitude; // Auto-generated based on sourceAirport
  final double speed;
  final int altitude;

  ScenarioEntry({
    required this.sno,
    required this.type,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.altitude,
  });
  @override
  String toString() {
    return 'ScenarioEntry(sno:$sno, type: $type, name: $name, latitude: $latitude, longitude: $longitude, speed: $speed, altitude: $altitude,)';
  }
}

String buildRouteXML(FgRoute route) {
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
    xml.writeln('          <ident>${entry.name}</ident>');
    xml.writeln('          <lon>${entry.longitude}</lon>');
    xml.writeln('          <lat>${entry.latitude}</lat>');
    xml.writeln('       </wp>');
  }

  xml.writeln('    </route>');
  xml.writeln('</PropertyList>');

  return xml.toString();
}