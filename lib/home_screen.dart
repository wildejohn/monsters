
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
  // modified
  final TextEditingController _textController = new TextEditingController();
  final reference = FirebaseDatabase.instance.reference().child('login');

  // Add the _ensureLoggedIn() method definition in ChatScreenState.

  Future<Null> _ensureLoggedIn() async {
    GoogleSignInAccount user = googleSignIn.currentUser;
    if (user == null)
      user = await googleSignIn.signInSilently();
    if (user == null) {
      await googleSignIn.signIn();
      analytics.logLogin(); //new
    }
    if (await auth.currentUser() == null) { //new
      GoogleSignInAuthentication credentials = //new
      await googleSignIn.currentUser.authentication; //new
      await auth.signInWithGoogle( //new
        idToken: credentials.idToken, //new
        accessToken: credentials.accessToken, //new
      ); //new
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
        );
  }
}