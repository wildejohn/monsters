import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
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
    this.myRect
  }) : super();

  final Rect myRect;

  void drawRect(Canvas canvas, Rect rect, Color color) {
    final Paint paint = new Paint()
      ..color = color.withOpacity(0.25)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawRect(canvas, myRect, Colors.green);
  }

  @override
  bool shouldRepaint(_ScreenPainter oldDelegate) {
    return myRect != oldDelegate.myRect;
  }

  @override
  bool hitTest(Offset position) {
    return (myRect.center - position).distanceSquared < _kTargetSlop;
  }
}

class DrawState extends State<DrawScreen> {
  final GlobalKey _painterKey = new GlobalKey();
  Rect _begin;
  Size _screenSize;

  Drag _handleOnStart(Offset position) {
    return new _DragHandler(_handleDragUpdate, _handleDragCancel, _handleDragEnd);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _begin = _begin.shift(details.delta);
    });
  }

  void _handleDragCancel() {
  }

  void _handleDragEnd(DragEndDetails details) {
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    if (_screenSize == null || _screenSize != screenSize) {
      _screenSize = screenSize;
      _begin = new Rect.fromLTWH(
          screenSize.width * 0.5, screenSize.height * 0.2,
          screenSize.width * 0.4, screenSize.height * 0.2
      );
    }

    return new RawGestureDetector(
        behavior: HitTestBehavior.deferToChild,
        gestures: <Type, GestureRecognizerFactory>{
          ImmediateMultiDragGestureRecognizer: new GestureRecognizerFactoryWithHandlers<ImmediateMultiDragGestureRecognizer>(
                () => new ImmediateMultiDragGestureRecognizer(),
                (ImmediateMultiDragGestureRecognizer instance) {
              instance
                ..onStart = _handleOnStart;
            },
          ),
        },
        child: new ClipRect(
            child: new CustomPaint(
                key: _painterKey,
                foregroundPainter: new _ScreenPainter(myRect: _begin)
            )
        )
    );
  }
}

