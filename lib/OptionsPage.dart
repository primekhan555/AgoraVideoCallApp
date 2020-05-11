import 'package:agora_flutter_quickstart/Home.dart';
import 'package:agora_flutter_quickstart/src/pages/call.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'globals.dart' as globals;

class OptionsPage extends StatefulWidget {
  final String channelId;
  OptionsPage({Key key, this.channelId}) : super(key: key);

  @override
  _OptionsPageState createState() => _OptionsPageState(channelId);
}

class _OptionsPageState extends State<OptionsPage> {
  String channelId;
  _OptionsPageState(channelId);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 150.0,left: 50,),
        child: Row(
          children: <Widget>[
            FlatButton(
              color: Colors.green,
              onPressed: () {
                var route=MaterialPageRoute(builder: (context)=>CallPage(channelName: widget.channelId));
                Navigator.of(context).push(route);
              }, child: Text("Accept")),
              Padding(padding: EdgeInsets.only(left: 50),),
              FlatButton(
              color: Colors.red,
              onPressed: () {
                Firestore.instance.collection("users").document("${globals.uid}").updateData({
                  "callevent":false,
                  "channelId":"none"
                });
                var route=MaterialPageRoute(builder: (context)=>Home());
                Navigator.of(context).push(route);
              }, child: Text("Decline"))
          ],
        ),
      ),
    );
  }
}
