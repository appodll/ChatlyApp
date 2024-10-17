import 'package:chatapp/Controller/ProfileController.dart';
import 'package:chatapp/Screen/Chats_Screen.dart';
import 'package:chatapp/Screen/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSettings extends StatefulWidget {
  ProfileSettings({super.key,});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  RxString email = "".obs;
  Rx<TextEditingController> bio_controller = TextEditingController().obs;

  RxBool _isEditingBio = false.obs;

  final profile_controller = Get.put(Profilecontroller());

  Future<void>get_email()async{
    final prefs = await SharedPreferences.getInstance();
    email.value = prefs.getString("email")!;
  }

  @override
  Widget build(BuildContext context) {
    get_email();
    profile_controller.get_username();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: 
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: (){
                Get.back();
              }, icon: Icon(Icons.keyboard_arrow_left_rounded, size: 35,)),
              Text(" Home", style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.bold
              ),)
            ],
          )
      ),
      body: SafeArea(
        child: Obx(()=>
          Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text(
                    "Settings",
                    style: GoogleFonts.montserrat(
                        fontSize: 35, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Row(
                children: [
                  Stack(
                    children: [
                      InkWell(
                        onLongPress: (){
                          Get.to(PhotoView(imageProvider: NetworkImage(profile_controller.profile_image.value)));
                        },
                        child: Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: NetworkImage(profile_controller.profile_image.value),
                                      fit: BoxFit.cover),
                                      ),
                            ),
                      ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(onPressed: ()async{
                              await profile_controller.get_username();
                              await profile_controller.uploadImage(profile_controller.username);
                              await Future.delayed(Duration(milliseconds: 100));
                              profile_controller.get_profileImage();
                            }, icon: Icon(Icons.edit)))
                          
                          ],
                  ),
                        SizedBox(width: 10,),
                        Column(
                          children: [
                            Text(profile_controller.username.value, style: GoogleFonts.montserrat(
                              fontSize: 30,
                              fontWeight: FontWeight.bold
                            ),),
                            Text(email.value,style: GoogleFonts.montserrat(
                              fontSize: 15,
                            ))
                          ],
                        )
                        
                        
                        ],
              ),
              SizedBox(height: 20,),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.black)
                  ]
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: (){
                        setState(() {
                          _isEditingBio.value = !_isEditingBio.value;
                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                const Color.fromARGB(255, 184, 222, 253),
                                const Color.fromRGBO(33, 150, 243, 1)
                              ]),
                              shape: BoxShape.circle
                            ),
                            child: Icon(Icons.edit, color: Colors.white,)),
                          SizedBox(width: 10,),
                          Text("Edit Bio", style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w500
                          ),)
                        ],
                      ),
                    ),
                    SizedBox(height: 5,),
                    Container(
                      height: 1,
                      width: Get.width - 30,
                      color: Colors.grey,
                      ),
                    SizedBox(height: 5,),
                    InkWell(
                      onTap: ()async{
                        
                        Get.off(LoginScreen());
                        final prefs = await SharedPreferences.getInstance();
                        prefs.remove("User");
                        prefs.remove("email");
                        prefs.remove("password");
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                const Color.fromARGB(255, 253, 184, 184),
                                const Color.fromARGB(255, 243, 33, 33)
                              ]),
                              shape: BoxShape.circle
                            ),
                            child: Icon(Icons.logout_rounded, color: Colors.white,)),
                          SizedBox(width: 10,),
                          Text("Logout", style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w500
                          ),)
                        ],
                      ),
                    )
                  ],
                ),
              ),
              AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _isEditingBio.value ? 100 : 0,
            padding: EdgeInsets.all(16),
            child: _isEditingBio.value
                ? TextField(
                  controller: bio_controller.value,
                    decoration: InputDecoration(
                      suffix: IconButton(onPressed: (){
                        
                          profile_controller.add_bio(bio_controller.value.text, context);
                        bio_controller.value.clear();
                        
                        
                      }, icon: Icon(Icons.verified)),
                      hintText: "Enter your bio",
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 3, 0, 182)
                        )
                      ),
                    ),
                  )
                : SizedBox(),
          ),
            ],
          ),
        ),
      ),
    );
  }
}
