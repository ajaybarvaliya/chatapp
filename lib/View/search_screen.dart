import 'package:chatapp/Widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sizer/sizer.dart';

import 'chat_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    Key? key,
  }) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

final box = GetStorage();

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController editingController = TextEditingController();

  var user = FirebaseFirestore.instance.collection('Users').where(
        "userUid",
        isNotEqualTo: box.read("uid"),
      );
//  CollectionReference Users = FirebaseFirestore.instance.collection('ChatRoom');

  List<Map<String, dynamic>> nameList = [];
  List<Map<String, dynamic>> compaireList = [];

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
            setState(() {});
          },
          controller: editingController,
          decoration: InputDecoration(
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            enabledBorder:
                const OutlineInputBorder(borderSide: BorderSide.none),
            hintText: "Search",
            hintStyle: const TextStyle(color: Colors.white),
            suffixIcon: InkResponse(
                onTap: () {
                  editingController.clear();
                  compaireList.clear();
                  setState(() {});
                },
                child: const Icon(Icons.cancel, color: Colors.white, size: 20)),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: compaireList.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: compaireList.length,
                        itemBuilder: (context, index) {
                          return InkResponse(
                            onTap: () {
                              String getChatId() {
                                List<String> ids = [
                                  box.read("uid"),
                                  compaireList[index]["userUid"]
                                ];
                                ids.sort();
                                return ids.join('_');
                              }

                              box.write("roomId", getChatId());

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    roomId: getChatId(),
                                    senderUid: compaireList[index]["userUid"],
                                    name: compaireList[index]!["Name"],
                                    profilePic:
                                        compaireList[index]!["profilePic"],
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
                                  child:
                                      compaireList[index]["profilePic"] == null
                                          ? const Icon(
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
                            ),
                          );
                        })
                    : const Center(
                        child: Text("No Data Found"),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
