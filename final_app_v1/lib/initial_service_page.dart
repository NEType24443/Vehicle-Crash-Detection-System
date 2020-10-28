import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:final_app_v1/ble_gps_write_test_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:final_app_v1/rounded_button.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:final_app_v1/connected_device.dart';

class InitialServiceWrite extends StatefulWidget {
  InitialServiceWrite({
    Key key,
    @required
    this.device,
  }) : super(key: key);

  final BluetoothDevice device;
  final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();

  @override
  _InitialServiceWriteState createState() => _InitialServiceWriteState();
}

class _InitialServiceWriteState extends State<InitialServiceWrite> {
  final ScrollController _scrollController = ScrollController();
  List<BluetoothService> _services;

  BluetoothCharacteristic _ownerFirstNameCharacteristic,
                          _ownerLastNameCharacteristic,
                          _ownerNumberCharacteristic,
                          _ownerPasswordCharacteristic;

  String  _firstName = "",
          _lastName = "",
          _phoneNumber = "",
          _password = "";

  @override
  void initState(){ // Start of page
    super.initState();
    _getServices(); // Separate because async cannot be used for initState
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
      // _services.clear();
      _services = await widget.device.discoverServices();
    }
    if(_findOwnerService()){
      print("Can start writing now");
    }
    else{
      widget.device.disconnect();
      ScopedModel.of<Device>(context).update("");
      Navigator.pushReplacementNamed(context, "/");
    }
  }

  bool _findOwnerService(){
    bool fName = false, lName = false, pNum  = false, pswd  = false;
    for (BluetoothService service in _services) {
      print("Service UUID: ${service.uuid}\n |");
      for(BluetoothCharacteristic characteristic in service.characteristics){
        print(" |-> Characteristic UUID: ${characteristic.uuid}");
        if(characteristic.uuid.toString() == "00002a8a-5b8b-49bb-b5d3-ec3aed3ca178"){
          print(" ^--- GOT OWNER FIRST NAME CHAR ");
          _ownerFirstNameCharacteristic = characteristic;
          fName = true;
        }
        else if(characteristic.uuid.toString() == "00002a90-5b8b-49bb-b5d3-ec3aed3ca178"){
          print(" ^--- GOT OWNER LAST NAME CHAR ");
          _ownerLastNameCharacteristic = characteristic;
          lName = true;
        }
        else if(characteristic.uuid.toString() == "00002a8b-5b8b-49bb-b5d3-ec3aed3ca178"){
          print(" ^--- GOT PASSWORD CHAR ");
          _ownerPasswordCharacteristic = characteristic;
          pswd = true;
        }
        else if(characteristic.uuid.toString() == "00002a25-5b8b-49bb-b5d3-ec3aed3ca178"){
          print(" ^--- GOT OWNER NUMBER CHAR ");
          _ownerNumberCharacteristic = characteristic;
          pNum = true;
        }
      }
      print(" |_____________________\n");
    }
    return (fName && lName && pNum && pswd);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: KeyboardAvoider(
        autoScroll: true,
        child: ListView(
          controller: _scrollController,
          children:<Widget>[
            SizedBox(
              height: height*0.04,
            ),
            Padding(      // Main Title
              padding: EdgeInsets.all(height * 0.02),
              child: Text(
                'Register with  device',//${widget.device.name}',
                style: GoogleFonts.abel(
                  letterSpacing: 2.0,
                  fontSize: height * 0.06,
                  color: Colors.black87,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Lets get \nyou on board',
                style: GoogleFonts.abel(
                  letterSpacing: 2.0,
                  fontSize: height * 0.04,
                  color: Colors.black54,
                ),
              ),
            ),
            Padding(      // Main Title
              padding: EdgeInsets.all(height * 0.02),
              child: TextField(
                style: GoogleFonts.abel(
                  letterSpacing: 2.0,
                ),
                onChanged: (value) {
                  _firstName = value;
                  print("First Name: $_firstName");
                },
                decoration: InputDecoration(
                  hintText: 'First Name',
                ),
              ),
            ),
            Padding(    //  Last Name Field
              padding: EdgeInsets.all(height * 0.02),
              child: TextField(
                style: GoogleFonts.abel(
                  letterSpacing: 2.0,
                ),
                onChanged: (value) {
                  _lastName = value;
                  print("Last Name: $_lastName");
                },
                decoration: InputDecoration(
                  hintText: 'Last Name',
                ),
              ),
            ),
            Padding(    //  Phone Number Field
              padding: EdgeInsets.all(height * 0.02),
              child: TextField(
                style: GoogleFonts.abel(
                  letterSpacing: 2.0,
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  _phoneNumber = value;
                  print("Phone Number: $_phoneNumber");
                },
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                ),
              ),
            ),
            Padding(    //  Password Field
              padding: EdgeInsets.all(height * 0.02),
              child: TextField(
                style: GoogleFonts.abel(
                  letterSpacing: 2.0,
                ),
                obscureText: false,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  _password = value;
                  print("Password: $_password");
                },
                decoration: InputDecoration(
                  hintText: 'Password',
                ),
              ),
            ),
            Center(   //  Register Button
              child: RoundedButton(
                colour: Colors.blueAccent[700],
                title: 'Register',
                onPressed: () async {
                  print("Registering...");
                  try {
                    await _ownerNumberCharacteristic.write(
                        utf8.encode(_phoneNumber));
                    await _ownerFirstNameCharacteristic.write(
                        utf8.encode(_firstName));
                    await _ownerLastNameCharacteristic.write(
                        utf8.encode(_lastName));
                    await _ownerPasswordCharacteristic.write(
                        utf8.encode(_password));
                  }
                  catch(e) {
                    print(e);
                  }
                  finally {
                    ScopedModel.of<Device>(context).update(widget.device.name);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) {
                              return new PositionWriteWidget(
                                device: widget.device,
                              );
                            }
                        )
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
    // return Scaffold(
    //   body: SafeArea(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Padding(      // Main Title
    //           padding: EdgeInsets.all(height * 0.02),
    //           child: Text(
    //             'Register',
    //             style: GoogleFonts.abel(
    //               letterSpacing: 2.0,
    //               fontSize: height * 0.05,
    //               color: Colors.black87,
    //             ),
    //           ),
    //         ),
    //         Container(    // Invitation text
    //           width: width * 0.9,
    //           child: Padding(
    //             padding: EdgeInsets.all(20.0),
    //             child: Text(
    //               'Lets get \nyou on board',
    //               style: GoogleFonts.abel(
    //                 letterSpacing: 2.0,
    //                 fontSize: height * 0.04,
    //                 color: Colors.black54,
    //               ),
    //             ),
    //           ),
    //         ),
    //         Padding(    //  First Name Field
    //           padding: EdgeInsets.all(height * 0.02),
    //           child: TextField(
    //             style: GoogleFonts.abel(
    //               letterSpacing: 2.0,
    //             ),
    //             onChanged: (value) {
    //               _firstName = value;
    //               print("First Name: $_firstName");
    //             },
    //             decoration: InputDecoration(
    //               hintText: 'First Name',
    //             ),
    //           ),
    //         ),
    //         Padding(    //  Last Name Field
    //           padding: EdgeInsets.all(height * 0.02),
    //           child: TextField(
    //             style: GoogleFonts.abel(
    //               letterSpacing: 2.0,
    //             ),
    //             onChanged: (value) {
    //               _lastName = value;
    //               print("Last Name: $_lastName");
    //             },
    //             decoration: InputDecoration(
    //               hintText: 'Last Name',
    //             ),
    //           ),
    //         ),
    //         Padding(    //  Phone Number Field
    //           padding: EdgeInsets.all(height * 0.02),
    //           child: TextField(
    //             style: GoogleFonts.abel(
    //               letterSpacing: 2.0,
    //             ),
    //             keyboardType: TextInputType.phone,
    //             onChanged: (value) {
    //               _phoneNumber = value;
    //               print("Phone Number: $_phoneNumber");
    //             },
    //             decoration: InputDecoration(
    //               hintText: 'Phone Number',
    //             ),
    //           ),
    //         ),
    //         Padding(    //  Password Field
    //           padding: EdgeInsets.all(height * 0.02),
    //           child: TextField(
    //             style: GoogleFonts.abel(
    //               letterSpacing: 2.0,
    //             ),
    //             obscureText: false,
    //             keyboardType: TextInputType.text,
    //             onChanged: (value) {
    //               _password = value;
    //               print("Password: $_password");
    //             },
    //             decoration: InputDecoration(
    //               hintText: 'Password',
    //             ),
    //           ),
    //         ),
    //         Center(   //  Register Button
    //           child: RoundedButton(
    //             colour: Colors.blueAccent,
    //             title: 'Register',
    //             onPressed: () async {
    //               print("Registering...");
    //               try {
    //                 await _ownerNumberCharacteristic.write(
    //                     utf8.encode(_phoneNumber));
    //                 await _ownerFirstNameCharacteristic.write(
    //                     utf8.encode(_firstName));
    //                 await _ownerLastNameCharacteristic.write(
    //                     utf8.encode(_lastName));
    //                 await _ownerPasswordCharacteristic.write(
    //                     utf8.encode(_password));
    //               }
    //               catch(e) {
    //                 print(e);
    //               }
    //               finally {
    //                 ScopedModel.of<Device>(context).update(widget.device.name);
    //                 Navigator.pushReplacement(
    //                     context,
    //                     MaterialPageRoute(
    //                         builder: (BuildContext context) {
    //                           return new PositionWriteWidget(
    //                             device: widget.device,
    //                           );
    //                         }
    //                     )
    //                 );
    //               }
    //             },
    //           ),
    //         ),
    //       ],
    //     ),
    //   )
    // );
  }
}
