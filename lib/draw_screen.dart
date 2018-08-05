import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:monsters/drawing_storage.dart';
import 'package:monsters/screen_painter.dart';

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
  List<Offset> _points = new List<Offset>();
  GlobalKey painterKey = new GlobalKey();

//  Drag _handleOnStart(Offset position) {
//    return new _DragHandler(
//        _handleDragUpdate, _handleDragCancel, _handleDragEnd);
//  }
  void _handleOnStart(DragStartDetails position) {}

  void _handleScaleStart(ScaleStartDetails d) {
    print("starting scale at ${d.focalPoint}"); // from $_offset $_scale");
//    _startingFocalPoint = d.focalPoint;
//    _previousOffset = _offset;
//    _previousScale = _scale;
  }
//  Drag _handleScaleStart(Offset position) {
//    return new _DragHandler(
//        _handleDragUpdate, _handleDragCancel, _handleDragEnd);
//  }

  void _handleScaleUpdate(ScaleUpdateDetails d) {
    print("update scale at ${d.toString()}"); // from $_offset $_scale");
//    double newScale = _previousScale * d.scale;
//    if (newScale > widget.maxScale) {
//      return;
//    }
//
//    // Ensure that item under the focal point stays in the same place despite zooming
//    final Offset normalizedOffset =
//        (_startingFocalPoint - _previousOffset) / _previousScale;
//    final Offset newOffset = d.focalPoint - normalizedOffset * newScale;
//
//    setState(() {
//      _scale = newScale;
//      _offset = newOffset;
//    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      final keyContext = painterKey.currentContext;
      RenderBox object = keyContext.findRenderObject();
      Offset _localPosition = object.globalToLocal(details.globalPosition);
      if (object.size.contains(_localPosition)) {
        _points = new List.from(_points)..add(_localPosition);
      }
      print(_localPosition);
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
    Size screenSize = MediaQuery.of(painterKey.currentContext).size;
    ByteData b = await p
        .toImage(screenSize.width.floor(), screenSize.height.floor())
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

  Widget _buttonClear() {
    return new FlatButton(
        color: Colors.red,
        onPressed: () => _clear(),
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

  Widget painterWidget() {
    return new RawGestureDetector(
        key: painterKey,
        behavior: HitTestBehavior.deferToChild,
        excludeFromSemantics: true,
        gestures: <Type, GestureRecognizerFactory>{
          PanGestureRecognizer:
              new GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
            () => new PanGestureRecognizer(),
            (PanGestureRecognizer instance) {
              instance..onStart = _handleOnStart;
              instance..onUpdate = _handleDragUpdate;
            },
          ),
          ScaleGestureRecognizer:
              new GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
            () => new ScaleGestureRecognizer(),
            (ScaleGestureRecognizer instance) {
              instance..onStart = _handleScaleStart;
              instance..onUpdate = _handleScaleUpdate;
            },
          ),
        },
        child: new CustomPaint(
          painter: new ScreenPainter(points: _points),
          child: new Center(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: [
        new Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[_buttonDone(), _buttonClear()]),
        ),
        new Expanded(
          child: new Column(children: [
            topHintImage == null ? getFutureWidget(topHint()) : topHintImage,
            new Expanded(child: painterWidget()),
            bottomHintImage == null
                ? getFutureWidget(bottomHint())
                : bottomHintImage,
          ]),
        )
      ],
    );
  }
}
