import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

@override
class Game extends StatelessWidget {
  Game({this.snapshot, this.animation});
  final DataSnapshot snapshot;
  final Animation animation;

  void _show(BuildContext context, String path) {
    Navigator.pushNamed(context, path);
  }

  List<Widget> avatars(List<dynamic> urls) {
    return urls.map((url) {
      return avatar(url);
    }).toList();
  }

  Widget avatar(String url) {
    return new Container(
        margin: const EdgeInsets.only(right: 16.0),
        child: new CircleAvatar(backgroundImage: new NetworkImage(url)));
  }

  Future<dynamic> getUrl(dynamic gameId) async {
    String loc = "$gameId/merge.jpg";
    print(loc);
    StorageReference ref = FirebaseStorage.instance.ref().child(loc);
    return ref.getDownloadURL();
  }

  Widget build(BuildContext context) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: new GestureDetector(
            onTap: () async {
              String url = await getUrl(snapshot.key);
              print("got url: $url");
              _show(context, "/show/$url");
            },
            child: new Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: avatars(snapshot.value['urls'])),
          )),
    );
  }
}

class FinishedGameListScreen extends StatefulWidget {
  @override
  State createState() => new FinishedGameListState();
}

class FinishedGameListState extends State<FinishedGameListScreen> {
  final DatabaseReference ref =
      FirebaseDatabase.instance.reference().child('finished');

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Finished Games"),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        body: new Column(children: <Widget>[
          new Flexible(
            child: new FirebaseAnimatedList(
              query: ref,
              sort: (a, b) => b.key.compareTo(a.key),
              padding: new EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                return new Game(
                  snapshot: snapshot,
                  animation: animation,
                );
              },
            ),
          ),
        ]));
  }
}
