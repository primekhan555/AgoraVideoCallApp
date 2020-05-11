import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'globals.dart' as globals;
import 'src/pages/call.dart';
import 'OptionsPage.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  String channelId, receiverUID;
  Future<void> join() async {
    await _handleCameraAndMic();
    var route = MaterialPageRoute(
        builder: (context) => CallPage(
              channelName: channelId,
              receiverUID: receiverUID,
            ));
    await Navigator.of(context).push(route);
  }

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone,PermissionGroup.storage],
    );
  }

  check() {}
  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 2), (time) {
      Firestore.instance
          .collection("users")
          .document("${globals.uid}")
          .get()
          .then((s) {
        if (s.data["callevent"] == true) {
          print(s.data["callevent"]);
          String channelId = s.data["channelId"];
          var route = MaterialPageRoute(
              builder: (context) => OptionsPage(
                    channelId: channelId,
                  ));
          Navigator.of(context).push(route);
          time.cancel();
        } else {
          print("no call yet");
        }
      });
    });
    check();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection("users").snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            return Container(
              child: ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  String uid = snapshot.data.documents[index]['uid'];
                  if (globals.uid != uid) {
                    return InkWell(
                      onTap: () {
                        print("${snapshot.data.documents[index]['uid']}");
                        print("${globals.uid}");
                        String channelId;
                        String currUser = globals.uid;
                        String receiverUid =
                            snapshot.data.documents[index]["uid"];
                        if (currUser.hashCode < receiverUid.hashCode) {
                          channelId = currUser.hashCode.toString() +
                              "-" +
                              receiverUid.hashCode.toString();
                        } else {
                          channelId = receiverUid.hashCode.toString() +
                              "-" +
                              currUser.hashCode.toString();
                        }
                        this.channelId = channelId;
                        this.receiverUID = receiverUid;
                        DocumentReference ref = Firestore.instance
                            .collection("users")
                            .document("$receiverUid");
                        ref.get().then((s) {
                          if (s.data["callevent"] == false) {
                            ref.updateData(
                                {"callevent": true, "channelId": "$channelId"});
                            join();
                          } else {
                            _scaffoldkey.currentState.showSnackBar(SnackBar(
                              duration: Duration(seconds: 1),
                              backgroundColor: Colors.black,
                              content: Text("Receiver is busy on another Call"),
                            ));
                          }
                        });
                      },
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            contentPadding: EdgeInsets.only(left: 10.0),
                            title: Text(
                                "${snapshot.data.documents[index]["name"]}"),
                            subtitle: Text(
                                "${snapshot.data.documents[index]["email"]}"),
                          ),
                          Divider()
                        ],
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
