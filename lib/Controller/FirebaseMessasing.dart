import 'dart:convert';

import 'package:chatapp/function/notication_helpers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FirebaseApi{
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNofitication()async{
    await _firebaseMessaging.requestPermission();

    final token = await _firebaseMessaging.getToken();
    var url = Uri.parse("https://appoaep.space/update_token");
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("email") != null){
      http.post(
        url,
        headers: {"Content-Type" : "application/json"},
        body: jsonEncode({
          "email" : prefs.getString("email"),
          "token" : token
        })
        );
    }
    print(token);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mesaj alındı: ${message.notification!.title}');
      
                    //Notification PUSH//
      NoticationHelpers().showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Mesaj uygulama açıldığında alındı: ${message.messageId}');
    });

  }
}