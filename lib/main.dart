// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:monsters/draw_screen.dart';
import 'package:monsters/finished_game_list.dart';
import 'package:monsters/game_list.dart';
import 'package:monsters/home_screen.dart';
import 'package:monsters/new_game.dart';
import 'package:monsters/show_image_screen.dart';


final googleSignIn = new GoogleSignIn();
//final analytics = new FirebaseAnalytics();
final auth = FirebaseAuth.instance;


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
      routes: <String, WidgetBuilder>{
        '/':         (BuildContext context) => new HomeScreen(),
        '/finishedGameList': (BuildContext context) => new FinishedGameListScreen(),
        '/gameList':         (BuildContext context) => new GameListScreen(),
      },
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
    if (path[1].startsWith('draw')) {
      if (path.length != 4)
        return null;
      final int symbol = int.parse(path[2]);
      final String gameKey = path[3];
      return new MaterialPageRoute<Null>(
        settings: settings,
        builder: (BuildContext context) => new DrawScreen(
            drawingType: symbol,
            gameKey: gameKey)
      );
    } else if (path[1].startsWith('new')) {
      print(path);
      final String gameKey = path[2];
      return new MaterialPageRoute<Null>(
          settings: settings,
          builder: (BuildContext context) => new NewGameScreen(
              gameKey: gameKey
          )
      );
    } else if (path[1].startsWith('show')) {
      final String downloadUrl = settings.name.substring(6);
      print(downloadUrl);
      return new MaterialPageRoute<Null>(
          settings: settings,
          builder: (BuildContext context) => new ShowImageScreen(
              url: downloadUrl
          )
      );
    }

    // The other paths we support are in the routes table.
    return null;
  }
}

