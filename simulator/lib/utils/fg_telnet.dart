import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class FlightGearTelnet {
  late Socket _socket;

  Future<void> connect(String host, int port) async {
    _socket = await Socket.connect(host, port);
    _socket.transform(utf8.decoder as StreamTransformer<Uint8List, dynamic>).listen((data) {
      print('Received: $data');
    });
  }

  void sendCommand(String command) {
    print('Sending: $command');
    _socket.write('$command\n');
  }

  void close() {
    _socket.close();
  }
}
