import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlocalisation/database/database_provider.dart';
import 'package:flutterlocalisation/models/localisation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_startup/flutter_startup.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:flutter_blue/flutter_blue.dart';

getFirstLocation() async {
  print("getfirst");
  //Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
  final position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  String line = "latitude : "+position.latitude.toString()+", longitude : "+position.longitude.toString();
  print(line);
}

getCurrentLocation() async {
  final position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  DateTime dateTime = DateTime.now();

  Localisation localisation = Localisation(
      latitude: position.latitude.toString(),
      longitude: position.longitude.toString(),
      time: dateTime.toString()
  );
  DatabaseProvider.db.insert(localisation).then((value) => print("id : "+value.id.toString()+" latitude : "+value.latitude+", longitude : "+value.longitude));
}

void isolate2(String arg) {
  FlutterStartup.startupReason.then((reason) {
    print("Isolate2 $reason");
  });

  Timer.periodic(
      Duration(seconds: 10), (timer) => getCurrentLocation());
}

Future<bool> scanBlue() async {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  // Start scanning
  flutterBlue.startScan(timeout: Duration(seconds: 4));

  // Listen to scan results
  flutterBlue.scanResults.listen((results) async {

    if(results.isEmpty){

      return false;
    }else{

      return true;
      // do something with scan results
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
      }
    }
  });

  flutterBlue.stopScan();
}

void isolate1(String arg) async {
  var isolate = await FlutterIsolate.spawn(isolate2, "hello2");
  isolate.pause();
  /*
  FlutterBlue flutterBlue = FlutterBlue.instance;
  // Start scanning
  flutterBlue.startScan(timeout: Duration(seconds: 4));

  // Listen to scan results
  flutterBlue.scanResults.listen((results) async {
    print("hani d5alt");
    if(results.isEmpty){
      print("Killing Isolate 2");
      isolate.pause();
    }else{
      print("hay hay 3la #####");
      isolate.resume();
      // do something with scan results
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
      }
    }
  });
  // Stop scanning
  //flutterBlue.stopScan();
  */

  var res = await scanBlue();
  if(res){
    print("pausing Isolate 2");
    isolate.pause();
  }else{
    print("hay hay 3la #####");
    isolate.resume();
  }

  FlutterStartup.startupReason.then((reason) {
    print("Isolate1 $reason");
  });
  Timer.periodic(
      Duration(seconds: 20), (timer) => print("Timer Running From Isolate 1"));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  getFirstLocation();
  /*
  final isolate = await FlutterIsolate.spawn(isolate1, "hello");
  Timer(Duration(seconds: 1200), () {
    print("Killing Isolate 2");
    isolate.kill();
  });

  DatabaseProvider.db.getLocalisations().then((value) => value.forEach((pos) { print(""+pos.id.toString()+" "+pos.latitude+" "+pos.longitude+" "+pos.time);}));
  final isolate = await FlutterIsolate.spawn(isolate1, "hello");
  Timer(Duration(seconds: 60), () {
    print("Killing Isolate 2");
    isolate.kill();
  });
    DateTime tempDate = new DateFormat("yyyy-MM-dd hh:mm:ss").parse(savedDateString); //Convert DateTime to String
    final difference = t1.difference(t2).inMinutes.toDouble(); //difference between 2 dates
  */
  runApp(MyApp());
}

class MyApp extends StatelessWidget {


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text("Location Services"),
        ),
        body: Align(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(""),
              FlatButton(
                onPressed: (){
                  getFirstLocation();
                  print("chacha");
                  DatabaseProvider.db.getLocalisations().then((value) => value.forEach((pos) { print(""+pos.id.toString()+" "+pos.latitude+" "+pos.longitude+" "+pos.time);}));
                },
                color: Colors.green,
                child: Text("Find location"),
              ),
              FlatButton(
                onPressed: (){
                  DatabaseProvider.db.delete().then((value) => print("number of rows deleted : $value"));
                },
                color: Colors.red,
                child: Text("Delete all"),
              ),
              FlatButton(
                onPressed: (){

                },
                color: Colors.grey,
                child: Text("Start background"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

