
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';                   // new
import 'dart:async';                                               // new
import 'package:firebase_analytics/firebase_analytics.dart';      // new
import 'package:firebase_auth/firebase_auth.dart';                // new
import 'package:firebase_database/firebase_database.dart';         //new
import 'package:transparent_image/transparent_image.dart';

//import 'package:firebase_database/ui/firebase_animated_list.dart'; //new
//import 'package:firebase_storage/firebase_storage.dart';          // new
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Monsters!"),
          elevation: Theme
              .of(context)
              .platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),

        body: new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _buildImage(),
              _buildButtons()
            ]
        )
    );
  }

  Widget _buildImage() {
    if (_isLoggedIn) {
      return new Expanded(
          child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: googleSignIn.currentUser.photoUrl
          ));
    } else {
      return new Expanded(
          child: new Image.asset(
        'images/monster.jpeg',
        width: 600.0,
      ));
    }
  }

  void _logInOrOut() {
    if (_isLoggedIn) {
      _tryLogOut();
    } else {
      _tryLogIn();
    }
  }

  void _newGame() {
    Navigator.pushNamed(context, "/new");
  }

  Widget _buildButtons() {
    String text = _isLoggedIn ? "Log Out" : "Login";
    if (_isLoggedIn) {
      return new Container(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton(text, _logInOrOut),
            _buildButton("Start", _newGame),
          ],
        ),
      );
    } else {
      return _buildButton(text, _logInOrOut);
    }
  }

  Widget _buildButton(String text, VoidCallback onTap) {
    return new IconTheme(
      data: new IconThemeData(color: Theme
          .of(context)
          .accentColor),
      child: new Center(
        child: new RaisedButton(
          onPressed: () async { onTap(); },
          child: new Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.dvr,
                size: 40.0,
              ),
              new Container(
                width: 20.0,
              ),
              new Container(
                  padding: EdgeInsets.all(10.0),
                  child: new Text(
                      text,
                      style: new TextStyle(fontSize: 40.0)
                  )
              ),
            ]
          )
        ),
      ),
    );
  }

}

