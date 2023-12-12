import 'package:chatapp/Widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sizer/sizer.dart';

import 'group_chat_room_screen.dart';

class GroupHomeScreen extends StatefulWidget {
  const GroupHomeScreen({Key? key}) : super(key: key);

  @override
  State<GroupHomeScreen> createState() => _GroupHomeScreenState();
}

class _GroupHomeScreenState extends State<GroupHomeScreen> {
  final box = GetStorage();
  bool loading = true;

  var user = FirebaseFirestore.instance.collection('Users');

  List groupList = [];

  void availableGroup() async {
    await user.doc(box.read("uid")).collection("Group").get().then((value) {
      setState(() {
        groupList = value.docs;
        loading = false;
      });
    });
  }

  @override
  void initState() {
    availableGroup();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Group"), backgroundColor: colorCode.primeryColor),
      // body: loading
      //     ? Center(
      //         child: CircularProgressIndicator(),
      //       )
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: groupList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupChatRoomScreen(
                            groupName: groupList[index]["name"],
                            groupChatId: groupList[index]["id"],
                            groupPic: groupList[index]["groupPicture"],
                          ),
                        ),
                      );
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        height: 14.w,
                        width: 14.w,
                        color: colorCode.primeryColor,
                        child: groupList[index]["groupPicture"] == null
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                              )
                            : Image.network(groupList[index]["groupPicture"],
                                fit: BoxFit.cover),
                      ),
                    ),
                    title: Text("${groupList[index]["name"]}"),
                  ),
                );
              },
            ),
    );
  }
}
