import 'package:chatapp/Widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';

import 'create_group_screen.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({Key? key}) : super(key: key);

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

final box = GetStorage();

class _AddMemberScreenState extends State<AddMemberScreen> {
  TextEditingController editingController = TextEditingController();

  List<Map<String, dynamic>> memberList = [];

  var user1 = FirebaseFirestore.instance.collection('Users');

  var user = FirebaseFirestore.instance.collection('Users').where(
        "userUid",
        isNotEqualTo: box.read("uid"),
      );

  List<Map<String, dynamic>> nameList = [];
  List<Map<String, dynamic>> compaireList = [];

  FirebaseAuth auth = FirebaseAuth.instance;

  void getCureenUserDetails() async {
    await user1.doc(box.read("uid")).get().then(
      (data1) {
        setState(() {
          memberList.add({
            "Name": "${data1["Name"]}",
            "Email": "${data1["Email"]}",
            "profilePic": "${data1["profilePic"]}",
            "userUid": "${data1["userUid"]}",
            "Admin": true,
          });
          box.write("Name", data1["Name"]);
        });
      },
    );
  }

  Future<void> getData() async {
    var data = await user.get();

    for (var doc in data.docs) {
      var data2 = doc.data();

      var usersDetail = {
        "Name": "${data2["Name"]}",
        "Email": "${data2["Email"]}",
        "profilePic": "${data2["profilePic"]}",
        "userUid": "${data2["userUid"]}",
      };

      nameList.add(usersDetail);
    }
  }

  @override
  void initState() {
    getData();
    compaireList = nameList;
    getCureenUserDetails();

    super.initState();
  }

  void filterSearchResults(String query) {
    setState(() {
      compaireList = nameList
          .where((item) => item.toString().contains(query.toString()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: TextField(
          onChanged: (value) {
            filterSearchResults(value);
          },
          controller: editingController,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
            hintText: "Search",
            hintStyle: TextStyle(color: Colors.white),
            suffixIcon: InkResponse(
                onTap: () {
                  editingController.clear();
                  compaireList.clear();
                  setState(() {});
                },
                child: Icon(Icons.cancel, color: Colors.white, size: 20)),
          ),
        ),
      ),
      floatingActionButton: memberList.length >= 2
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    PageTransition(
                        child: CreateGroupScreen(memberList: memberList),
                        type: PageTransitionType.fade));
              },
              child: Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
              backgroundColor: colorCode.primeryColor)
          : SizedBox(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: colorCode.primeryColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  child: Text(
                    "${memberList.length} Members",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 6,
            ),
            memberList.isEmpty
                ? Container(
                    width: double.infinity,
                    height: 70,
                    child: Center(
                      child: Text("No member"),
                    ),
                  )
                : Container(
                    height: 90,
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: memberList.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            memberList[index]["userUid"] == box.read("uid")
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text("Admin"),
                                  )
                                : SizedBox(height: 2.1.h),
                            Container(
                              height: 70,
                              width: 170,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                              ),
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: ListTile(
                                onTap: () {
                                  if (memberList[index]["userUid"] !=
                                      box.read("uid")) {
                                    setState(() {
                                      memberList.removeAt(index);
                                    });
                                  }
                                },
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    child: Image.network(
                                        memberList[index]["profilePic"],
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                subtitle: Text(
                                  memberList[index]["Email"],
                                  overflow: TextOverflow.ellipsis,
                                ),
                                title: Text(
                                  "${memberList[index]["Name"]}",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
            Divider(color: Colors.black),
            Expanded(
              child: compaireList.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: compaireList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            bool alreadyExist = false;
                            for (int i = 0; i < memberList.length; i++) {
                              if (memberList[i]["userUid"] ==
                                  compaireList[index]["userUid"]) {
                                alreadyExist = true;
                              }
                            }

                            if (!alreadyExist) {
                              setState(() {
                                memberList.add({
                                  "Name": "${compaireList[index]["Name"]}",
                                  "Email": "${compaireList[index]["Email"]}",
                                  "profilePic":
                                      "${compaireList[index]["profilePic"]}",
                                  "userUid":
                                      "${compaireList[index]["userUid"]}",
                                  "Admin": false,
                                });

                                compaireList.clear();
                              });
                            }
                          },
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              height: 14.w,
                              width: 14.w,
                              color: colorCode.primeryColor,
                              child: compaireList[index]["profilePic"] == null
                                  ? Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    )
                                  : Image.network(
                                      compaireList[index]["profilePic"],
                                      fit: BoxFit.cover),
                            ),
                          ),
                          title: Text('${compaireList[index]["Name"]}'),
                          subtitle: Text('${compaireList[index]['Email']}'),
                        );
                      })
                  : Center(
                      child: const Text("No Data Found"),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
