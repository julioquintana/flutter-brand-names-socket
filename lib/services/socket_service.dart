import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

enum ServerStatus { online, offline, connecting }

class SocketProvider with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.connecting;

  Socket _socket;

  Socket get socket => _socket;

  ServerStatus get serverStatus => _serverStatus;

  SocketProvider() {
    _initConfig();
  }

  void _initConfig() {
    _socket = io(
        'http://192.168.1.86:3000',
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .enableAutoConnect()
            .build());

    _socket.onConnect((_) {
      print('connect');
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });
    _socket.onDisconnect((_) {
      print('connect');
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });
/*    _socket.on('nuevo-mensaje', (payload) {
      print('nuevo mensaje: ' + payload);
    });*/
  }
}
