import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

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
  DrawScreen({
    this.drawingType
  }) : super();

  final int drawingType;

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
      ..color = color.withOpacity(0.25)
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
    return new _DragHandler(
        _handleDragUpdate, _handleDragCancel, _handleDragEnd);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _points.add(details.globalPosition);
      _begin = _begin.shift(details.delta);
    });
  }

  void _handleDragCancel() {
  }

  void _handleDragEnd(DragEndDetails details) {
  }

  void _save() async {
   // https://groups.google.com/forum/#!msg/flutter-dev/yCzw8sutC-E/zo2GZw87BgAJ
    PictureRecorder recorder = new PictureRecorder();
    Canvas c = new Canvas(recorder);
    _ScreenPainter.drawPoints(c, _points, Colors.red);
    Picture p = recorder.endRecording();
    p.toImage(_screenSize.width.floor(), _screenSize.height.floor()).toString();
  }

  Widget _gesture(BuildContext context) {
    return new Expanded(
        child: new RawGestureDetector(
            behavior: HitTestBehavior.deferToChild,
            gestures: <Type, GestureRecognizerFactory>{
              ImmediateMultiDragGestureRecognizer: new GestureRecognizerFactoryWithHandlers<
                  ImmediateMultiDragGestureRecognizer>(
                    () => new ImmediateMultiDragGestureRecognizer(),
                    (ImmediateMultiDragGestureRecognizer instance) {
                  instance
                    ..onStart = _handleOnStart;
                },
              ),
            },
//            child: new ClipRect(
                child: new CustomPaint(
                  key: _painterKey,
                  painter: new _ScreenPainter(
                      myRect: _begin,
                      points: _points
                  ),
                )
            )
        )
    );
  }

  Widget _button() {
    return new FlatButton(
        color: Colors.red,
        onPressed: () async {
          _save();
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
          _button()
        ]);
  }
}
