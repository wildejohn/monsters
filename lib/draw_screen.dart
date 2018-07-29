import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:monsters/drawing_storage.dart';
import 'package:monsters/screen_painter.dart';

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

class DrawState extends State<DrawScreen> {
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

  void _handleDragCancel() {}

  void _handleDragEnd(DragEndDetails details) {}

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
    ScreenPainter.drawPoints(c, _points, Colors.red);
    Picture p = recorder.endRecording();
    ByteData b = await p
        .toImage(_screenSize.width.floor(), _screenSize.height.floor())
        .toByteData(format: ImageByteFormat.png);
    return widget.storage.writeImage(b);
  }

  Future<dynamic> getUrl(dynamic gameId) async {
    String loc = "$gameId/jpg";
    print(loc);
    StorageReference ref = FirebaseStorage.instance.ref().child(loc);
    return ref.getDownloadURL();
  }

  Widget topHintImage;
  Widget bottomHintImage;

  Future<Widget> topHint() async {
    if (topHintImage == null) {
      String url = await widget.storage.topHint();
      topHintImage = getHint(url);
    }
    return topHintImage;
  }

  Future<Widget> bottomHint() async {
    if (bottomHintImage == null) {
      String url = await widget.storage.bottomHint();
      bottomHintImage = getHint(url);
    }
    return bottomHintImage;
  }

  Widget getHint(String url) {
    if (url.isNotEmpty) {
      return Image.network(url);
    } else {
      return new Container(width: 0.0, height: 0.0);
    }
  }

  Widget painterWidget() {
    return new Expanded(
        child: new RawGestureDetector(
            behavior: HitTestBehavior.deferToChild,
            excludeFromSemantics: true,
            gestures: <Type, GestureRecognizerFactory>{
              ImmediateMultiDragGestureRecognizer:
                  new GestureRecognizerFactoryWithHandlers<
                      ImmediateMultiDragGestureRecognizer>(
                () => new ImmediateMultiDragGestureRecognizer(),
                (ImmediateMultiDragGestureRecognizer instance) {
                  instance..onStart = _handleOnStart;
                },
              ),
            },
            child: new CustomPaint(
                painter:
                    new ScreenPainter(myRect: startRect(), points: _points),
                child: new Center())));
  }

  Widget _buttonClear() {
    return new FlatButton(
        color: Colors.red,
        onPressed: () async {
          _clear();
        },
        child: new Text('Clear',
            style:
                Theme.of(context).textTheme.caption.copyWith(fontSize: 16.0)));
  }

  Widget _buttonDone() {
    return new FlatButton(
        color: Colors.red,
        onPressed: () async {
          _save();
          Navigator.pop(context);
        },
        child: new Text('Done',
            style:
                Theme.of(context).textTheme.caption.copyWith(fontSize: 16.0)));
  }

  Rect startRect() {
    final Size screenSize = MediaQuery.of(context).size;
    if (_screenSize == null || _screenSize != screenSize) {
      _screenSize = screenSize;
      _begin = new Rect.fromLTWH(
          screenSize.width * 0.5,
          screenSize.height * 0.2,
          screenSize.width * 0.4,
          screenSize.height * 0.2);
    }
    return _begin;
  }

  Widget getFutureWidget(Future<Widget> calc) {
    return new FutureBuilder<Widget>(
        future: calc,
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return new Text('Press button to start');
            case ConnectionState.waiting:
              return new Text('loading...');
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else
                return snapshot.data;
          }
        });
  }

  Widget painterWidgets(BuildContext context) {
    List<Widget> widgets = [
      topHintImage == null ? getFutureWidget(topHint()) : topHintImage,
      painterWidget(),
      bottomHintImage == null ? getFutureWidget(bottomHint()) : bottomHintImage,
    ];
    return new Expanded(child: new Column(children: widgets));
  }

  @override
  Widget build(BuildContext context) {
    return new Row(children: [
      painterWidgets(context),
      new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[_buttonDone(), _buttonClear()])
    ]);
  }
}
