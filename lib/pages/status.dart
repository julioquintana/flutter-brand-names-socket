import 'package:brand_names/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Status Server ${socketProvider.serverStatus}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        elevation: 1,
        onPressed: (){
          _emitMessage(socketProvider, 'probando sonido');
        },
      ),
    );
  }

  void _emitMessage(SocketProvider socketProvider, String message){
    socketProvider.socket.emit('emitir-mensaje',{'id':1, 'destinatario': 'Mayruma Crespo', 'message': message });
  }
  
}
