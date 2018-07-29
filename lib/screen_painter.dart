import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ScreenPainter extends CustomPainter {
  ScreenPainter({this.points}) : super();

  static void drawPoints(Canvas canvas, List<Offset> points, Color color) {
    final Paint paint = new Paint()
      ..color = color.withOpacity(.25)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    canvas.drawPoints(PointMode.points, points, paint);
  }

  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    drawPoints(canvas, points, Colors.red);
  }

  @override
  bool shouldRepaint(ScreenPainter oldDelegate) {
    return points != oldDelegate.points;
  }

  @override
  bool shouldRebuildSemantics(ScreenPainter oldDelegate) {
    return false;
  }

  @override
  bool hitTest(Offset position) {
    print("hit test" + position.toString());
//    return (myRect.center - position).distanceSquared < _kTargetSlop;
    return true;
  }
}
