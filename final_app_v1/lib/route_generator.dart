import 'package:final_app_v1/ble_gps_write_test_page.dart';
import 'package:final_app_v1/bluetooth_connect_page.dart';
import 'package:flutter/material.dart';
import 'package:final_app_v1/welcome_page.dart';
import 'package:flutter_blue/flutter_blue.dart';

class RouteGenerator{
  static Route<dynamic> generalRoute(RouteSettings settings){

    final dynamic args = settings.arguments;

    print('\n Args: ${settings.arguments} \n ');

    switch(settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return WelcomePage(
              //connected: true,
            );
          },
        );
        break;

      case '/ble_connect':
        return MaterialPageRoute(
          builder: (_) => BluetoothConnectPage()
        );
        break;

      case '/gps_data_send':
        if(args is BluetoothDevice){
          return MaterialPageRoute(
            builder: (BuildContext context){
              return PositionWriteWidget(
                device: args,
              );
            }
          );
        }
        break;
    }
    return _errorRoute();
  }

  static Route<dynamic> _errorRoute(){
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Error'),
          ),
          body: Center(
            child: Text(
              'ERROR',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.normal,
              ),
            ),
          ),
        );
      }
    );
  }
}