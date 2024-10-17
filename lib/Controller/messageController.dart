import 'dart:async';
import 'dart:convert';

import 'package:chatapp/Controller/ProfileController.dart';
import 'package:chatapp/Controller/groupElementController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class Messagecontroller extends GetxController{

  Rx<TextEditingController> message_controller = TextEditingController().obs;
  RxList messages_list = [].obs;
  RxList account_info_list = [].obs;
  Future<void>send_message(sender_id, receiver_id, message, type)async{
    var url = Uri.parse("https://appoaep.space/send_message");
    http.post(
      url,
      headers: {"Content-Type" : "application/json"},
      body: jsonEncode({
        "sender_id" : sender_id,
        "receiver_id" : receiver_id,
        "message" : message,
        "created_at_message" : DateTime.now().toString(),
        "message_type" : type
      })
      );
  }
  Stream<List<dynamic>>get_messages(sender_id, receiver_id) async* {
    Timer.periodic(Duration(seconds: 1),(t){
      
    });
    try{
      while(true){
        await Future.delayed(Duration(milliseconds: 500));
        var url = Uri.parse("https://appoaep.space/get_messages");
        var repo = await http.post(
        url,
        headers: {"Content-Type" : "application/json"},
        body: jsonEncode({
          "sender_id" : sender_id,
          "receiver_id" : receiver_id
        })
        );
        
        messages_list.value = jsonDecode(repo.body);
        yield messages_list;
      
    }
    }catch(e){
      print(e);
    }
  }

  Future<void>send_message_file(sender_id, receiver_id, created_at_message, message_type, file)async{
    Groupelementcontroller().push_receiver_group_members(receiver_id, sender_id);
    var url = Uri.parse("https://appoaep.space/send_message_file?sender_id=${sender_id}&&receiver_id=${receiver_id}&&created_at_message=${created_at_message}&&message_type=${message_type}");
    var request = http.MultipartRequest("POST", url);
    request.files.add(await http.MultipartFile.fromPath("file", file.path));
    await request.send();
    
  
  }

  
  Future<void>send_message_sound(sender_id, receiver_id, created_at_message, message_type, sound)async{
    Groupelementcontroller().push_receiver_group_members(receiver_id, sender_id);
    var url = Uri.parse("https://appoaep.space/send_message_sound?sender_id=${sender_id}&&receiver_id=${receiver_id}&&created_at_message=${created_at_message}&&message_type=${message_type}");
    var request = http.MultipartRequest('POST', url);
      if (sound != null) {
        var audioStream = http.ByteStream(sound.openRead());
        var audioLength = await sound.length();
        var multipartFile = http.MultipartFile('sound', audioStream, audioLength, filename: sound.path.split('/').last);
        request.files.add(multipartFile);
  }
  var response = await request.send();
  print(response.statusCode);

  }
  
  Future<void>deleted_message(created_at, sender_id, receiver_id)async{
    var url = Uri.parse("https://appoaep.space/deleted_messages?created_at=${created_at}&&sender_id=${sender_id}&&receiver_id=${receiver_id}");
    http.get(
      url,
      headers: {"Content-Type" : "application/json"}
      );
  }

  Future<void>push_nofitication(token, title, body)async{
    var url = Uri.parse("https://appoaep.space/send_notification");
    http.post(
      url,
      headers: {"Content-Type" : "application/json"},
      body: jsonEncode({
        "token" : token,
        "title" : title,
        "body" : body
      })
      );
  }
  RxList last_message = [].obs;
  RxString name = "".obs;
  Future<void>get_message_init(sender_id, receiver_id)async{
  var url = Uri.parse("https://appoaep.space/get_messages");
  var repo = await http.post(
    url,
    headers: {"Content-Type" : "application/json"},
    body: jsonEncode({
      "sender_id" : sender_id,
      "receiver_id" : receiver_id
    })
    );
  last_message.value = jsonDecode(repo.body);

}

Future<void>id_info(id)async{
  var url = Uri.parse("https://appoaep.space/id_info");
  var repo = await http.post(
    url,
    headers: {"Content-Type" : "application/json"},
    body: jsonEncode({
      "id" : id
    })
    );
  name.value = jsonDecode(repo.body)['name'];
  print(name);
}

}