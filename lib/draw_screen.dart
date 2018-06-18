import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:monsters/home_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';          // new

// How close a drag's start position must be to the target point. This is
// a distance squared.
const double _kTargetSlop = 2500.0;

class _DragHandler extends Drag {
  _DragHandler(this.onUpdate, this.onCancel, this.onEnd);

  final GestureDragUpdateCallback onUpdate;
  final GestureDragCancelCallback onCancel;
  final GestureDragEndCallback onEnd;

  @override
  void update(DragUpdateDetails details) {
    onUpdate(details);
  }

  @override
  void cancel() {
    onCancel();
  }

  @override
  void end(DragEndDetails details) {
    onEnd(details);
  }
}

class DrawingStorage {
  final int drawingType;
  final String gameKey;
  DrawingStorage(this.drawingType, this.gameKey);

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();

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

  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If we encounter an error, return 0
      return 0;
    }
  }

  Future<void> writeImage(ByteData data) async {
    final file = await _localFile;
    // Write the file
    file.writeAsBytes(data.buffer.asUint8List());

    StorageReference ref = FirebaseStorage.instance.ref()
        .child("$gameKey-$drawingType.jpg");
    StorageUploadTask uploadTask = ref.put(file);
    Uri downloadUrl = (await uploadTask.future).downloadUrl;

    return FirebaseDatabase.instance.reference()
        .child('game')
        .child(gameKey)
        .child(getDrawingType())
        .set(<String, String>{
      getDrawingType() : downloadUrl.toString(),
      'senderPhotoUrl' : googleSignIn.currentUser.photoUrl,
      'senderName' : googleSignIn.currentUser.displayName
    });
  }
}

class DrawScreen extends StatefulWidget {
  final int drawingType;
  final String gameKey;
  final DrawingStorage storage;

  DrawScreen({drawingType, gameKey})
      : drawingType = drawingType,
        gameKey = gameKey,
        storage = new DrawingStorage(drawingType, gameKey),
        super();

  @override
  State createState() {
    return new DrawState();
  }
}

class _ScreenPainter extends CustomPainter {
  _ScreenPainter({
    this.myRect,
    this.points
  }) : super();

  final Rect myRect;
  final List<Offset> points;

  void drawRect(Canvas canvas, Rect rect, Color color) {
    final Paint paint = new Paint()
      ..color = color.withOpacity(0.25)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, paint);
  }

  static void drawPoints(Canvas canvas, List<Offset> points, Color color) {
    final Paint paint = new Paint()
      ..color = color.withOpacity(.25)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    canvas.drawPoints(PointMode.points, points, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawRect(canvas, myRect, Colors.green);
    drawPoints(canvas, points, Colors.red);
  }

  @override
  bool shouldRepaint(_ScreenPainter oldDelegate) {
    return myRect != oldDelegate.myRect;
  }

  @override
  bool hitTest(Offset position) {
//    return (myRect.center - position).distanceSquared < _kTargetSlop;
    return true;
  }
}

class DrawState extends State<DrawScreen> {
  final GlobalKey _painterKey = new GlobalKey();
  Rect _begin;
  Size _screenSize;
  List<Offset> _points = new List<Offset>();

  Drag _handleOnStart(Offset position) {
    print(position);
    return new _DragHandler(
        _handleDragUpdate, _handleDragCancel, _handleDragEnd);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      print(details);
      _points.add(details.globalPosition);
      _begin = _begin.shift(details.delta);
    });
  }

  void _handleDragCancel() {
  }

  void _handleDragEnd(DragEndDetails details) {
  }

  void _clear() {
    setState(() {
      _points.clear();
    });
  }

  Future _save() async {
    print("Save tapped");
   // https://groups.google.com/forum/#!msg/flutter-dev/yCzw8sutC-E/zo2GZw87BgAJ
    PictureRecorder recorder = new PictureRecorder();
    Canvas c = new Canvas(recorder);
    _ScreenPainter.drawPoints(c, _points, Colors.red);
    Picture p = recorder.endRecording();
    ByteData b = await p
        .toImage(_screenSize.width.floor(), _screenSize.height.floor())
        .toByteData(format: ImageByteFormat.png);
    return widget.storage.writeImage(b);
  }

  Widget _gesture(BuildContext context) {
    return new Expanded(
        child: new RawGestureDetector(
            behavior: HitTestBehavior.deferToChild,
            gestures: <Type, GestureRecognizerFactory>{
              ImmediateMultiDragGestureRecognizer: new GestureRecognizerFactoryWithHandlers
              <ImmediateMultiDragGestureRecognizer>(
                    () => new ImmediateMultiDragGestureRecognizer(),
                    (ImmediateMultiDragGestureRecognizer instance) {
                  instance
                    ..onStart = _handleOnStart;
                },
              ),
            },
            child: new CustomPaint(
                key: _painterKey,
                painter: new _ScreenPainter(
                    myRect: _begin,
                    points: _points
                ),
                child: new Center()
            )
        )
    );
  }

  Widget _buttonClear() {
    return new FlatButton(
        color: Colors.red,
        onPressed: () async {
          _clear();
        },
        child: new Text('Clear',
            style: Theme
                .of(context)
                .textTheme
                .caption
                .copyWith(fontSize: 16.0)
        )
    );
  }
  Widget _buttonDone() {
    return new FlatButton(
        color: Colors.red,
        onPressed: () async {
          _save();
          Navigator.pop(context);
        },
        child: new Text('Done',
            style: Theme
                .of(context)
                .textTheme
                .caption
                .copyWith(fontSize: 16.0)
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery
        .of(context)
        .size;
    if (_screenSize == null || _screenSize != screenSize) {
      _screenSize = screenSize;
      _begin = new Rect.fromLTWH(
          screenSize.width * 0.5, screenSize.height * 0.2,
          screenSize.width * 0.4, screenSize.height * 0.2
      );
    }

    return new Row(
        children: <Widget>[
          _gesture(context),
          new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buttonDone(),
                _buttonClear()
              ])
        ]);
  }
}
