import 'dart:io';

import 'package:chatapp/View/search_screen.dart';
import 'package:chatapp/Widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'Auth/login_screen.dart';
import 'Group/add_member_screen.dart';
import 'Group/group_home_screen.dart';
import 'chat_screen.dart';
import 'edit_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List icon = [Icons.groups_outlined, Icons.home];

  List<String> fieldName = ["New Group", "Home Group"];

  FirebaseStorage storage = FirebaseStorage.instance;

  ImagePicker imagePicker = ImagePicker();

  File? image;

  final box = GetStorage();

  var user = FirebaseFirestore.instance.collection('Users');

  CollectionReference chatroom =
      FirebaseFirestore.instance.collection('ChatRoom');

  TextEditingController nameController = TextEditingController();
  TextEditingController gmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: StreamBuilder<DocumentSnapshot>(
          stream: user.doc(box.read("uid")).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
              return Column(
                children: [
                  Container(
                    height: 25.h,
                    width: double.infinity,
                    color: colorCode.primeryColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 5.h,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Container(
                                  width: 22.w,
                                  height: 22.w,
                                  color: Colors.white,
                                  child: data["profilePic"] == null
                                      ? Icon(
                                          Icons.person,
                                          color: colorCode.primeryColor,
                                        )
                                      : Image.network(
                                          data["profilePic"],
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(),
                                child: InkResponse(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            child: const EditProfileScreen(),
                                            type: PageTransitionType
                                                .bottomToTop));
                                  },
                                  child: Container(
                                    height: 3.h,
                                    width: 20.w,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Edit Profile",
                                        style: TextStyle(
                                            fontSize: 10.sp,
                                            color: colorCode.primeryColor,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
                          Text(
                            data["Name"],
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 17.sp,
                                color: Colors.white),
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          Text(
                            data["Email"],
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    itemCount: icon.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          if (index == 0) {
                            Navigator.push(
                              context,
                              PageTransition(
                                  child: const AddMemberScreen(),
                                  type: PageTransitionType.fade),
                            );
                          }

                          if (index == 1) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GroupHomeScreen(),
                              ),
                            );
                          }
                        },
                        leading: Icon(
                          icon[index],
                        ),
                        title: Text(
                          fieldName[index],
                          style:
                              TextStyle(color: Colors.black, fontSize: 12.5.sp),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  InkResponse(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: SizedBox(
                                height: 25.h,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    Text(
                                      "Log out of\nyour account?",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    const Spacer(),
                                    const Divider(
                                      height: 0,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        await box.erase();

                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen(),
                                          ),
                                        );
                                      },
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: Center(
                                          child: Text(
                                            "Log out",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.sp,
                                                color: Colors.red),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Divider(height: 0),
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: SizedBox(
                                        height: 50,
                                        width: double.infinity,
                                        child: Center(
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      color: colorCode.primeryColor,
                      child: ListTile(
                        leading: const Icon(Icons.logout, color: Colors.white),
                        title: Text(
                          "Log out",
                          style:
                              TextStyle(color: Colors.white, fontSize: 14.sp),
                        ),
                      ),
                    ),
                  )
                ],
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
      appBar: AppBar(
        title: Text(
          "Groupie",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: InkResponse(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                      child: const SearchScreen(),
                      type: PageTransitionType.rightToLeftWithFade),
                );
              },
              child: const Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
          ),
        ],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: StreamBuilder(
        stream: chatroom
            .where("receiverUid", isEqualTo: box.read("receiverUid"))
            .where("userid", isEqualTo: box.read("uid"))
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data = snapshot.data!.docs[index]
                        .data() as Map<String, dynamic>;
                    return InkResponse(
                      onTap: () {
                        String getChatId() {
                          List<String> ids = [
                            box.read("uid"),
                            data["receiverUid"]
                          ];
                          ids.sort();
                          return ids.join('_');
                        }

                        box.write("useruid", data["userUid"]);

                        box.write("receiverUid", data["userUid"]);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              name: data["receiverName"],
                              senderUid: data["receiverUid"],
                              roomId: getChatId(),
                              profilePic:
                                  data["profilePic"], // data["profilePic"],
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            height: 14.w,
                            width: 14.w,
                            color: colorCode.primeryColor,
                            child: data["profilePic"] == null
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  )
                                : Image.network(data["profilePic"],
                                    fit: BoxFit.cover),
                          ),
                        ),
                        title: Text(
                          data["receiverName"],
                          style:
                              TextStyle(fontSize: 14.sp, color: Colors.black),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
