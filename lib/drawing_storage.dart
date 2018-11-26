import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:monsters/home_screen.dart';
import 'package:path_provider/path_provider.dart';

class DrawingStorage {
  final int drawingType;
  final String gameKey;
  DrawingStorage(this.drawingType, this.gameKey);

  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  String getDrawingType() {
    switch (drawingType) {
      case 1:
        return 'head';
      case 2:
        return 'body';
      case 3:
        return 'legs';
      default:
        return '';
    }
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return new File('$path/image.png');
  }

  Future<String> topHint() async {
    StorageReference ref = FirebaseStorage.instance.ref();
    Future<dynamic> future;
    switch (drawingType) {
      case 1:
        future = new Future<dynamic>.value('');
        break;
      case 2:
        future = ref.child("$gameKey/1south.jpg").getDownloadURL();
        break;
      case 3:
        future = ref.child("$gameKey/2south.jpg").getDownloadURL();
        break;
    }
    try {
      String url = await future;
      return url;
    } catch (e) {
      print("no top hint");
      print(e);
      return "";
    }
  }

  Future<String> bottomHint() async {
    StorageReference ref = FirebaseStorage.instance.ref();
    Future<dynamic> future;
    switch (drawingType) {
      case 1:
        future = ref.child("$gameKey/2north.jpg").getDownloadURL();
        break;
      case 2:
        future = ref.child("$gameKey/3north.jpg").getDownloadURL();
        break;
      case 3:
        future = new Future<dynamic>.value('');
        break;
    }
    try {
      String url = await future;
      return url;
    } catch (e) {
      print("no bottom hint");
      print(e);
      return "";
    }
  }

  Future<void> writeImage(ByteData data) async {
    final file = await _localFile;
    // Write the file
    await file.writeAsBytes(data.buffer.asUint8List());

    StorageReference ref =
        FirebaseStorage.instance.ref().child("$gameKey-$drawingType.jpg");
    StorageUploadTask uploadTask = ref.putFile(file);

    String url = await uploadTask.onComplete
        .then((snapshot) => snapshot.ref.getDownloadURL())
        .then((v) => v);

    return FirebaseDatabase.instance
        .reference()
        .child('game')
        .child(gameKey)
        .child(getDrawingType())
        .set(<String, String>{
      getDrawingType(): url,
      'senderPhotoUrl': googleSignIn.currentUser.photoUrl,
      'senderName': googleSignIn.currentUser.displayName
    });
  }
}
