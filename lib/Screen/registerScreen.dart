import 'package:chatapp/Controller/Auth.dart';
import 'package:chatapp/Screen/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatefulWidget {
   RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  RxBool visibility_bool = true.obs;
  Rx<TextEditingController> username = TextEditingController().obs;
  Rx<TextEditingController> email = TextEditingController().obs;
  Rx<TextEditingController> password = TextEditingController().obs;
  @override
  final _auth = Get.put(Auth());
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: Get.width,
      height: Get.height,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("lib/image/Login Screen.png"),
              fit: BoxFit.cover)),
      child: Obx(()=>
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    "Create Account",
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 3, 0, 182)),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        Text(
                        "Create an account so you can explore all",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("the existing jobs",style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),)
                      
                      ],
                    ),
                  )
                ],
              ),
              Container(
                width: Get.width - 50,
                child: Column(
                  children: [
                    TextField(
                      controller: username.value,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.account_circle_outlined),
                          filled: true,
                          fillColor: Color.fromRGBO(241, 244, 255, 1),
                          hintText: "Username",
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13),
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 3, 0, 182))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.transparent))),
                    ),
                    SizedBox(
                      height: 25,
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
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 3, 0, 182))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.transparent))),
                    ),
                    SizedBox(
                      height: 25,
                    ),
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
                  ],
                ),
              ),
              Column(
                children: [
                  ElevatedButton(
                  onPressed: () {
                    _auth.register(username.value.text, email.value.text, password.value.text, context);
                  },
                  child: Text(
                    "Sign Up",
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
                  Get.to(LoginScreen(), transition: Transition.leftToRight,
                  duration: Duration(milliseconds: 500));
        
                }, child: Text("Already have an account", style: TextStyle(
                  color: Colors.black,
                  fontSize: 15
                ),))
                ],
              ),
        
            ],
          ),
        ),
      ),
    ));
  }
}
