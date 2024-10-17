import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class Statuscontroller {

  Future<void>set_status(status)async{
    var url = Uri.parse("https://appoaep.space/set_status");
    final prefs = await SharedPreferences.getInstance();
    var email = prefs.getString("email");
    http.post(
      url,
      headers: {"Content-Type" : "application/json"},
      body: jsonEncode({
        "status" : status,
        "email" : email
      })
      
      );
  }

  Future<void>set_receiver_status(sender_id , receiver_id , status)async{
    var url = Uri.parse("https://appoaep.space/set_receiver_status");
    http.post(
      url,
      headers: {"Content-Type" : "application/json"},
      body: jsonEncode({
        "sender_id" : sender_id,
        "receiver_id" : receiver_id,
        "receiver_status" : status
      })
      );
  }

  Future<void>message_status(sender_id , receiver_id)async{
    var url = Uri.parse("https://appoaep.space/message_status");
    http.post(
      url,
      headers: {"Content-Type" : "application/json"},
      body: jsonEncode({
        "sender_id" : sender_id,
        "receiver_id" : receiver_id
      })
      );
  }


}