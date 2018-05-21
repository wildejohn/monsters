import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';


class NewGameScreen extends StatefulWidget {
  final String gameKey;
  NewGameScreen({
    this.gameKey
  }) : super();

  @override
  State createState() => new NewGameState();
}
class NewGameState extends State<NewGameScreen> {

  Future<List<String>> getParts() {
    DatabaseReference ref = FirebaseDatabase.instance.reference()
        .child('game')
        .child(widget.gameKey)
        .child('command');
    return ref.once().then((DataSnapshot snap) {
      List<String> parts = "head,body,legs".split((','));
      if (snap.value != null) {
        parts = snap.value.split(',');
      }
      return parts;
    });
  }

  @override

  Widget build(BuildContext context) {
    return new FutureBuilder<List<String>>(
      future: getParts(),

      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return new Text('Press button to start');
          case ConnectionState.waiting:
            return new Text('Awaiting result...');
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
              return getButtons(context, snapshot.data);
        }
      },
    );
  }

  Widget getButtons(BuildContext context, List<String> parts) {
      return new Container(
        height: 56.0, // in logical pixels
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        // Row is a horizontal, linear layout.
        child: new Row(
          // <Widget> is the type of items in the list.
          children: <Widget>[
            _button(context, 'images/head.jpg', 1, parts.contains('head')),
            _button(context, 'images/torso.jpg', 2, parts.contains('body')),
            _button(context, 'images/legs.png', 3, parts.contains('legs')),
          ],
        ),
      );
    }


  void _newDrawing(BuildContext context, String path) {
    Navigator.popAndPushNamed(context, path);
  }

  Widget _button(BuildContext context, String assetPath, int type, bool enabled){
    return new Expanded(child: new GestureDetector(
        onTap: () => enabled ? _newDrawing(context, '/draw/$type/${widget.gameKey}') : null,
        child: new Opacity(
          opacity: enabled ? 1.0 : 0.1,
          child: Image.asset(
            assetPath,
            width: 200.0,
          ),
        )
    ));
  }
}