import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NoticationHelpers {
  final _notification = FlutterLocalNotificationsPlugin();
  
  Future<void> showLocalNotification(RemoteMessage message) async {
    
    const androidInitialize = AndroidInitializationSettings("mipmap/ic_launcher");
    const initializationSettings = InitializationSettings(android: androidInitialize);
    await _notification.initialize(initializationSettings);
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
     await _notification.show(
      0, 
      message.notification!.title ?? 'Başlık Yok',
      message.notification!.body ?? 'Mesaj İçeriği Yok',
      platformChannelSpecifics,
      payload: 'Mesaj Tıklandığında Gönderilecek Veri',
    );
}
  

}