
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';                   // new
import 'dart:async';                                               // new
import 'package:firebase_analytics/firebase_analytics.dart';      // new
import 'package:firebase_auth/firebase_auth.dart';                // new
import 'package:firebase_database/firebase_database.dart';         //new
import 'package:firebase_database/ui/firebase_animated_list.dart'; //new
import 'package:firebase_storage/firebase_storage.dart';          // new
import 'package:image_picker/image_picker.dart';     // new

import 'dart:math';                                  // new
import 'dart:io';

final googleSignIn = new GoogleSignIn();
final analytics = new FirebaseAnalytics();
final auth = FirebaseAuth.instance;

class HomeScreen extends StatefulWidget {
  @override
  State createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final reference = FirebaseDatabase.instance.reference().child('login');
  bool _isLoggedIn = false;
  Future<Null> _tryLogIn() async {
    GoogleSignInAccount user = googleSignIn.currentUser;
    if (user == null)
      user = await googleSignIn.signInSilently();
    if (user == null) {
      await googleSignIn.signIn();
      analytics.logLogin();
    }
    _tryAuthenticate();
    setState(() {
      _isLoggedIn = googleSignIn.currentUser != null;
    });
  }

  void _tryLogOut() async {
    await googleSignIn.signOut();
    setState(() {
      _isLoggedIn = googleSignIn.currentUser != null;
    });
  }

  Future<Null> _tryAuthenticate() async {
    if (await auth.currentUser() == null) {
      GoogleSignInAuthentication credentials = await googleSignIn.currentUser.authentication;
      await auth.signInWithGoogle(
        idToken: credentials.idToken,
        accessToken: credentials.accessToken,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Monsters!"),
          elevation: Theme
              .of(context)
              .platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),

        body: new Column(children: <Widget>[
          new Container(
            decoration:
            new BoxDecoration(color: Theme
                .of(context)
                .cardColor),
            child: _buildButton(),
          ),
        ]));
  }

  Widget _buildButton() {
    String text = _isLoggedIn ? "Log Out" : "Login";
    return new IconTheme(
      data: new IconThemeData(color: Theme
          .of(context)
          .accentColor),
      child: new Container(
        margin: new EdgeInsets.symmetric(horizontal: 4.0),
        child: new RaisedButton(
          onPressed: () async {
            if (_isLoggedIn) {
              _tryLogOut();
            } else {
              _tryLogIn();
            }
          },
          child: new Row(
            children: <Widget>[
              const Icon(
                Icons.dvr,
                size: 18.0,
              ),
              new Container(
                width: 8.0,
              ),
              new Text(text),
            ],
          ),
        ),
      ),
    );
  }

}