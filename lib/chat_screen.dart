//
//import 'package:flutter/material.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/foundation.dart';
//import 'package:google_sign_in/google_sign_in.dart';                   // new
//import 'dart:async';                                               // new
////import 'package:firebase_analytics/firebase_analytics.dart';      // new
//import 'package:firebase_auth/firebase_auth.dart';                // new
//import 'package:firebase_database/firebase_database.dart';         //new
//import 'package:firebase_database/ui/firebase_animated_list.dart'; //new
//import 'package:firebase_storage/firebase_storage.dart';          // new
//import 'package:image_picker/image_picker.dart';     // new
//
//import 'dart:math';                                  // new
//import 'dart:io';
//
//final googleSignIn = new GoogleSignIn();                          // new
////final analytics = new FirebaseAnalytics();     // new
//final auth = FirebaseAuth.instance;                              // new
//
//@override
//class ChatMessage extends StatelessWidget {
//  ChatMessage({this.snapshot, this.animation});              // modified
//  final DataSnapshot snapshot;                               // modified
//  final Animation animation;
//
//  Widget build(BuildContext context) {
//    return new SizeTransition(
//      sizeFactor: new CurvedAnimation(
//          parent: animation, curve: Curves.easeOut),            // modified
//
//      axisAlignment: 0.0,
//      child: new Container(
//        margin: const EdgeInsets.symmetric(vertical: 10.0),
//        child: new Row(
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: <Widget>[
//            new Container(
//              margin: const EdgeInsets.only(right: 16.0),
//              child: new CircleAvatar(
//                  backgroundImage:
//                  new NetworkImage(snapshot.value['senderPhotoUrl'])
//              ),   //modified
//            ),
//            new Expanded(
//              child: new Column(
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: <Widget>[
//                  new Text(snapshot.value['senderName'],                      //modified
//                      style: Theme.of(context).textTheme.subhead),
//                  new Container(
//                    margin: const EdgeInsets.only(top: 5.0),
//                    child: snapshot.value['imageUrl'] != null ?                //modified
//                    new Image.network(                                         //new
//                      snapshot.value['imageUrl'],                             //new
//                      width: 250.0,                                           //new
//                    ) : new Text(snapshot.value['text']),                  //modified
//                  ),
//                ],
//              ),
//            ),
//          ],
//        ),
//      ),
//    );
//  }
//}
//
//class ChatScreen extends StatefulWidget {
//  @override
//  State createState() => new ChatScreenState();
//}
//
//class ChatScreenState extends State<ChatScreen> {
//  // modified
//  final TextEditingController _textController = new TextEditingController();
//  bool _isComposing = false;
//  final reference = FirebaseDatabase.instance.reference().child(
//      'messages'); // new
//
//
//  Future<Null> _ensureLoggedIn() async {
//    GoogleSignInAccount user = googleSignIn.currentUser;
//    if (user == null)
//      user = await googleSignIn.signInSilently();
//    if (user == null) {
//      await googleSignIn.signIn();
////      analytics.logLogin(); //new
//    }
//    if (await auth.currentUser() == null) { //new
//      GoogleSignInAuthentication credentials = //new
//      await googleSignIn.currentUser.authentication; //new
//      await auth.signInWithGoogle( //new
//        idToken: credentials.idToken, //new
//        accessToken: credentials.accessToken, //new
//      ); //new
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return new Scaffold(
//        appBar: new AppBar(
//          title: new Text("Monsters!"),
//          elevation: Theme
//              .of(context)
//              .platform == TargetPlatform.iOS ? 0.0 : 4.0,
//        ),
//        body: new Column(children: <Widget>[
//          new Flexible(
//            child: new FirebaseAnimatedList( //new
//              query: reference,
//              //new
//              sort: (a, b) => b.key.compareTo(a.key),
//              //new
//              padding: new EdgeInsets.all(8.0),
//              //new
//              reverse: true,
//              //new
//              itemBuilder: (_, DataSnapshot snapshot,
//                  Animation<double> animation) { //new
//                return new ChatMessage( //new
//                    snapshot: snapshot, //new
//                    animation: animation //new
//                ); //new
//              }, //new
//            ),
//          ),
//          new Divider(height: 1.0),
//          new Container(
//            decoration:
//            new BoxDecoration(color: Theme
//                .of(context)
//                .cardColor),
//            child: _buildTextComposer(),
//          ),
//        ]));
//  }
//
//  Widget _buildTextComposer() {
//    return new IconTheme(
//      data: new IconThemeData(color: Theme
//          .of(context)
//          .accentColor),
//      child: new Container(
//          margin: const EdgeInsets.symmetric(horizontal: 8.0),
//          child: new Row(children: <Widget>[
//            new Container( //new
//              margin: new EdgeInsets.symmetric(horizontal: 4.0), //new
//              child: new IconButton( //new
//                icon: new Icon(Icons.photo_camera), //new
//                onPressed: () async { // modified
//                  await _ensureLoggedIn(); // new
//                  File imageFile = await ImagePicker.pickImage(); // new
//                  int random = new Random().nextInt(100000); //new
//                  StorageReference ref = //new
//                  FirebaseStorage.instance.ref().child(
//                      "image_$random.jpg"); //new
//                  StorageUploadTask uploadTask = ref.put(imageFile); //new
//                  Uri downloadUrl = (await uploadTask.future).downloadUrl;
//                  _sendMessage(imageUrl: downloadUrl.toString()); // new
//                },
//              ), //new
//            ),
//            new Flexible(
//              child: new TextField(
//                controller: _textController,
//                onChanged: (String text) {
//                  setState(() {
//                    _isComposing = text.length > 0;
//                  });
//                },
//                onSubmitted: _handleSubmitted,
//                decoration:
//                new InputDecoration.collapsed(hintText: "Send a message"),
//              ),
//            ),
//            new Container(
//                margin: new EdgeInsets.symmetric(horizontal: 4.0),
//                child: Theme
//                    .of(context)
//                    .platform == TargetPlatform.iOS
//                    ? new CupertinoButton(
//                  child: new Text("Send"),
//                  onPressed: _isComposing
//                      ? () => _handleSubmitted(_textController.text)
//                      : null,
//                )
//                    : new IconButton(
//                  icon: new Icon(Icons.send),
//                  onPressed: _isComposing
//                      ? () => _handleSubmitted(_textController.text)
//                      : null,
//                )),
//          ]),
//          decoration: Theme
//              .of(context)
//              .platform == TargetPlatform.iOS
//              ? new BoxDecoration(
//              border:
//              new Border(top: new BorderSide(color: Colors.grey[200])))
//              : null),
//    );
//  }
//
//  Future<Null> _handleSubmitted(String text) async {
//    //modified
//    _textController.clear();
//    setState(() {
//      _isComposing = false;
//    });
//    await _ensureLoggedIn(); //new
//    _sendMessage(text: text); //new
//  }
//
//  void _sendMessage({String text, String imageUrl }) {
//    //modified
//    reference.push().set({ //new
//      'text': text, //new
//      'imageUrl': imageUrl,
//      'senderName': googleSignIn.currentUser.displayName, //new
//      'senderPhotoUrl': googleSignIn.currentUser.photoUrl, //new
//    });
////    analytics.logEvent(name: 'send_message'); //new
//  }
//}