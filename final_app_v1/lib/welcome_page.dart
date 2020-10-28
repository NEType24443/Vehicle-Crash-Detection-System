import 'package:final_app_v1/connected_device.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:oktoast/oktoast.dart';

class WelcomePage extends StatelessWidget {

  FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    Stream<BluetoothState> _bluetoothState = flutterBlue.state;

    return OKToast(
      animationDuration: Duration(milliseconds: 400),
      animationCurve: Curves.easeInOutSine,
      child: StreamBuilder<BluetoothState>(
        stream: _bluetoothState,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            );
          }
          if (snapshot.hasData) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: height * 0.20,
                      ),
                      Container(
                        child: Text(
                          "Vehicle Crash Detector",
                          style: GoogleFonts.abel(
                              fontSize: height * 0.05 //30.0, // 40.0,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          "Connection App",
                          style: GoogleFonts.abel(
                              fontSize: height * 0.05 //30.0, // 40.0,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.15,
                      ),
                      Container(
                        padding: EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          color: _boxColor(snapshot.data),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20)
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _bluetoothIcon(snapshot.data),
                              color: Colors.grey[100],
                            ),
                            SizedBox(width: 10.0,),
                            Text(
                              _adapterState(snapshot.data),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[100],
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: height * 0.08,
                      ),
                      Container(
                        padding: EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20)
                          ),
                        ),
                        child: Text(
                          (ScopedModel
                              .of<Device>(context)
                              .device == '')
                              ? 'Not Connected'
                              : 'Connected to: ${ScopedModel
                              .of<Device>(context)
                              .device}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[100],
                            fontSize: 20,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.10,
                      ),
                      Container(
                        padding: EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey[600],
                        ),
                        child: FlatButton(
                            color: Colors.transparent,
                            child: Container(
                              child: Text(
                                'Scan for Device',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            onPressed: () {
                              if(snapshot.data == BluetoothState.on) {
                                print('\nOpening BluetoothConnectPage\n');
                                Navigator.pushReplacementNamed(context, '/ble_connect');
                              }
                              else showToast(
                                "Please turn on Bluetooth",
                                position: ToastPosition(
                                  align: Alignment.topCenter,
                                  offset: height*0.32
                                ),
                                backgroundColor: Colors.grey[700],
                                radius: 5.0,
                                textPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0)
                              );
                            }
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          else {  // Did not get snapshot yet
            return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        backgroundColor: Colors.redAccent[700],
                      ),
                      SizedBox(height: height*0.04,),
                      Text(
                        "Waiting for",
                        style: GoogleFonts.abel(
                          letterSpacing: 1.0,
                          fontSize: 17.0
                        ),
                      ),
                      Text(
                        "Bluetooth Adapter",
                        style: GoogleFonts.abel(
                            letterSpacing: 1.0,
                            fontSize: 17.0
                        ),
                      ),
                    ],
                  ),
                ),
            );
          }
        }
      ),
    );
  }

  IconData _bluetoothIcon(BluetoothState state){
      switch(state){
      case BluetoothState.turningOn:
      case BluetoothState.on:
        return Icons.bluetooth;
      default:
        return Icons.bluetooth_disabled;
    }
  }

  Color _boxColor(BluetoothState state){
    switch (state) {
      case BluetoothState.turningOn:
      case BluetoothState.on:
        return Colors.blueAccent[700];
      default:
        return Colors.grey[600];
    }
  }

  // ignore: missing_return
  String _adapterState(BluetoothState state) {
    switch (state) {
      case BluetoothState.turningOff :
        return "Switching Off";
      case BluetoothState.off :
        return "Switched Off";
      case BluetoothState.turningOn :
        return "Switching On";
      case BluetoothState.on :
        return "Switched On";
      case BluetoothState.unavailable :
        return "Unavavilable";
      case BluetoothState.unknown :
        return "Unknown";
      case BluetoothState.unauthorized :
        return "Unauthorised";
    }
  }
}