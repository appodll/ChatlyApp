import 'package:chatapp/Controller/Auth.dart';
import 'package:chatapp/Screen/OTP_password.dart';
import 'package:chatapp/Screen/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotEmail extends StatelessWidget {
  
  ForgotEmail({super.key});


  Rx<TextEditingController> email = TextEditingController().obs;
  @override
  Widget build(BuildContext context) {
    final _auth = Get.put(Auth());
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: IconButton(onPressed: (){
          Get.off(LoginScreen());
        }, icon: Icon(Icons.home, size: 40,)),
      ),
      backgroundColor: Colors.white,
      body: Obx(()=>
        SafeArea(
            child: Center(
          child: Container(
            width: Get.width - 30,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Enter your email",
                      style: GoogleFonts.montserrat(
                          fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Enter the email adress to get OTP reset your",
                      style: GoogleFonts.montserrat(fontSize: 15),
                    ),
                    Text(
                      "password",
                      style: GoogleFonts.montserrat(fontSize: 15),
                    )
                  ],
                ),
                TextField(
                  controller: email.value,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: Color.fromRGBO(241, 244, 255, 1),
                      hintText: "Email",
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide:
                              BorderSide(color: Color.fromARGB(255, 3, 0, 182))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.transparent))),
                ),
               
                ElevatedButton(
                  onPressed: () {
        
                    _auth.forgot_password(email.value.text, context);
                  },
                  child: Text(
                    "Verify",
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                          Color.fromARGB(255, 47, 100, 247)),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      minimumSize: WidgetStatePropertyAll(Size(300, 70))),
                )
              ],
            ),
          ),
        )),
      ),
    );
  }
}
