import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:monsters/drawing_storage.dart';
import 'package:monsters/screen_painter.dart';

class DrawScreen extends StatefulWidget {
  final int drawingType;
  final String gameKey;
  final DrawingStorage storage;
  final double maxScale;

  DrawScreen(
      {

      /// Maximum ratio to blow up image pixels. A value of 2.0 means that the
      /// a single device pixel will be rendered as up to 4 logical pixels.
      this.maxScale = 4.0,
      drawingType,
      gameKey})
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
  Size _defaultImageSize = new Size(200.0, 200.0);
  Size _imageSize = new Size(200.0, 200.0);
  Offset _startingFocalPoint;
  Offset _previousOffset;
  Offset _offset; // where the top left corner of the image is drawn
  double _previousScale;
  double _scale; // multiplier applied to scale the full image
  Size _canvasSize;
  Orientation _previousOrientation;
  Size _scaledImage;
  Rect _activeRect;

  void _centerAndScaleImage() {
    _imageSize = _defaultImageSize;
    _scale = 1.0;
    Offset delta = _canvasSize - _imageSize;
    _offset = delta / 2.0; // Centers the image
    // ignore points outside visible canvas
    _scaledImage = _imageSize * _scale;
    _activeRect = _offset & _scaledImage;
  }

  void _handleOnPanStart(DragStartDetails position) {
    // TODO: process pan start?
  }

  void _handleOnPanUpdate(DragUpdateDetails details) {
    setState(() {
      final keyContext = painterKey.currentContext;
      RenderBox object = keyContext.findRenderObject();
      print("ds object size" + object.size.toString());
      print("ds global: " + details.globalPosition.toString());

      Offset pos = object.globalToLocal(details.globalPosition);

      if (_activeRect.contains(pos)) {
        Offset newPos = pos / _scale - _offset / _scale;
        _points = new List.from(_points)..add(newPos);
      } else {
        print("ds touch point outside object");
      }
    });
  }

  void _handleScaleStart(ScaleStartDetails d) {
    print("starting scale at ${d.focalPoint}"); // from $_offset $_scale");
    _startingFocalPoint = d.focalPoint;
    _previousOffset = _offset;
    _previousScale = _scale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails d) {
    print("scale details + $d"); // from $_offset $_scale");
    print("previous scale + $_previousScale"); // from $_offset $_scale");
    double newScale = _previousScale * d.scale;
    if (newScale > widget.maxScale) {
      return;
    }

    print("update scale at ${d.toString()}"); // from $_offset $_scale");

    // Ensure that item under the focal point stays in the same place despite zooming
    final Offset normalizedOffset =
        (_startingFocalPoint - _previousOffset) / _previousScale;
    final Offset newOffset = d.focalPoint - normalizedOffset * newScale;

    setState(() {
      print("new scale: $newScale");
      _points = _points;
      _scale = newScale;
      _offset = newOffset;
      // ignore points outside visible canvas
      _scaledImage = _imageSize * _scale;
      _activeRect = _offset & _scaledImage;
    });
  }

  void _clear() {
    setState(() {
      _points.clear();
      _centerAndScaleImage();
    });
  }

  Future _save() async {
    print("Save tapped");
    // https://groups.google.com/forum/#!msg/flutter-dev/yCzw8sutC-E/zo2GZw87BgAJ
    PictureRecorder recorder = new PictureRecorder();
    Canvas c = new Canvas(recorder);
    ZoomableScreenPainter.drawPoints(c, _points, Colors.red);
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
              instance..onStart = _handleOnPanStart;
              instance..onUpdate = _handleOnPanUpdate;
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
//          child: new Text('Hello this is text'),
//          size: new Size(200, 200),
          child: new Center(
              child: new Container(
            color: Colors.white,
            width: 50.0,
            height: 100.0,
          )),
          foregroundPainter: new ZoomableScreenPainter(
              points: _points,
              offset: _offset,
              scale: _scale,
              imageSize: _imageSize
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(builder: (ctx, constraints) {
      Orientation orientation = MediaQuery.of(ctx).orientation;
      if (orientation != _previousOrientation) {
        _previousOrientation = orientation;
        _canvasSize = constraints.biggest;
        print("ds canvas size: " + _canvasSize.toString());
        _centerAndScaleImage();
      }

//      return new Center(
//        child: painterWidget(),
//      );

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
    });
  }
}
