import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ScreenPainter extends CustomPainter {
  ScreenPainter({this.myRect, this.points}) : super();

  static void drawPoints(Canvas canvas, List<Offset> points, Color color) {
    final Paint paint = new Paint()
      ..color = color.withOpacity(.25)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    canvas.drawPoints(PointMode.points, points, paint);
  }

  final Rect myRect;
  final List<Offset> points;

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
    drawPoints(canvas, points, Colors.red);
  }

  @override
  bool shouldRepaint(ScreenPainter oldDelegate) {
//    return myRect != oldDelegate.myRect;
    return false;
  }

  @override
  bool shouldRebuildSemantics(ScreenPainter oldDelegate) {
    return false;
  }

  @override
  bool hitTest(Offset position) {
//    return (myRect.center - position).distanceSquared < _kTargetSlop;
    return true;
  }
}
