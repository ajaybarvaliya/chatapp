import 'dart:io';

import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chatapp/Widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:uuid/uuid.dart';

import 'home_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen(
      {Key? key,
      required this.name,
      required this.senderUid,
      this.profilePic,
      this.roomId})
      : super(key: key);
  final String name;
  final profilePic;
  final roomId;
  final String senderUid;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FirebaseStorage storage = FirebaseStorage.instance;
  ImagePicker imagePicker = ImagePicker();
  File? image;

  final box = GetStorage();

  final User? user = FirebaseAuth.instance.currentUser;

  CollectionReference chatRoom =
      FirebaseFirestore.instance.collection('ChatRoom');

  TextEditingController chat = TextEditingController();

  bool loading = false;

  ScrollController scrollController = ScrollController();

  Future<void> deleteAll() async {
    final collection =
        await chatRoom.doc(widget.roomId).collection('Chat').get();

    final batch = FirebaseFirestore.instance.batch();

    for (final doc in collection.docs) {
      batch.delete(doc.reference);
    }

    return batch.commit();
  }

  String number = "abcccc-deeeee";

  @override
  Widget build(BuildContext context) {
    List newNumbers = number.split("-");

    print('${newNumbers}');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(widget.name),
        leadingWidth: 85,
        leading: Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            InkResponse(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Container(
                height: 45,
                width: 45,
                color: Colors.white,
                child: widget.profilePic == null
                    ? Icon(
                        Icons.person,
                        color: colorCode.primeryColor,
                      )
                    : Image.network(widget.profilePic, fit: BoxFit.cover),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                // value: 1,
                onTap: () async {
                  setState(() {
                    loading = true;
                  });

                  deleteAll();

                  setState(() {
                    loading = false;
                  });

                  setState(() {});
                },
                child: const Text("Clear Chat"),
              ),
            ],
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Column(
          children: [
            Expanded(
              child: loading == true
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : StreamBuilder(
                      stream: chatRoom
                          .doc(widget.roomId)
                          .collection("Chat")
                          .orderBy('time')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            controller: scrollController,
                            physics: const BouncingScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> data =
                                  snapshot.data!.docs[index].data()
                                      as Map<String, dynamic>;
                              return Padding(
                                padding: const EdgeInsets.symmetric(),
                                child: Row(
                                  mainAxisAlignment:
                                      box.read("uid") == data['userid']
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onLongPress: () async {
                                        if (box.read("uid") == data['userid']) {
                                          await chatRoom
                                              .doc(widget.roomId)
                                              .collection("Chat")
                                              .doc(
                                                  snapshot.data!.docs[index].id)
                                              .delete();
                                        }
                                      },
                                      child: data["type"] == "text"
                                          ? BubbleSpecialThree(
                                              text: '${data['chat']}',
                                              color: box.read("uid") ==
                                                      data['userid']
                                                  ? colorCode.primeryColor
                                                  : Colors.grey,
                                              tail: false,
                                              textStyle: const TextStyle(
                                                  //  fontFamily: "Poppins",
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            )
                                          : Container(
                                              width: 50.w,
                                              height: 50.w,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 3, horizontal: 10),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 10),
                                              decoration: BoxDecoration(
                                                color: box.read("uid") ==
                                                        data['userid']
                                                    ? colorCode.primeryColor
                                                    : Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: data["image"] != ""
                                                  ? Image.network(
                                                      "${data["image"]}",
                                                      fit: BoxFit.cover)
                                                  : Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                            ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.h),
              child: Row(
                children: [
                  TextField(
                    controller: chat,
                    onSubmitted: (value) {
                      if (chat.text == '') {
                        return;
                      } else {
                        chatRoom.doc(widget.roomId).collection("Chat").add(
                          {
                            "chat": chat.text,
                            "userid": box.read("uid"),
                            "type": "text",
                            "receiverName": widget.name,
                            "receiverUid": widget.senderUid,
                            "time": DateTime.now(),
                          },
                        ).then(
                          (value) {
                            chatRoom.doc(widget.roomId).set(
                              {
                                "chat": value.id,
                                "userid": box.read("uid"),
                                "receiverUid": widget.senderUid,
                                "receiverName": widget.name,
                                "profilePic": widget.profilePic,
                                "time": DateTime.now()
                              },
                            );
                          },
                        );
                      }
                      chat.clear();
                    },
                    minLines: 1,
                    maxLines: 6,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: "Send a massage",
                      constraints: BoxConstraints(maxWidth: 80.w),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      suffixIcon: InkWell(
                        onTap: () {
                          if (chat.text == '') {
                            return;
                          } else {
                            scrollController.animateTo(
                              scrollController.position.maxScrollExtent,
                              curve: Curves.bounceInOut,
                              duration: const Duration(milliseconds: 500),
                            );

                            chatRoom.doc(widget.roomId).collection("Chat").add(
                              {
                                "chat": chat.text,
                                "userid": box.read("uid"),
                                "type": "text",
                                "receiverName": widget.name,
                                "receiverUid": widget.senderUid,
                                "time": DateTime.now(),
                              },
                            ).then(
                              (value) {
                                chatRoom.doc(widget.roomId).set({
                                  "userid": box.read("uid"),
                                  "receiverUid": widget.senderUid,
                                  "receiverName": widget.name,
                                  "profilePic": widget.profilePic,
                                  "time": DateTime.now()
                                });
                              },
                            );
                          }
                          chat.clear();
                        },
                        child: const Icon(
                          Icons.send,
                          color: Color(0xFFee7b64),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () async {
                      XFile? file = await imagePicker.pickImage(
                          source: ImageSource.gallery);

                      image = File(file!.path);
                      setState(() {});

                      print('PATH ${file.path}');

                      String fileName = Uuid().v1();

                      storage
                          .ref("FileImage/${fileName}.png")
                          .putFile(image!)
                          .then(
                        (uploadedImage) async {
                          String url = await uploadedImage.ref.getDownloadURL();

                          if (kDebugMode) {
                            print("URL $url");
                          }

                          await chatRoom
                              .doc(widget.roomId)
                              .collection("Chat")
                              .add(
                            {
                              "image": url,
                              "userid": box.read("uid"),
                              "receiverName": widget.name,
                              "receiverUid": widget.senderUid,
                              "time": DateTime.now(),
                            },
                          );
                        },
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Send image'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.blue,
                          margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height - 135,
                          ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 3.h,
                      backgroundColor: colorCode.primeryColor,
                      child: const Icon(Icons.image, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
