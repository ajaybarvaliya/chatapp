import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:uuid/uuid.dart';

import '../../Widgets/widgets.dart';
import 'group_home_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key, required this.memberList})
      : super(key: key);
  final List<Map<String, dynamic>> memberList;

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  FirebaseStorage storage = FirebaseStorage.instance;
  ImagePicker imagePicker = ImagePicker();
  File? image;
  final box = GetStorage();

  TextEditingController groupController = TextEditingController();

  var group = FirebaseFirestore.instance.collection('Group');
  var user = FirebaseFirestore.instance.collection('Users');
  var chatRoom = FirebaseFirestore.instance.collection('ChatRoom');

  bool loading = false;

  void createGroup() async {
    setState(() {
      loading = true;
    });

    String groupId = Uuid().v1();

    await group.doc(groupId).set({
      "member": widget.memberList,
      "id": groupId,
    });

    for (int i = 0; i < widget.memberList.length; i++) {
      String uid = widget.memberList[i]["userUid"];

      if (image == null) {
        await user.doc(uid).collection("Group").doc(groupId).set({
          "name": groupController.text,
          "id": groupId,
          "groupPicture": null
        });
      } else {
        storage.ref("profile/${box.read("uid")}.png").putFile(image!).then(
          (uploadedImage) async {
            String url = await uploadedImage.ref.getDownloadURL();

            if (kDebugMode) {
              print("URL $url");
            }

            await user.doc(uid).collection("Group").doc(groupId).set({
              "name": groupController.text,
              "id": groupId,
              "groupPicture": url
            });
          },
        );
      }
    }

    await group.doc(groupId).collection("GroupChat").add({
      "message": "${box.read("Name")}created this group",
      "type": "notify",
    });
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: formKey,
            child: loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: [
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
                        height: 50,
                      ),
                      TextFormField(
                        controller: groupController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Your GroupName';
                          }
                          return null;
                        },
                        decoration: textInputDecoration.copyWith(
                          labelText: "Enter group name",
                          prefixIcon: Icon(
                            Icons.groups_outlined,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () async {
                          createGroup();
                          if (formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Group created"),
                              ),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupHomeScreen(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Unsuccesfully"),
                              ),
                            );
                          }
                        },
                        child: Text("Create Group"),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
