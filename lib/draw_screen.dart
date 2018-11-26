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
  List<Offset> points = new List<Offset>();
  GlobalKey painterKey = new GlobalKey();
  int width = 300;
  int height = 500;
  Size defaultSize;
  Offset startingFocalPoint;
  Offset previousOffset;
  Offset offset; // where the top left corner of the image is drawn
  double previousScale;
  double scale; // multiplier applied to scale the full image
  Size canvasSize;
  Orientation previousOrientation;
  Rect activeRect;

  void _centerAndScaleImage() {
    // add points to define a border
    defaultSize = Size(width.toDouble(), height.toDouble());

    Rect r = Offset.zero & defaultSize;
    for (double i=0.0; i<=1.0; i+=0.01) {
      points.add(Offset.lerp(r.topLeft, r.topRight, i));
      points.add(Offset.lerp(r.topRight, r.bottomRight, i));
      points.add(Offset.lerp(r.bottomRight, r.bottomLeft, i));
      points.add(Offset.lerp(r.bottomLeft, r.topLeft, i));
    }

    scale = 1.0;
    Offset delta = canvasSize - defaultSize;
    offset = delta / 2.0; // Centers the image
    // ignore points outside visible canvas
    activeRect = offset & defaultSize * scale;
  }

  void _handleOnPanStart(DragStartDetails position) {
    // TODO: process pan start?
  }

  void _handleOnPanUpdate(DragUpdateDetails details) {
    setState(() {
      final keyContext = painterKey.currentContext;
      RenderBox object = keyContext.findRenderObject();
      Offset pos = object.globalToLocal(details.globalPosition);

      if (activeRect.contains(pos)) {
        // add point in canvas coordinates
        print("inside");
        Offset newPos = (pos - offset) / scale;
        points = new List.from(points)..add(newPos);
      } else {
        print("outside");
      }
    });
  }

  void _handleScaleStart(ScaleStartDetails d) {
    startingFocalPoint = d.focalPoint;
    previousOffset = offset;
    previousScale = scale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails d) {
    double newScale = previousScale * d.scale;
    if (newScale > widget.maxScale) {
      return;
    }

    // Ensure that item under the focal point stays in the same place despite zooming
    final Offset normalizedOffset =
        (startingFocalPoint - previousOffset) / previousScale;
    final Offset newOffset = d.focalPoint - normalizedOffset * newScale;

    setState(() {
      points = points;
      scale = newScale;
      offset = newOffset;
      // Rectangle construction operator: &
      // left hand is origin, right hand is size of rectangle
      activeRect = offset & defaultSize * scale;
    });
  }

  void _clear() {
    setState(() {
      points.clear();
      _centerAndScaleImage();
    });
  }

  Future _save() async {
    // https://groups.google.com/forum/#!msg/flutter-dev/yCzw8sutC-E/zo2GZw87BgAJ
    PictureRecorder recorder = new PictureRecorder();
    Canvas c = new Canvas(recorder);
    ZoomableScreenPainter.drawPoints(c, points);
    Picture p = recorder.endRecording();
//    Size screenSize = MediaQuery.of(painterKey.currentContext).size;
    ByteData b = await p
        .toImage(width, height)
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
          child: new Center(),
          foregroundPainter: new ZoomableScreenPainter(
              points: points,
              offset: offset,
              scale: scale,
            activeRect: activeRect
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(builder: (ctx, constraints) {
      Orientation orientation = MediaQuery.of(ctx).orientation;
      if (orientation != previousOrientation) {
        previousOrientation = orientation;
        canvasSize = constraints.biggest;
        _centerAndScaleImage();
      }

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
