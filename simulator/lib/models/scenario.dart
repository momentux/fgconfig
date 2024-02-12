import 'package:xml/xml.dart';

class Scenario {
  final String name;
  final String description;
  final String searchOrder;
  final ScenarioNasal? nasal;
  final List<ScenarioEntry> entries;

  Scenario({
    required this.name,
    required this.description,
    this.searchOrder = "PREFER_DATA",
    this.nasal,
    this.entries = const [],
  });

  factory Scenario.fromXmlElement(XmlElement element) {
    final nasalElement = element.findElements('nasal').firstOrNull;
    return Scenario(
      name: getElementText(element, 'name'),
      description: getElementText(element, 'description'),
      searchOrder: getElementText(element, 'search-order', defaultValue: "PREFER_DATA"),
      nasal: nasalElement != null ? ScenarioNasal.fromXmlElement(nasalElement, getElementText(element, 'name')) : null,
      entries: element.findElements('entry').map(ScenarioEntry.fromXmlElement).toList(),
    );
  }

  void buildXmlElement(XmlBuilder builder) {
    builder.element('scenario', nest: () {
      builder.element('name', nest: name);
      builder.element('description', nest: description);
      builder.element('search-order', nest: searchOrder);
      nasal?.buildXmlElement(builder);
      entries.forEach((entry) => entry.buildXmlElement(builder));
    });
  }
}

class ScenarioNasal {
  final String load;
  final String unload;

  ScenarioNasal({
    required String scenarioName,
    required this.load,
    required this.unload,
  });

  factory ScenarioNasal.fromXmlElement(XmlElement element, String scenarioName) {
    return ScenarioNasal(
      scenarioName: scenarioName,
      load: getElementText(element, 'load', defaultValue: "debug.dump('Scenario $scenarioName loaded');"),
      unload: getElementText(element, 'unload', defaultValue: "debug.dump('Scenario $scenarioName unloaded');"),
    );
  }

  void buildXmlElement(XmlBuilder builder) {
    builder.element('nasal', nest: () {
      builder.element('load', nest: () => builder.cdata(load));
      builder.element('unload', nest: () => builder.cdata(unload));
    });
  }
}

class ScenarioEntry {
  final String type;
  final String model;
  final String name;
  final String callSign;
  final int altitude;
  final double speed;
  final double latitude;
  final double longitude;
  final double heading;
  final double roll;
  final double bank;
  final double rudder;

  ScenarioEntry({
    this.type = 'ship',
    required this.model,
    required this.name,
    this.callSign = 'ship1',
    this.altitude = 15000,
    required this.speed,
    required this.latitude,
    required this.longitude,
    this.heading = 0.0,
    this.roll = 0.0,
    this.bank = 0.0,
    this.rudder = 0.0,
  });

  factory ScenarioEntry.fromXmlElement(XmlElement element) {
    String type = getElementText(element, 'type', defaultValue: 'ship');
    String name = getElementText(element, 'name');
    return ScenarioEntry(
      type: getElementText(element, 'type', defaultValue: 'ship'),
      model: getElementText(element, 'model'),
      name: getElementText(element, 'name'),
      callSign: getElementText(element, 'callsign', defaultValue: '$type-$name'),
      altitude: int.tryParse(getElementText(element, 'altitude')) ?? 15000,
      speed: double.tryParse(getElementText(element, 'speed')) ?? 0.0,
      latitude: double.tryParse(getElementText(element, 'latitude')) ?? 0.0,
      longitude: double.tryParse(getElementText(element, 'longitude')) ?? 0.0,
      heading: double.tryParse(getElementText(element, 'heading')) ?? 0.0,
      roll: double.tryParse(getElementText(element, 'roll', defaultValue: '0.0')) ?? 0.0,
      bank: double.tryParse(getElementText(element, 'bank', defaultValue: '0.0')) ?? 0.0,
      rudder: double.tryParse(getElementText(element, 'rudder', defaultValue: '0.0')) ?? 0.0,
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

// Standalone utility function
String getElementText(XmlElement element, String tagName, {String defaultValue = ''}) {
  return element.findElements(tagName).firstOrNull?.innerText ?? defaultValue;
}

extension on Iterable<XmlElement> {
  XmlElement? get firstOrNull => isEmpty ? null : first;
}

class PropertyList {
  final Scenario scenario;

  PropertyList({required this.scenario});

  factory PropertyList.fromXmlElement(XmlElement element) {
    final scenarioElement = element.findElements('scenario').first;
    return PropertyList(
      scenario: Scenario.fromXmlElement(scenarioElement),
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