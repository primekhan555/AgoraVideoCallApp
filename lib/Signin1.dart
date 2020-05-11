import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;
import 'Home.dart';

class Signin1 extends StatefulWidget {
  @override
  _Signin1State createState() => _Signin1State();
}

class _Signin1State extends State<Signin1> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();
  var _emailController2 = TextEditingController();
  var _passwordController2 = TextEditingController();
  var _nameController = TextEditingController();
  init() async {
    SharedPreferences prefs = await _prefs;
    String uid = prefs.getString("key");
    if (uid != null) {
      setState(() {
        globals.uid = uid;
      });
      var route = MaterialPageRoute(builder: (context) => Home());
      await Navigator.of(context).push(route);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("dfs"),
      ),
      body: ListView(
        children: <Widget>[
          // child:
          Column(
            children: <Widget>[
              Text("Sign Up Section"),
              TextField(
                decoration: InputDecoration(hintText: "Name"),
                controller: _nameController,
              ),
              TextField(
                decoration: InputDecoration(hintText: "Email"),
                controller: _emailController,
              ),
              TextField(
                decoration: InputDecoration(hintText: "Password"),
                controller: _passwordController,
              ),
              RaisedButton(
                  child: Text("Create Account"),
                  onPressed: () async {
                    SharedPreferences prefs = await _prefs;
                    await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text)
                        .then((user) {
                      prefs.setString("key", "${user.user.uid}");
                      setState(() {
                        globals.uid = user.user.uid;
                      });
                    });
                    await FirebaseAuth.instance.currentUser().then((user) {
                      String uid = user.uid;
                      Firestore.instance
                          .collection("users")
                          .document("$uid")
                          .setData({
                        "name": "${_nameController.text}",
                        "email": "${_emailController.text}",
                        "pass": "${_passwordController.text}",
                        "uid": "$uid",
                        "callevent": false,
                        "channelId": "none"
                      });
                      var route =
                          MaterialPageRoute(builder: (context) => Home());
                      Navigator.of(context).push(route);
                    });
                  }),
              Text("Sign in Section"),
              TextField(
                decoration: InputDecoration(hintText: "Email"),
                controller: _emailController2,
              ),
              TextField(
                decoration: InputDecoration(hintText: "password"),
                controller: _passwordController2,
              ),
              RaisedButton(
                  child: Text("Sign In"),
                  onPressed: () async {
                    SharedPreferences prefs = await _prefs;
                    FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: _emailController2.text,
                            password: _passwordController2.text)
                        .then((user) {
                      prefs.setString("key", "${user.user.uid}");
                      setState(() {
                        globals.uid = user.user.uid;
                      });
                    }).then((uid) {
                      var route =
                          MaterialPageRoute(builder: (context) => Home());
                      Navigator.of(context).push(route);
                    });
                  }),
              RaisedButton(
                  child: Text("Logout"),
                  onPressed: () {
                    FirebaseAuth.instance.signOut().whenComplete(() {
                      print("Signout");
                    });
                  })
            ],
          ),
        ],
      ),
    );
  }
}
