import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:permission_handler/permission_handler.dart';

class MyBackgroundTask{
  Future<void> initializeService() async {
    var status = await Permission.notification.status;
    if(status.isDenied){
      final PermissionStatus status = await Permission.notification.request();
      if(status.isGranted){
        final service = FlutterBackgroundService();
        await service.configure(
            iosConfiguration: IosConfiguration(
                autoStart: false
            ),
            androidConfiguration: AndroidConfiguration(
                onStart: onStart,
                isForegroundMode: true,
                autoStart: false,
                autoStartOnBoot: false
            )
        );
        await service.startService();
      }
    }else if(status.isGranted){
      final service = FlutterBackgroundService();
      await service.configure(
          iosConfiguration: IosConfiguration(
              autoStart: false
          ),
          androidConfiguration: AndroidConfiguration(
              onStart: onStart,
              isForegroundMode: true,
              autoStart: false,
              autoStartOnBoot: false
          )
      );
      await service.startService();
    }
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service)async{

    MyBackgroundTask myBackgroundTask = MyBackgroundTask();

    if(service is AndroidServiceInstance){
      service.on('setAsForeground').listen((event) async {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    if(service is AndroidServiceInstance){
      if(await service.isForegroundService()){
        service.setForegroundNotificationInfo(
            title: 'Background Task',
            content: 'Background service for testing'
        );

        Future.delayed(Duration(seconds: 15), () async{
          bool status = await FlutterOverlayWindow.isPermissionGranted();

          print("Status of overlay: $status");
          if(status){
            if (await FlutterOverlayWindow.isActive()) return;
            await FlutterOverlayWindow.shareData("Demo Id, Demo Data");
            await FlutterOverlayWindow.showOverlay(
              enableDrag: true,
              visibility: NotificationVisibility.visibilityPublic,
              positionGravity: PositionGravity.auto,
              height: 400,
              width: WindowSize.matchParent,
              startPosition: const OverlayPosition(0, 0),
            );
          }
        });

      }
    }
  }
}