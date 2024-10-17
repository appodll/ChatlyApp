import 'package:chatapp/Screen/Chats_Screen.dart';
import 'package:chatapp/Screen/loginScreen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountSave {
  Future<void>saveData()async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("User", true);
  }

  Future<void>getData()async{
    final prefs = await SharedPreferences.getInstance();
    var user_data_info  = prefs.getBool("User");
    if (user_data_info == true){
      Get.off(Chats());
    }else{
      Get.off(LoginScreen());
    }
  }

  Future<void>userinfo_save(email, password)async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("email", email);
    prefs.setString("password", password);
  }
}