import 'package:chatapp/View/Auth/register_screeen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sizer/sizer.dart';

import '../../Widgets/widgets.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final box = GetStorage();

  bool hide = false;
  bool loading = false;

  FirebaseAuth auth = FirebaseAuth.instance;

  var user = FirebaseFirestore.instance.collection("Users");

  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
          child: Center(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Text(
                    "Groupie",
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Text(
                    "Login now to see what they are to talking!",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13.sp,
                    ),
                  ),
                  Image.asset("assets/image/login.png"),
                  TextFormField(
                    controller: emailController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter Your Email';
                      }
                      if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                          .hasMatch(value)) {
                        return 'Please Enter a valid Email';
                      }
                      return null;
                    },
                    decoration: textInputDecoration.copyWith(
                      labelText: "Email",
                      prefixIcon: Icon(
                        Icons.email,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  TextFormField(
                    controller: passController,
                    obscureText: hide,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter Your Password';
                      }
                      if (value!.length < 6) {
                        return 'Please Enter 6 Length Password';
                      }
                      return null;
                    },
                    decoration: textInputDecoration.copyWith(
                      labelText: "Password",
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Theme.of(context).primaryColor,
                      ),
                      suffixIcon: InkResponse(
                        onTap: () {
                          setState(() {});
                          hide = !hide;
                        },
                        child: Icon(
                          hide ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFFee7b64),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        //  if (formKey.currentState!.validate()) {
                        try {
                          setState(() {
                            loading = true;
                          });
                          UserCredential credential =
                              await auth.signInWithEmailAndPassword(
                                  email: emailController.text,
                                  password: passController.text);

                          box.write("uid", credential.user!.uid);
                          var data = await user.doc(credential.user!.uid).get();
                          box.write("Name", data["Name"]);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Login Succesfully"),
                            ),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );

                          setState(() {
                            loading = false;
                          });
                        } on FirebaseAuthException catch (e) {
                          setState(() {
                            loading = false;
                          },);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${e.message}"),
                              backgroundColor: colorCode.primeryColor,
                            ),
                          );
                        }
                        //} else {
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(
                        //       content: Text("Unsuccessfully"),
                        //     ),
                        //   );
                        // }
                      },
                      child: const Text("Log In"),
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      const SizedBox(
                        width: 3,
                      ),
                      InkResponse(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Register here",
                          style:
                              TextStyle(decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
