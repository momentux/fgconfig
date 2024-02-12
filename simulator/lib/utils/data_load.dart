import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Airport {
  final String code;
  final double latitude;
  final double longitude;

  Airport({required this.code, required this.latitude, required this.longitude});
}

class DataLoader {
  static final DataLoader _instance = DataLoader._internal();
  Map<String, Airport> _airports = {};

  DataLoader._internal();

  factory DataLoader() {
    return _instance;
  }

  Future<void> loadAirportsFromJson() async {
    try {
      final fileContent = await rootBundle.loadString('data/airports.json');
      final parsedJson = json.decode(fileContent) as List<dynamic>;
      _airports.clear();

      for (var airport in parsedJson) {
        final String code = airport['airportCode'];
        final double lat = airport['latitude'];
        final double long = airport['longitude'];
        _airports[code] = Airport(code: code, latitude: lat, longitude: long);
        
      }
    } catch (e) {
      print('Error loading airports from JSON: $e');
    }
  }

  Airport? getAirport(String code) {
    return _airports[code];
  }


  List<String> getAllAirportCodes() {
    return _airports.keys.toList();
  }
  List<String> getAllAirportLat() {
    return _airports.keys.toList();
  }
}
