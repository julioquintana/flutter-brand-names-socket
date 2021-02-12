import 'dart:io';

import 'package:brand_names/model/band.dart';
import 'package:brand_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];
  List<Color> colorList = [
    Colors.blue[50],
    Colors.blue[200],
    Colors.pink[50],
    Colors.pink[200],
    Colors.yellow[50],
    Colors.yellow[200]
  ];

  @override
  void initState() {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(data) {
    this.bands = (data as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: socketProvider.serverStatus == ServerStatus.online
                ? Icon(
                    Icons.check_circle,
                    color: Colors.green[300],
                  )
                : Icon(
                    Icons.offline_bolt,
                    color: Colors.red,
                  ),
          )
        ],
        title: Text(
          'Band Names',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height - 180,
        child: Column(
          children: [
            _showGraph(),
            Expanded(
              child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (context, index) => _bandTitle(bands[index]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          elevation: 1, child: Icon(Icons.add), onPressed: addNewBrand),
    );
  }

  Widget _bandTitle(Band band) {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);

    return Dismissible(
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => deleteBand(band.id),
      background: Container(
        padding: EdgeInsets.only(left: 8),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Delete Band',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      key: Key(band.id),
      child: ListTile(
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () => socketProvider.socket.emit('vote-band', {'id': band.id}),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0, 2)),
        ),
      ),
    );
  }

  addNewBrand() {
    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('New Band name:'),
          content: TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
              child: Text('Add'),
              elevation: 5,
              textColor: Colors.blue,
              onPressed: () => addBandToList(textController.text),
            )
          ],
        ),
      );
    }
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text('New Band Name:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('Add'),
              isDefaultAction: true,
              onPressed: () => addBandToList(textController.text),
            ),
            CupertinoDialogAction(
              child: Text('Dismiss'),
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
    }
  }

  addBandToList(String name) {
    if (bands.length > 1) {
      final socketProvider =
          Provider.of<SocketProvider>(context, listen: false);
      socketProvider.socket.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }

  deleteBand(String id) {
    if (bands.length > 1) {
      final socketProvider =
          Provider.of<SocketProvider>(context, listen: false);
      socketProvider.socket.emit('delete-band', {'id': id});
    }
  }

  _showGraph() {
    Map<String, double> dataMap = new Map();
    bands.forEach((element) {
      dataMap.putIfAbsent(element.name, () => element.votes.toDouble());
    });
    return Container(
      width: double.infinity,
      height: 180,
      child: (dataMap.isNotEmpty)
          ? PieChart(
              dataMap: dataMap,
              animationDuration: Duration(milliseconds: 800),
              chartValuesOptions: ChartValuesOptions(
                showChartValuesInPercentage: true,
                showChartValues: true,
                showChartValuesOutside: true,
                chartValueBackgroundColor: Colors.grey[200],
                decimalPlaces: 0,
              ),
              legendOptions: LegendOptions(
                showLegends: true,
              ),
              colorList: colorList,
              chartType: ChartType.disc,
            )
          : Container(),
    );
  }
}
