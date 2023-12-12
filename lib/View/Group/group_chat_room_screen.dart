import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chatapp/Widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../edit_profile_screen.dart';
import '../home_screen.dart';

class GroupChatRoomScreen extends StatefulWidget {
  const GroupChatRoomScreen(
      {Key? key, this.groupChatId, this.groupName, this.groupPic})
      : super(key: key);
  final groupChatId;
  final groupName;
  final groupPic;

  @override
  State<GroupChatRoomScreen> createState() => _GroupChatRoomScreenState();
}

class _GroupChatRoomScreenState extends State<GroupChatRoomScreen> {
  var group = FirebaseFirestore.instance.collection('Group');
  ScrollController scrollController = ScrollController();
  TextEditingController chat = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(widget.groupName),
        leadingWidth: 85,
        leading: Row(
          children: [
            SizedBox(
              width: 10,
            ),
            InkResponse(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ),
                );
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Container(
                height: 45,
                width: 45,
                color: Colors.white,
                child: widget.groupPic == null
                    ? Icon(
                        Icons.person,
                        color: colorCode.primeryColor,
                      )
                    : Image.network(widget.groupPic, fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: group
                  .doc(widget.groupChatId)
                  .collection("GroupChat")
                  .orderBy("time")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    controller: scrollController,
                    physics: BouncingScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data = snapshot.data!.docs[index]
                          .data() as Map<String, dynamic>;
                      print("DATA  : ${data}");
                      return Padding(
                        padding: const EdgeInsets.symmetric(),
                        child: Row(
                          mainAxisAlignment: box.read("uid") == data['sendby']
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () async {
                                if (box.read("uid") == data['sendby']) {
                                  await group
                                      .doc(widget.groupChatId)
                                      .collection("GroupChat")
                                      .doc(snapshot.data!.docs[index].id)
                                      .delete();
                                }
                              },
                              child: Column(
                                children: [
                                  Text("${data["Name"]}"),
                                  BubbleSpecialThree(
                                    text: '${data['chat']}',
                                    color: box.read("uid") == data['sendby']
                                        ? colorCode.primeryColor
                                        : Colors.grey,
                                    tail: false,
                                    textStyle: TextStyle(
                                        //  fontFamily: "Poppins",
                                        color: Colors.white,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.h),
            child: TextField(
              controller: chat,
              onSubmitted: (value) {
                if (chat.text == '') {
                  return;
                } else {
                  group.doc(widget.groupChatId).collection("GroupChat").add(
                    {
                      "chat": chat.text,
                      "sendby": box.read("uid"),
                      "Name": box.read("Name"),
                      "type": 'text',
                      "time": DateTime.now(),
                    },
                  );
                  // ).then(
                  //       (value) {
                  //     Users.doc(widget.roomId).set(
                  //       {
                  //         "chat": value.id,
                  //         "userid": box.read("uid"),
                  //         "receiverUid": widget.senderUid,
                  //         "receiverName": widget.Name,
                  //         "profilePic": widget.profilePic
                  //       },
                  //     );
                  //   },
                  // );
                }
                chat.clear();
              },
              minLines: 1,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: "Send a massage",
                constraints: BoxConstraints(maxWidth: 90.w),
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
                        duration: Duration(milliseconds: 500),
                      );

                      group.doc(widget.groupChatId).collection("GroupChat").add(
                        {
                          "chat": chat.text,
                          "sendby": box.read("uid"),
                          "Name": box.read("Name"),
                          "type": 'text',
                          "time": DateTime.now(),
                        },
                      );
                      // ).then(
                      //   (value) {
                      //     print("aaaaaaaaaaaaaaaaaaa ${value.id}");
                      //
                      //     Users.doc(widget.roomId).set({
                      //       "userid": box.read("uid"),
                      //       "receiverUid": widget.senderUid,
                      //       "receiverName": widget.Name,
                      //       "profilePic": widget.profilePic
                      //     });
                      //   },
                      // );
                    }
                    box.write("chat", chat.text);
                    chat.clear();
                  },
                  child: const Icon(
                    Icons.send,
                    color: Color(0xFFee7b64),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

///
///
///
///
//
// import 'package:chatapp/Try/register_demo.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get_storage/get_storage.dart';
//
// class GroupChatRoomScreen extends StatefulWidget {
//   final String groupChatId, groupName;
//
//   GroupChatRoomScreen(
//       {required this.groupName, required this.groupChatId, Key? key})
//       : super(key: key);
//
//   @override
//   State<GroupChatRoomScreen> createState() => _GroupChatRoomScreenState();
// }
//
// class _GroupChatRoomScreenState extends State<GroupChatRoomScreen> {
//   final box = GetStorage();
//   final TextEditingController _message = TextEditingController();
//
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   void onSendMessage() async {
//     if (_message.text.isNotEmpty) {
//       Map<String, dynamic> chatData = {
//         "sendBy": box.read("Name"),
//         "message": _message.text,
//         "type": "text",
//         "time": FieldValue.serverTimestamp(),
//       };
//
//       _message.clear();
//
//       await _firestore
//           .collection('Group')
//           .doc(widget.groupChatId)
//           .collection('GroupChat')
//           .add(chatData);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.groupName),
//         actions: [],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               height: size.height / 1.27,
//               width: size.width,
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: _firestore
//                     .collection('Group')
//                     .doc(widget.groupChatId)
//                     .collection('GroupChat')
//                     .orderBy('time')
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     return ListView.builder(
//                       itemCount: snapshot.data!.docs.length,
//                       itemBuilder: (context, index) {
//                         Map<String, dynamic> chatMap =
//                             snapshot.data!.docs[index].data()
//                                 as Map<String, dynamic>;
//
//                         return messageTile(size, chatMap);
//                       },
//                     );
//                   } else {
//                     return Container();
//                   }
//                 },
//               ),
//             ),
//             Container(
//               height: size.height / 10,
//               width: size.width,
//               alignment: Alignment.center,
//               child: Container(
//                 height: size.height / 12,
//                 width: size.width / 1.1,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       height: size.height / 17,
//                       width: size.width / 1.3,
//                       child: TextField(
//                         controller: _message,
//                         decoration: InputDecoration(
//                             suffixIcon: IconButton(
//                               onPressed: () {},
//                               icon: Icon(Icons.photo),
//                             ),
//                             hintText: "Send Message",
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             )),
//                       ),
//                     ),
//                     IconButton(
//                         icon: Icon(Icons.send), onPressed: onSendMessage),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget messageTile(Size size, Map<String, dynamic> chatMap) {
//     return Builder(builder: (context) {
//       if (chatMap['type'] == "text") {
//         return Container(
//           width: size.width,
//           alignment: chatMap['sendBy'] == box.read("Name")
//               ? Alignment.centerRight
//               : Alignment.centerLeft,
//           child: Container(
//             padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
//             margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(15),
//               color: Colors.blue,
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   chatMap['sendBy'],
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(
//                   height: size.height / 200,
//                 ),
//                 Text(
//                   chatMap['message'],
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       } else if (chatMap['type'] == "img") {
//         return Container(
//           width: size.width,
//           alignment: chatMap['sendBy'] == box.read("Name")
//               ? Alignment.centerRight
//               : Alignment.centerLeft,
//           child: Container(
//             padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//             height: size.height / 2,
//             child: Image.network(
//               chatMap['message'],
//             ),
//           ),
//         );
//       } else if (chatMap['type'] == "notify") {
//         return Container(
//           width: size.width,
//           alignment: Alignment.center,
//           child: Container(
//             padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//             margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(5),
//               color: Colors.black38,
//             ),
//             child: Text(
//               chatMap['message'],
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         );
//       } else {
//         return SizedBox();
//       }
//     });
//   }
// }
