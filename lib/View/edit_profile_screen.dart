import 'dart:io';

import 'package:chatapp/Widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

final box = GetStorage();

class _EditProfileScreenState extends State<EditProfileScreen> {
  ImagePicker imagePicker = ImagePicker();

  FirebaseStorage storage = FirebaseStorage.instance;

  File? image;

  TextEditingController nameController = TextEditingController();
  TextEditingController gmailController = TextEditingController();

  int select = 0;

  var user = FirebaseFirestore.instance.collection('Users');

  bool loading = false;

  Map<String, dynamic>? users;

  Future<void> getData() async {
    setState(() {
      loading = true;
    });

    var data = await user.doc(box.read("uid")).get();

    users = data.data() as Map<String, dynamic>;

    nameController = TextEditingController(text: data["Name"]);
    gmailController = TextEditingController(text: data["Email"]);

    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    getData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              color: colorCode.primeryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: users!["profilePic"] == null && image == null
                                ? const Icon(
                                    (Icons.person),
                                    color: Colors.white,
                                  )
                                : image == null
                                    ? Image.network(
                                        users!["profilePic"],
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        image!,
                                        fit: BoxFit.cover,
                                      ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            XFile? file = await imagePicker.pickImage(
                                source: ImageSource.gallery);

                            image = File(file!.path);
                            setState(() {});

                            if (kDebugMode) {
                              print('PATH ${file.path}');
                            }
                          },
                          child: CircleAvatar(
                            backgroundColor: colorCode.primeryColor,
                            child: const Icon(Icons.camera_alt,
                                size: 20, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5.h,
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
                      height: 5.h,
                    ),
                    TextFormField(
                      controller: gmailController,
                      decoration: textInputDecoration.copyWith(
                        labelText: "Email",
                        prefixIcon: Icon(
                          Icons.email,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: colorCode.primeryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          if (image == null) {
                            user.doc(box.read("uid")).update({
                              "Name": nameController.text,
                              "Email": gmailController.text,
                              "profilePic": users!["profilePic"],
                            });
                          } else {
                            storage
                                .ref("profile/${box.read("uid")}.png")
                                .putFile(image!)
                                .then((uploadedImage) async {
                              String url =
                                  await uploadedImage.ref.getDownloadURL();

                              if (kDebugMode) {
                                print("URL $url");
                              }

                              user.doc(box.read("uid")).update({
                                "Name": nameController.text,
                                "Email": gmailController.text,
                                "profilePic": url,
                              });
                            });
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Successfully data updated"),
                            ),
                          );
                        },
                        child: const Text('update'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
