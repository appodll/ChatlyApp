import 'package:chatapp/Controller/messageController.dart';
import 'package:chatapp/Model/All_Friends_Model.dart';
import 'package:chatapp/Model/Friends.dart';
import 'package:chatapp/Screen/Message_Screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Controller/ProfileController.dart';
import '../Controller/groupElementController.dart';

class AllFriendScreen extends StatefulWidget {
  const AllFriendScreen({super.key});

  @override
  State<AllFriendScreen> createState() => _AllFriendScreenState();
}

class _AllFriendScreenState extends State<AllFriendScreen> {
  Container? status_icon;
  Future<void> init()async{
    final profile_controller = Get.put(Profilecontroller());
    final group_controller = Get.put(Groupelementcontroller());
    await profile_controller.my_account_info();
    await group_controller.all_friends(int.parse(profile_controller.my_id.value));
  }
  
  @override
  void initState() {
    super.initState();
    init();
  }
  @override
  Widget build(BuildContext context) {
    final profile_controller = Get.put(Profilecontroller());
    final group_controller = Get.put(Groupelementcontroller());
    final message_controller = Get.put(Messagecontroller());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(()=>
        group_controller.loading_fri.value == true?SafeArea(
          child: Column(
            children: [
              SizedBox(height: 10,),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text(
                    "Friends",
                    style: GoogleFonts.montserrat(
                        fontSize: 35, fontWeight: FontWeight.bold),
                  ),
        
                ),
              ),
              Expanded(
                child: group_controller.friends.isEmpty?Center(child: Text("Your friendship list is empty.", 
                        style: GoogleFonts.montserrat(fontSize: 15),)):Container(
                          height: 100,
                          child: ListView.builder(
                            itemCount: group_controller.friends.value.length,
                            itemBuilder: (context, index) {
                              var name = group_controller.friends[index]['name'];
                              var status = group_controller.friends[index]['status'];
                              if (status == "online"){
                                status_icon = Container(child: Icon(Icons.circle, color: Colors.green,size: 17,shadows: [
                                  BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.4), blurRadius: 10),
                                ],),);
                              }else{
                                status_icon = Container();
                              }
                              return InkWell(
                                onTap: ()async{
                                  Get.to(MessageScreen(
                                    token: group_controller.friends[index]['token'],
                                    status: group_controller.friends[index]['status'],
                                    sender_id: int.parse(profile_controller.my_id.toString()),
                                    receiver_id: int.parse(group_controller.friends[index]['id'].toString()),
                                    send_message: () async{
                                      var message = message_controller.message_controller.value.text;
                                        if (message.trim().isNotEmpty){
                                        await group_controller.push_receiver_group_members(int.parse(group_controller.friends[index]['id'].toString()), int.parse(profile_controller.my_id.toString()));
                                        message_controller.send_message(int.parse(profile_controller.my_id.toString()), int.parse(group_controller.friends[index]['id'].toString()), message_controller.message_controller.value.text, "TEXT");
                                        if (status != "online"){
                                          message_controller.push_nofitication(group_controller.friends[index]['token'], profile_controller.username.value, message_controller.message_controller.value.text);
                                        }
                                        message_controller.message_controller.value.clear();
                                        
                                      }
                                    },
                                    profile_image: "https://appoaep.space/get_profile_image?email=${group_controller.friends[index]["email"]}", 
                                    name: name
                                    ),
                                    
                                    transition: Transition.rightToLeft,
                                    duration: Duration(milliseconds: 500));
                                    
                                 
                                },
                                child: AllFriendsModel(
                                  last_message_name: group_controller.friends[index]["message"].toString() != null?group_controller.friends[index]["last_message_username"]:"Boş",
                                  last_message: group_controller.friends[index]["message"].toString() != null?group_controller.friends[index]['message']["message"].toString():"Boş",
                                  status_icon: status_icon,
                                  receiver_id: int.parse(group_controller.friends[index]['id'].toString()),
                                  sender_id: int.parse(profile_controller.my_id.toString()),
                                  name: name, 
                                  profile_image: group_controller.friends[index]['email'], 
                                  bio: group_controller.friends[index]['bio'],
                                  
                                  ));
                            },),
                        ),)
            ],
          ),
        ):Center(child: CircularProgressIndicator(),),
      ),
    );
  }
}
