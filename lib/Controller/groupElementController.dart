import 'dart:convert';

import 'package:chatapp/Controller/ProfileController.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


class Groupelementcontroller extends GetxController{
  RxList friends = [].obs;
  RxBool loading = RxBool(false);
  RxBool loading_fri = RxBool(false);
  Future<void>push_group_members(sender_id, receiver_id,context)async{
    var url = Uri.parse("https://appoaep.space/push_group_members");
    var repo = await http.post(
      url,
      headers: {"Content-Type" : "application/json"},
      body: jsonEncode({
        "sender_id" : sender_id,
        "receiver_id" : receiver_id
      })
      );
    var jsonData = jsonDecode(repo.body);
    DelightToastBar(
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      animationCurve: Curves.elasticOut,
      builder: (context) {
        return ToastCard(
        leading: Icon(Icons.notification_important_rounded),
        title: Text(jsonData['message'].toString()));
      }  , ).show(context);
  }
  Future<void>push_receiver_group_members(sender_id, receiver_id)async{
    var url = Uri.parse("https://appoaep.space/push_group_members");
    http.post(
      url,
      headers: {"Content-Type" : "application/json"},
      body: jsonEncode({
        "sender_id" : sender_id,
        "receiver_id" : receiver_id
      })
      );
    
  }

  Future<void>all_friends(sender_id)async{
    
    loading_fri.value = false;
    var url = Uri.parse("https://appoaep.space/all_friends");
    var repo = await http.post(
      url,
      headers: {"Content-Type" : "application/json"},
      body: jsonEncode({
        "sender_id" : sender_id
      })
      );
      var jsonData = jsonDecode(repo.body);
      
      friends.value = jsonData;
    loading_fri.value = true;
    print(friends);
  }

}