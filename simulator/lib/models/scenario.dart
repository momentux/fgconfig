import 'package:xml/xml.dart';

class PropertyList {
  final Scenario scenario;

  PropertyList({required this.scenario});

  factory PropertyList.fromXmlElement(XmlElement element) {
    return PropertyList(
      scenario: Scenario.fromXmlElement(element.findElements('scenario').first),
    );
  }

  factory PropertyList.fromFile(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    return PropertyList.fromXmlElement(document.rootElement);
  }

  XmlDocument toXmlDocument() {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('PropertyList', nest: () {
      scenario.buildXmlElement(builder);
    });
    return builder.buildDocument();
  }
}

class Scenario {
  final String name;
  final String description;
  final String searchOrder;
  final ScenarioNasal? nasal;
  final List<ScenarioEntry> entries;

  Scenario({
    required this.name,
    required this.description,
    String? searchOrder,
    this.nasal,
    List<ScenarioEntry>? entries,
  })  : searchOrder = searchOrder ?? "PREFER_DATA",
        entries = entries ?? [];

  factory Scenario.fromXmlElement(XmlElement element) {
    var name = element.findElements('name').first.value!;
    return Scenario(
      name: name,
      description: element.findElements('description').first.value!,
      searchOrder: element.findElements('search-order').first.value ?? "PREFER_DATA",
      nasal: element.findElements('nasal').isEmpty ? null : ScenarioNasal.fromXmlElement(element.findElements('nasal').first, name),
      entries: element.findElements('entry').map(ScenarioEntry.fromXmlElement).toList(),
    );
  }

  void buildXmlElement(XmlBuilder builder) {
    builder.element('scenario', nest: () {
      builder.element('name', nest: name);
      builder.element('description', nest: description);
      builder.element('search-order', nest: searchOrder);
      if (nasal != null) {
        nasal!.buildXmlElement(builder);
      }
      for (var entry in entries) {
        entry.buildXmlElement(builder);
      }
    });
  }
}

class ScenarioNasal {
  final String load;
  final String unload;

  ScenarioNasal({
    required String scenarioName,
    String? load,
    String? unload,
  })  : load = load ?? "debug.dump('Scenario $scenarioName loaded');",
        unload = unload ?? "debug.dump('Scenario $scenarioName unloaded');";

  factory ScenarioNasal.fromXmlElement(XmlElement element, String scenarioName) {
    return ScenarioNasal(
      scenarioName: scenarioName,
      load: element.findElements('load').first.value!,
      unload: element.findElements('unload').first.value!,
    );
  }

  void buildXmlElement(XmlBuilder builder) {
    builder.element('nasal', nest: () {
      builder.element('load', nest: () {
        builder.cdata(load);
      });
      builder.element('unload', nest: () {
        builder.cdata(unload);
      });
    });
  }
}

class ScenarioEntry {
  String type;
  final String model;
  final String name;
  String callSign;
  int altitude;
  final double speed;
  final double latitude;
  final double longitude;
  double heading;
  double roll;
  double bank;
  double rudder;

  ScenarioEntry({
    String? type,
    required this.model,
    required this.name,
    String? callsign,
    int? altitude,
    required this.speed,
    required this.latitude,
    required this.longitude,
    double? heading,
    double? roll,
    double? bank,
    double? rudder,
  })  : type = type ?? 'ship',
        callSign = callsign ?? '$type-$name',
        altitude = altitude ?? 15000,
        heading = heading ?? 0.0,
        roll = roll ?? 0.0,
        bank = bank ?? 0.0,
        rudder = rudder ?? 0.0;

  factory ScenarioEntry.fromXmlElement(XmlElement element) {
    var typeElement = element.findElements('type').firstOrNull;
    var callsignElement = element.findElements('callsign').firstOrNull;
    var rollElement = element.findElements('roll').firstOrNull;
    var bankElement = element.findElements('bank').firstOrNull;

    return ScenarioEntry(
      type: typeElement?.value!,
      model: element.findElements('model').first.value!,
      name: element.findElements('name').first.value!,
      callsign: callsignElement?.value!,
      altitude: int.parse(element.findElements('altitude').first.value!),
      speed: double.parse(element.findElements('speed').first.value!),
      latitude: double.parse(element.findElements('latitude').first.value!),
      longitude: double.parse(element.findElements('longitude').first.value!),
      heading: double.parse(element.findElements('heading').first.value!),
      roll: rollElement != null ? double.parse(rollElement.value!) : null,
      bank: bankElement != null ? double.parse(bankElement.value!) : null,
    );
  }

  void buildXmlElement(XmlBuilder builder) {
    builder.element('entry', nest: () {
      builder.element('type', nest: type);
      builder.element('model', nest: model);
      builder.element('name', nest: name);
      if (callSign != '$type-$name') {
        builder.element('callsign', nest: callSign);
      }
      builder.element('altitude', nest: altitude.toString());
      builder.element('speed', nest: speed.toString());
      builder.element('latitude', nest: latitude.toString());
      builder.element('longitude', nest: longitude.toString());
      builder.element('heading', nest: heading.toString());
      if (roll != 0.0) {
        builder.element('roll', nest: roll.toString());
      }
      if (bank != 0.0) {
        builder.element('bank', nest: bank.toString());
      }
    });
  }
}
