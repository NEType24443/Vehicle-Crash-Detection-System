import 'package:final_app_v1/initial_service_page.dart';
import 'package:flutter/material.dart';
import 'package:final_app_v1/welcome_page.dart';
import 'package:final_app_v1/route_generator.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:final_app_v1/connected_device.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  Device dev = Device();
  // BluetoothDevice device;

  @override
  Widget build(BuildContext context) {

    return ScopedModel<Device>(
      model: Device(),
      child: MaterialApp(
        title: 'Final App V1',
        theme: ThemeData(
          primarySwatch: Colors.grey,
        ),
        home: WelcomePage(), //InitialServiceWrite(device: device,),
        onGenerateRoute: RouteGenerator.generalRoute,
        ),
    );
  }
}