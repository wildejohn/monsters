// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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

import 'package:monsters/chat_screen.dart';
import 'package:monsters/home_screen.dart';

final googleSignIn = new GoogleSignIn();                          // new
final analytics = new FirebaseAnalytics();     // new
final auth = FirebaseAuth.instance;                              // new


final ThemeData kIOSTheme = new ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);

void main() {
  runApp(new MonstersApp());
}

class MonstersApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Monsters!",
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
      home: new HomeScreen(),
      onGenerateRoute: _getRoute,
    );
  }

  Route<Null> _getRoute(RouteSettings settings) {
    // Routes, by convention, are split on slashes, like filesystem paths.
    final List<String> path = settings.name.split('/');
    // We only support paths that start with a slash, so bail if
    // the first component is not empty:
    if (path[0] != '')
      return null;
    // If the path is "/chat:..." then show a chat page
    if (path[1].startsWith('chat:')) {
      if (path.length != 2)
        return null;
      // Extract the symbol part of "stock:..." and return a route
      // for that symbol.
      final String symbol = path[1].substring(6);
      return new MaterialPageRoute<Null>(
        settings: settings,
        builder: (BuildContext context) => new ChatScreen()
      );
    }
    // The other paths we support are in the routes table.
    return null;
  }
}

