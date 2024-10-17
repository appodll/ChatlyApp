import 'dart:convert';
import 'dart:io';

import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profilecontroller extends GetxController{

  RxString my_id = "".obs;

  RxString username = "".obs;
  RxBool loading = false.obs;
  RxString profile_image = "".obs;
  File? selectfile;
  Future<void>get_username_API(email,password)async{
    loading.value = false;
    var url = Uri.parse("https://appoaep.space/get_account_info?email=$email&&password=$password");
    var repo = await http.get(
      url,
      headers: {"Content-Type" : "application/json"},
      );
    var jsonData = jsonDecode(repo.body);
    username.value = jsonData['username'];
    loading.value = true;
  }

  Future<void>get_username()async{
    final prefs = await SharedPreferences.getInstance();
    get_username_API(prefs.getString("email"), prefs.getString("password"));
  }

  Future<void>push_profile_image(username, image)async{
    var url = Uri.parse("https://appoaep.space/push_profile_image?username=${username}");
    var request = await http.MultipartRequest("POST", url);
    request.files.add(await http.MultipartFile.fromPath("profile_image", image.path));
    var repo = await request.send();
    print(repo.statusCode);
  }

  
  Future<void>uploadImage(username)async{
    final picker = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picker != null){
      selectfile = File(picker.path);
      Profilecontroller().push_profile_image(username, selectfile);
    }
    
  }

  
  Future<void>get_profileImage()async{
    final prefs = await SharedPreferences.getInstance();
    var email = prefs.getString("email");
    profile_image.value = "https://appoaep.space/get_profile_image?email=${email}&timestamp=${DateTime.now().millisecondsSinceEpoch}";
    
  }

  Future<void>my_account_info()async{
    loading.value = false;
    final prefs = await SharedPreferences.getInstance();
    var email = prefs.getString("email");
    var url = Uri.parse("https://appoaep.space/account_info?email=${email}");
    var repo = await http.get(
      url,
      headers: {"Content-Type" : "application/json"},
      );
    var jsonData = jsonDecode(repo.body);

    my_id.value = jsonData['id'].toString();
    loading.value = true;
  }

  Future<void>add_bio(bio, context)async{
    final prefs = await SharedPreferences.getInstance();
    var email = prefs.getString("email");
    var url = Uri.parse("https://appoaep.space/add_bio");
    var repo = await http.post(
      url,
      headers: {"Content-Type" : "application/json"},
      body: jsonEncode({
        "email" : email,
        "bio" : bio
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
  
}