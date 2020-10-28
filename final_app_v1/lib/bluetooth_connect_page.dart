import 'dart:convert'; // for utf8 encoding
import 'package:flutter/material.dart';
import 'package:final_app_v1/ble_gps_write_test_page.dart';
import 'package:final_app_v1/initial_service_page.dart';
import 'package:final_app_v1/welcome_page.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:final_app_v1/connected_device.dart';
import 'package:oktoast/oktoast.dart';

class BluetoothConnectPage extends StatefulWidget {

  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();
  final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();

  @override
  _BluetoothConnectPageState createState() => _BluetoothConnectPageState();
}

class _BluetoothConnectPageState extends State<BluetoothConnectPage> {
  bool initialSetup;
  final _writeController = TextEditingController();
  BluetoothDevice _connectedDevice;
  List<BluetoothService> _services;
  // BuildContext context;

  @override
  Widget build(context) {
    return OKToast(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bluetooth_searching,
                color: Colors.grey[100],
              ),
              SizedBox(width: 14.0,),
              Text(
                "Connect to Device",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[100],
                  fontSize: 20,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: _buildView(),
        floatingActionButton: _showDoneButton(),
      ),
    );
  }

  ListView _buildView() {
    // build the device list or the contents of connected device
    if (_connectedDevice != null)
      return _buildConnectDeviceView();
    else
      return _buildListViewOfDevices();
  }

  FloatingActionButton _showDoneButton(){
    return FloatingActionButton(
      child: Icon(
        (_connectedDevice != null)? Icons.done : Icons.arrow_back,
        color: Colors.white,
      ),
      onPressed: () {
        ScopedModel.of<Device>(context).update((_connectedDevice != null)? _connectedDevice.name : "");
        print('\n ConnectedDevice: ${(_connectedDevice != null)? _connectedDevice.name.toString() : ''} \n');
//        Navigator.pushReplacementNamed(context, '/', arguments: _connectedDevice.name.toString());  // <-- Doesn't work
        widget.flutterBlue.stopScan();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => (_connectedDevice != null) ? new PositionWriteWidget(device: _connectedDevice) : new WelcomePage()
          )
        );
      }
    );
  }

  _addDeviceToList(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  @override
  void initState() {  // Initiate Bluetooth scanning
    super.initState();
    initialSetup = true;
    widget.flutterBlue.connectedDevices
      .asStream()
      .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceToList(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceToList(result.device);
      }
    });
    widget.flutterBlue.startScan();
  }   // Initiate Bluetooth scanning

  ListView _buildListViewOfDevices() {  // Build a ListView of the available devices
    double height = MediaQuery.of(context).size.height;
    List<Container> containers = new List<Container>();
    for (BluetoothDevice device in widget.devicesList) {
      containers.add(
        Container(
          height: 70,
          decoration: BoxDecoration(),
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(device.name == '' ? '(unknown device)' : device.name),
                        Text(device.id.toString()),
                      ],
                    ),
                  ),
                  FlatButton(
                    color: Colors.blueAccent[700],
                    child: Text(
                      'Connect',
                      style: TextStyle(color: Colors.white),
                    ),
                    onLongPress: () async{
                      showToast(
                        "Connect to this device",
                        position: ToastPosition(
                            align: Alignment.topCenter,
                            offset: height*0.32
                        ),
                        backgroundColor: Colors.grey[700],
                        radius: 5.0,
                        textPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0)
                      );
                    },
                    onPressed: () async {
                      widget.flutterBlue.stopScan();
                      try {
                        await device.connect();
                      }
                      catch (e) {
                        if (e.code != 'already_connected') throw e;
                      }
                      finally {
                        // if(_services != null) _services.clear();
                        _services = await device.discoverServices();
                        // while(_services != null)
                        //   Center(child: CircularProgressIndicator());
                      }
                      ScopedModel.of<Device>(context).update(device.name);
                      print("Device Name: ${ScopedModel.of<Device>(context).device}");
                      setState(() {
                        _connectedDevice = device;
                      });
                      initialSetup =  ScopedModel.of<Device>(context).initialSetup;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext con) {
                            if(initialSetup) {
                              ScopedModel.of<Device>(context).updateSetup(false);
                              return new InitialServiceWrite(
                                device: _connectedDevice,
                              );
                            }
                            else {
                              return new PositionWriteWidget(
                                device: _connectedDevice,
                              );
                            }
                          }
                        )
                      );
                    },
                  ),
                  SizedBox(width: 2.0,),
                  FlatButton(
                    color: Colors.blueAccent[700],
                    child: Text(
                      'Debug',
                      style: TextStyle(color: Colors.white),
                    ),
                    onLongPress: () async{
                      showToast(
                        "Details of Services",
                        position: ToastPosition(
                            align: Alignment.topCenter,
                            offset: height*0.32
                        ),
                        backgroundColor: Colors.grey[700],
                        radius: 5.0,
                        textPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0)
                      );
                    },
                    onPressed: () async {
                      widget.flutterBlue.stopScan();
                      try {
                        await device.connect();
                      } catch (e) {
                        if (e.code != 'already_connected') {
                          throw e;
                        }
                      } finally {
                        // if(_services != null) _services.clear();
                        _services = await device.discoverServices();
                      }
                      ScopedModel.of<Device>(context).update(device.name);
                      setState( () {
                        _connectedDevice = device;
                      });
                    },
                  ),
                  SizedBox(width: 2.0,),
                ],
              ),
              Divider(thickness: 1.0,),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(3),
      shrinkWrap: true,
      children: <Widget>[
        ...containers,
      ],
    );
  }   // Build a ListView of the available devices

  ListView _buildConnectDeviceView() {  // Build view of the connected devices services.
    List<Container> containers = new List<Container>();
    for (BluetoothService service in _services) {
      List<Widget> characteristicsWidget = new List<Widget>();
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        characteristicsWidget.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(characteristic.uuid.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    ..._buildReadWriteNotifyButton(characteristic),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Value: ' + widget.readValues[characteristic.uuid].toString(),
                      ),
                    ),
                  ],
                ),
                Divider(thickness: 0.3,),
              ],
            ),
          ),
        );
      }
      containers.add(
        Container(
          child: ExpansionTile(
              title: Text(service.uuid.toString()),
              children: characteristicsWidget),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
}   // Build view of the connected devices services.

  List<ButtonTheme> _buildReadWriteNotifyButton(BluetoothCharacteristic characteristic) {   // List of the appropriate buttons for a given service
    List<ButtonTheme> buttons = new List<ButtonTheme>();
    if (characteristic.properties.read) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RaisedButton(
              color: Colors.blue,
              child: Text('READ', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                  var sub = characteristic.value.listen((value) {
                  print('\nvalue: $value\n');
                  setState(() {
                    widget.readValues[characteristic.uuid] = value;
                  });
                });
                await characteristic.read();
                sub.cancel();
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.write) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RaisedButton(
              color: Colors.blue,
              child: Text('WRITE', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Write"),
                      content: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _writeController,
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("Send"),
                          onPressed: () {
                            characteristic.write(
                              utf8.encode(_writeController.value.text));
                            Navigator.pop(context);
                          },
                        ),
                        FlatButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  });
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.notify) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RaisedButton(
              color: Colors.blue,
              child: Text('NOTIFY', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                characteristic.value.listen((value) {
                  print('\nvalue: $value\n');
                  setState(() {
                    widget.readValues[characteristic.uuid] = value;
                  });
                });
                await characteristic.setNotifyValue(true);
              },
            ),
          ),
        ),
      );
    }
    return buttons;
  }   // List of the appropriate buttons for a given service
}