import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionController {
  Future<void> requestPermission()async{
    final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
    final prefs = await SharedPreferences.getInstance();
    final status = await Permission.microphone.request();
    if (status.isGranted){
      _recorder.startRecorder();
      prefs.setBool("permission", true);
    }else if(status.isDenied){
      print('microphone denied');
    }else if(status.isPermanentlyDenied){
      openAppSettings();
    }
    
  }
}