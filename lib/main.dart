import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:permission_handler/permission_handler.dart';

import 'background_service/my_background_task.dart';
import 'overlay_layout.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

@pragma("vm:entry-point")
void overlayMain()async{ ///ENTRY POINT OF OVERLAY WINDOW
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OverlayLayout(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool isServiceRunning = false;
  late FlutterBackgroundService service;

  @override
  void initState() {

    super.initState();

    checkNotificationPermission();
    checkOverlayWindowPermission();
    checkIfServiceIsRunning();
  }

  checkNotificationPermission()async{
    var status = await Permission.notification.status;

    if(status.isDenied){
      final PermissionStatus status = await Permission.notification.request();

      if(status.isGranted){
        print("Permission Granted");
      }else if(status.isDenied){
        print("Permission Denied");
      }
    }
  }

  checkOverlayWindowPermission()async{

    bool status = await FlutterOverlayWindow.isPermissionGranted();
    if(!status){
      bool? status = await FlutterOverlayWindow.requestPermission();

      print(status);
    }
  }

  checkIfServiceIsRunning()async{
    service = FlutterBackgroundService();
    isServiceRunning = await service.isRunning();

    print("isServiceRunning: $isServiceRunning");

    setState(() {
      isServiceRunning;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black12,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: isServiceRunning ? null : ()async{

                MyBackgroundTask myBackgroundTask = MyBackgroundTask();
                myBackgroundTask.initializeService();

                setState(() {
                  isServiceRunning = true;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(left: 50, right: 50),
                decoration: BoxDecoration(
                  color: isServiceRunning ? Colors.blue.withOpacity(0.5) : Colors.blue,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                      topRight: Radius.circular(10)),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 15, bottom: 15),
                    child: Text("START SERVICE",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isServiceRunning ? Colors.white.withOpacity(0.5) : Colors.white,
                            fontSize: 15)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
            InkWell(
              onTap: isServiceRunning ? ()async{
                if (isServiceRunning) {
                  service.invoke("stopService");
                  setState(() {
                    isServiceRunning = false;
                  });
                }
              } : null,
              child: Container(
                margin: const EdgeInsets.only(left: 50, right: 50),
                decoration: BoxDecoration(
                  color: isServiceRunning ? Colors.redAccent :  Colors.redAccent.withOpacity(0.5),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                      topRight: Radius.circular(10)),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 15, bottom: 15),
                    child: Text("END SERVICE",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isServiceRunning ? Colors.white : Colors.white.withOpacity(0.5),
                            fontSize: 15)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
