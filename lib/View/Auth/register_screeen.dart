import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../Widgets/widgets.dart';
import '../home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  FirebaseStorage storage = FirebaseStorage.instance;
  ImagePicker imagePicker = ImagePicker();
  File? image;

  CollectionReference users = FirebaseFirestore.instance.collection('Users');
  bool hide = false;
  bool loading = false;

  final box = GetStorage();

  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: SingleChildScrollView(
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
                  "Create your account now to chat and explore",
                  style:
                      TextStyle(fontWeight: FontWeight.w400, fontSize: 13.sp),
                ),
                SizedBox(
                  height: 1.h,
                ),
                Container(
                  height: 65.w,
                  width: 100.w,
                  child: Image.asset("assets/image/register.png",
                      fit: BoxFit.cover),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: GestureDetector(
                    onTap: () async {
                      XFile? file = await imagePicker.pickImage(
                          source: ImageSource.gallery);

                      image = File(file!.path);
                      setState(() {});

                      print('PATH ${file.path}');
                    },
                    child: Container(
                      height: 30.w,
                      width: 30.w,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: image != null
                          ? Image.file(
                              image!,
                              fit: BoxFit.cover,
                            )
                          : const Center(
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                TextFormField(
                  controller: nameController,
                  decoration: textInputDecoration.copyWith(
                    labelText: "Name",
                    prefixIcon: Icon(
                      Icons.person,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                TextFormField(
                  controller: emailController,
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
                  width: 350,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        setState(() {
                          loading = true;
                        });
                        UserCredential credential =
                            await auth.createUserWithEmailAndPassword(
                                email: emailController.text,
                                password: passController.text);

                        box.write("uid", credential.user!.uid);

                        if (image == null) {
                          await users.doc(credential.user!.uid).set(
                            {
                              "Name": nameController.text,
                              "Email": emailController.text,
                              "Password": passController.text,
                              "profilePic": null,
                              "userUid": box.read("uid"),
                            },
                          );
                        } else {
                          storage
                              .ref("profile/${box.read("uid")}.png")
                              .putFile(image!)
                              .then(
                            (uploadedImage) async {
                              String url =
                                  await uploadedImage.ref.getDownloadURL();

                              if (kDebugMode) {
                                print("URL $url");
                              }

                              await users.doc(credential.user!.uid).set(
                                {
                                  "Name": nameController.text,
                                  "Email": emailController.text,
                                  "Password": passController.text,
                                  "profilePic": url,
                                  "userUid": box.read("uid"),
                                },
                              );
                            },
                          );
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Register Successfully"),
                          ),
                        );

                        box.write("Name", nameController.text);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(),
                          ),
                        );

                        setState(() {
                          loading = false;
                        });
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          loading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${e.message}"),
                          ),
                        );
                      }
                    },
                    child: const Text("Sign In"),
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    const SizedBox(
                      width: 3,
                    ),
                    InkResponse(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Login here",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
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
