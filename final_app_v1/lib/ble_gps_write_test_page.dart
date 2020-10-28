import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:final_app_v1/welcome_page.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:geolocator/geolocator.dart';
import 'package:final_app_v1/info_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:final_app_v1/connected_device.dart';
import 'package:oktoast/oktoast.dart';

class PositionWriteWidget extends StatefulWidget {
  PositionWriteWidget({
    Key key,
    @required
    this.device
  }) : super(key: key);

  final BluetoothDevice device;
  // final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();

  @override
  _PositionWriteWidgetState createState() => _PositionWriteWidgetState();
}

class _PositionWriteWidgetState extends State<PositionWriteWidget> {
  StreamSubscription<Position> _positionStreamSubscription;
  Position _position;
  double _latitude = 0.0,
         _longitude = 0.0;
  List<BluetoothService> _services;
  BluetoothCharacteristic _latCharacteristic, _lonCharacteristic, _resetCharacteristic;
  final _writeController = TextEditingController();
  @override
  void initState(){ // Start of page
    super.initState();
    _getServices(); // Separate because async cannot be used for initState
    if (_positionStreamSubscription == null) {
      final positionStream = getPositionStream();
      _positionStreamSubscription = positionStream.handleError((error) {
        _positionStreamSubscription.cancel();
        _positionStreamSubscription = null;
      })
          .listen((position) => setState(() {
        _position = position;
        print("\nGot Position --> Latitude: ${_position.longitude}, Longitude: ${_position.latitude}");
        updateUI();
        _updateLatLonCharacteristic();
      }));
      _positionStreamSubscription.pause();
    }
    setState(() {
      if (_positionStreamSubscription.isPaused) {
        _positionStreamSubscription.resume();
        print("Position Stream Resumed");
      } else {
        _positionStreamSubscription.pause();
        print("Position Stream Paused");
      }
    });
  }

  void updateUI() {
    setState(() {
      _latitude  = _position.latitude;
      _longitude = _position.longitude;
    });
  }

  void _getServices() async{  // Discover all services
    try {
      await widget.device.connect();
    }
    catch (e) {
      if (e.code != 'already_connected') {
        throw e;
      }
    }
    finally {
      _services = await widget.device.discoverServices();
    }
    if(_findLatLonService()){
      // Can start writing now
      print("Can start writing now");
    }
    else{
      await widget.device.disconnect();
      ScopedModel.of<Device>(context).update("");
      Navigator.pushReplacement(
        context,MaterialPageRoute(
          builder: (_) => new WelcomePage(),
        ),
      );
    }
  }

  bool _findLatLonService(){
    bool foundLat = false, foundLon = false, foundRst = false;
    for (BluetoothService service in _services) {
      print("Service UUID: ${service.uuid}\n |");     // 00001819-0000-1000-8000-00805f9b34f1
      // List<BluetoothCharacteristic> characteristics = new List<BluetoothCharacteristic>();
      for(BluetoothCharacteristic characteristic in service.characteristics){
        print(" |-> Characteristic UUID: ${characteristic.uuid}");
        if(characteristic.uuid.toString() == "00002aae-0000-1000-8000-00805f9b34fb"){
          print(" ^--- GOT LATITUDE CHAR ");
          _latCharacteristic = characteristic;
          foundLat = true;
        }
        if(characteristic.uuid.toString() == "00002aaf-0000-1000-8000-00805f9b34fb"){
          print(" ^--- GOT LONGITUDE CHAR ");
          _lonCharacteristic = characteristic;
          foundLon = true;
        }
        if(characteristic.uuid.toString() == "00002a0b-0000-1000-8000-00805f9b34fb"){
          print(" ^--- GOT RESET CHAR ");
          _resetCharacteristic = characteristic;
          foundRst = true;
        }
      }
    }
    return (foundLon && foundLat && foundRst);
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocationPermission>(
      future: checkPermission(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        else if (snapshot.data == LocationPermission.denied) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const InfoWidget(
                  'Request location permission',
                  'Access to the device\'s location has been denied, please '
                      'request permissions before continuing'
              ),
              RaisedButton(
                  child: const Text('Request permission'),
                  onPressed: () => requestPermission()
              ),
            ],
          );
        }
        else if (snapshot.data == LocationPermission.deniedForever) {
          return const InfoWidget(
              'Access to location permanently denied',
              'Allow access to the location services for this App using the '
                  'device settings.'
          );
        }
        if (widget.device == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const InfoWidget(
                  'Not connected to any device',
                  'Please connect to a device before continuing'
              ),
              RaisedButton(
                  child: const Text('Click here to go back'),
                  onPressed: () {
                    ScopedModel.of<Device>(context).update("");
                    Navigator.pushReplacement(
                      context, MaterialPageRoute(
                        builder: (_) => new WelcomePage()
                    ),
                  );
                }
              ),
            ],
          );
        }
        else return _buildSendingView();
      }
    );
  }

  Widget _buildSendingView(){
    double height = MediaQuery
        .of(context)
        .size
        .height;
    double width = MediaQuery
        .of(context)
        .size
        .width;
    return OKToast(
        child: Scaffold(
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: height*0.2,
                ),
                Text(
                  "Send location data",
                  style: GoogleFonts.abel(
                      fontSize: height * 0.05,
                  )
                ),
                Text(
                    "to the device",
                    style: GoogleFonts.abel(
                      fontSize: height * 0.05,
                    )
                ),
                SizedBox(
                  height: height*0.14,
                ),

                _sendingViewContent(),

                SizedBox(
                  height: height*0.16,
                ),
                Container(
                  constraints: BoxConstraints(minWidth: width*0.5),
                  child: RaisedButton(
                    child: Text(
                      _isListening() ? 'Start Updating Data' : 'Stop Updating Data',
                      style: TextStyle(fontWeight: FontWeight.w400, fontSize: height * 0.02,),
                    ),
                    color: _isListening() ? Colors.green : Colors.red,
                    onPressed: () => _toggleListening(),
                    onLongPress: () async{
                      showToast(
                        _isListening() ? 'Start sending GPS data to device' : 'Stop sending GPS data to device',
                        position: ToastPosition(
                          align: Alignment.topCenter,
                          offset: height*0.32
                        ),
                        backgroundColor: Colors.grey[700],
                        radius: 5.0,
                        textPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0)
                      );
                    },
                  ),
                ),
                Container(
                  constraints: BoxConstraints(minWidth: width*0.5),
                  child: RaisedButton(
                      child: Text(
                        "Reset Device",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: height * 0.02,
                        ),
                      ),
                      color: Colors.green,
                      onLongPress: () async{
                        showToast(
                          "Reset the connected device",
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
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Enter Password"),
                              backgroundColor: Colors.grey[100],
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
                                  child: Text("Reset"),
                                  onPressed: () async{
                                    ScopedModel.of<Device>(context).initialSetup = true;
                                    _resetCharacteristic.write(
                                        utf8.encode(_writeController.value.text));
                                    await widget.device.disconnect();
                                    Navigator.pop(context);
                                    Navigator.pushReplacementNamed(
                                      context, '/ble_connect'
                                    );
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
                          }
                        );
                      }
                  ),
                ),
              ],
            ),
          ),
          floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
          // floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
          floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () async{
                await widget.device.disconnect();
                ScopedModel.of<Device>(context).device = "";
                Navigator.pushReplacement(
                  context, MaterialPageRoute(
                    builder: (_) => new WelcomePage()
                ));
              }
          ),
        )
    );
  }

  Widget _sendingViewContent(){
    double width = MediaQuery
        .of(context)
        .size
        .width;
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        constraints: BoxConstraints.tightForFinite(width: width*0.7),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Latitude:',
                  style: const TextStyle(fontSize: 20.0, color: Colors.black, letterSpacing: 1.0),
                ),
                Text(
                  '$_latitude',
                  style: const TextStyle(fontSize: 20.0, color: Colors.black, letterSpacing: 1.0),
                ),
              ],
            ),
            Divider(
              thickness: 1.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Longitude:',
                  style: const TextStyle(fontSize: 20.0, color: Colors.black, letterSpacing: 1.0),
                ),
                Text(
                  '$_longitude',
                  style: const TextStyle(fontSize: 20.0, color: Colors.black, letterSpacing: 1.0),
                ),
              ],
            ),
            SizedBox(
              height: 5.0,
            ),
          ],
        ),
      );
  }

  bool _isListening() => (_positionStreamSubscription == null ||
      _positionStreamSubscription.isPaused);

  void _toggleListening() {
    if (_positionStreamSubscription == null) {
      final positionStream = getPositionStream();
      _positionStreamSubscription = positionStream.handleError((error) {
        _positionStreamSubscription.cancel();
        _positionStreamSubscription = null;
      })
      .listen((position) => setState(() {
        _position = position;
        print("\nGot Position --> Latitude: ${_position.longitude}, Longitude: ${_position.latitude}");
        updateUI();
        _updateLatLonCharacteristic();
      }));
      _positionStreamSubscription.pause();
    }
    setState(() {
      if (_positionStreamSubscription.isPaused) {
        _positionStreamSubscription.resume();
        print("Position Stream Resumed");
      } else {
        _positionStreamSubscription.pause();
        print("Position Stream Paused");
      }
    });
  }

  void _updateLatLonCharacteristic() async {
    await _latCharacteristic.write(utf8.encode( _position.latitude.toString()));
    await _lonCharacteristic.write(utf8.encode(_position.longitude.toString()));
  }

  @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription.cancel();
      _positionStreamSubscription = null;
    }
    widget.device.disconnect();
    super.dispose();
  }
}