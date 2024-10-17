import 'package:chatapp/Controller/Auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTP extends StatelessWidget {
  final email;
  OTP({super.key, @required this.email});
  Rx<TextEditingController> otp = TextEditingController().obs;
  @override
  Widget build(BuildContext context) {
    final _auth = Get.put(Auth());
    return Scaffold(
      body: Obx(()=>
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Center(
                child: Image(
                  width: 200,
                  height: 200,
                  image: AssetImage("lib/image/otp.png",),fit: BoxFit.cover,),
              ),
              Column(
                children: [
                  Text("OTP Verification", style: GoogleFonts.montserrat(
                  color: Color.fromRGBO(91, 91, 91, 1),
                  fontWeight: FontWeight.bold,
                  fontSize: 30
                ),),
                SizedBox(height: 25,),
               
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text("Enter the OTP sent to",style: GoogleFonts.montserrat(
                      fontSize: 17,
                      fontWeight: FontWeight.w500
                    )),
                    Text("  $email", style: GoogleFonts.montserrat(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      
                    ),
                    overflow: TextOverflow.ellipsis,)],
                ),
                
                ],
                
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: PinCodeTextField(
                  controller: otp.value,
                    cursorColor: Colors.transparent,
                    keyboardType: TextInputType.number,
                    appContext: context, 
                    length: 6,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.underline,
                      fieldHeight: 50,
                      fieldWidth: 50,
                      inactiveColor: Colors.blue
                    ),
                    ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Didn’t you receive the OTP?", style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w500
                ),),
                TextButton(onPressed: (){
                  _auth.resend_SMTP(email, context);
                }, child: Text("Resend OTP", style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 33, 89, 243)
                ),))
                ],
              ),
              ElevatedButton(onPressed: (){
                _auth.verify_OTP(email, otp.value.text, context);
              }, child: Text("Verify", style: TextStyle(color: Colors.white, 
              fontSize: 25),),
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 47, 100, 247)),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
                ),),
                minimumSize: WidgetStatePropertyAll(Size(330, 80))
              ),
              
              )
            ],
          ),
        ),
      )
    );
  }
}