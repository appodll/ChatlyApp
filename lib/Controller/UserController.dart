import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class Usercontroller extends GetxController{
  RxList all_users = RxList();
  Future<void>get_all_users()async{
    var url = Uri.parse("https://appoaep.space/all_users");
    var repo = await http.get(
      url,
      headers: {"Content-Type" : "application/json"}
      );
    all_users.value = jsonDecode(repo.body);
  }
}