import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

@override
class Game extends StatelessWidget {
  Game({this.snapshot, this.animation});
  final DataSnapshot snapshot;
  final Animation animation;

  void _newDrawing(BuildContext context, String path) {
    Navigator.popAndPushNamed(context, path);
  }

  Widget build(BuildContext context) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut
      ),
      axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: new GestureDetector(
          onTap: () => _newDrawing(context, "/new/${snapshot.value['ref']}"),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(right: 16.0),
                child: new CircleAvatar(
                    backgroundImage:
                    new NetworkImage(snapshot.value['urls'][0])
                ),
//              ),
//              new Expanded(
//                child: new Column(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    new Text(snapshot.value['senderName'],
//                        style: Theme.of(context).textTheme.subhead),
//                  new Container(
//                    margin: const EdgeInsets.only(top: 5.0),
//                    child: snapshot.value['imageUrl'] != null ?
//                    new Image.network(
//                      snapshot.value['imageUrl'],
//                      width: 250.0,
//                    ) : new Text(snapshot.value['text']),
//                  ),
//                  ],
//                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}

class GameListScreen extends StatefulWidget {
  final String gameKey;
  GameListScreen({
    this.gameKey
  }) : super();

  @override
  State createState() => new GameListState();
}

class GameListState extends State<GameListScreen> {
  final DatabaseReference ref = FirebaseDatabase.instance.reference()
      .child('inProgress');
  Future<List<String>> getGames() {
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
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Join a game"),
          elevation: Theme
              .of(context)
              .platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        body: new Column(children: <Widget>[
          new Flexible(
            child: new FirebaseAnimatedList(
              query: ref,
              sort: (a, b) => b.key.compareTo(a.key),
              padding: new EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_,
                  DataSnapshot snapshot,
                  Animation<double> animation,
                  int index) {
                return new Game(
                    snapshot: snapshot,
                    animation: animation
                );
              },
            ),
          ),
        ]));
  }

  Widget getButtons(BuildContext context, List<String> parts) {
    return new Container(
      height: 56.0, // in logical pixels
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      // Row is a horizontal, linear layout.
      child: new Row(
        // <Widget> is the type of items in the list.
        children: <Widget>[
          new Text("hi")
        ],
      ),
    );
  }
}
