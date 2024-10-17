import 'package:chatapp/Controller/Auth.dart';
import 'package:chatapp/Screen/forgot_email.dart';
import 'package:chatapp/Screen/registerScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  RxBool visibility_bool = true.obs;
  Rx<TextEditingController> email = TextEditingController().obs;
  Rx<TextEditingController> password = TextEditingController().obs;
  @override
  Widget build(BuildContext context) {
    final _auth = Get.put(Auth());
    return Scaffold(
      body: Container(
        width: Get.width,
        height: Get.height,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("lib/image/Login Screen.png"))
        ),

        child: Obx(()=>
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                        "Login here",
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 3, 0, 182)),
                      ),
                      SizedBox(height: 5,),
          
                      Text(
                      "Welcome back you’ve",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("been missed!",style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),)
                      
                      ],
                ),
          
              Container(
                width: Get.width - 50,
                child: Column(
                  children: [
                    TextField(
                      controller: email.value,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: Color.fromRGBO(241, 244, 255, 1),
                            hintText: "Email",
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 3, 0, 182))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.transparent))),
                      ),
                      SizedBox(height: 25,),
                       TextField(
                        controller: password.value,
                        obscureText: visibility_bool.value,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(onPressed: (){
                              setState(() {
                                visibility_bool.value = !visibility_bool.value;
                              });
                            }, icon: Icon(visibility_bool.value == true? Icons.visibility : Icons.visibility_off)),
                            filled: true,
                            fillColor: Color.fromRGBO(241, 244, 255, 1),
                            hintText: "Password",
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 3, 0, 182))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.transparent))),
                      ),
                      SizedBox(height: 5,),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(onPressed: (){

                          Get.to(ForgotEmail(), transition: Transition.downToUp,
                          duration: Duration(milliseconds: 500));
                        }, child: Text("Forgot your Password ?", style: TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(12, 46, 169, 1)
                        ),)),
                      )
                  ],
                ),
              ),
              Column(
                children: [
                  ElevatedButton(
                  onPressed: () {
                    _auth.login(email.value.text, password.value.text, context);
                  },
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22
                      ),
                  ),
                  style: ButtonStyle(
                    elevation: WidgetStatePropertyAll(10),
                      backgroundColor: WidgetStatePropertyAll(Color.fromRGBO(31, 65, 187, 1)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      )),
                      minimumSize: WidgetStatePropertyAll(Size(350, 58))
                      ),
                ),
                SizedBox(height: 15,),
                TextButton(onPressed: (){
                  Get.to(RegisterScreen(), transition: Transition.rightToLeft,
                  duration: Duration(milliseconds: 500));
          
                }, child: Text("Create new account", style: TextStyle(
                  color: Colors.black,
                  fontSize: 15
                ),))
                ],
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}