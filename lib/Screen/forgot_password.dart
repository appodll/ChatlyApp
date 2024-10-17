import 'package:chatapp/Controller/Auth.dart';
import 'package:chatapp/Screen/OTP_password.dart';
import 'package:chatapp/Screen/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasword extends StatelessWidget {
  final email;
   ForgotPasword({super.key, @required this.email});


  Rx<TextEditingController> password = TextEditingController().obs;
  @override
  Widget build(BuildContext context) {
    final _auth = Get.put(Auth());
    return Scaffold(
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
                      "Enter your new password",
                      style: GoogleFonts.montserrat(
                          fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Enter the new password to get old reset",
                      style: GoogleFonts.montserrat(fontSize: 15),
                    ),
                    Text(
                      "password",
                      style: GoogleFonts.montserrat(fontSize: 15),
                    )
                  ],
                ),
                TextField(
                  controller: password.value,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                      filled: true,
                      fillColor: Color.fromRGBO(241, 244, 255, 1),
                      hintText: "Password",
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
        
                    _auth.reset_password(email, password.value.text, context);
                  },
                  child: Text(
                    "Reset Password",
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
