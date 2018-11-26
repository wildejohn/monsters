import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ZoomableScreenPainter extends CustomPainter {
  ZoomableScreenPainter({this.points, this.offset, this.scale, this.activeRect}) : super();

  Rect activeRect;
  final List<Offset> points;
  final Offset offset;
  final double scale;
  static final Paint brushPaint = new Paint()
    ..color = Colors.red.withOpacity(.25)
    ..strokeWidth = 4.0
    ..style = PaintingStyle.stroke;

  static void drawPoints(Canvas canvas, List<Offset> points) {
    canvas.drawPoints(ui.PointMode.points, points, brushPaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    paint00(canvas, size);
  }

  void paint00(Canvas canvas, Size size) {
    canvas.clipRect(activeRect);
    canvas.drawColor(Colors.white, BlendMode.srcOver);
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);
    canvas.drawPoints(ui.PointMode.points, points, brushPaint);
  }

  @override
  bool shouldRepaint(ZoomableScreenPainter old) {
    return points != old.points || old.offset != offset || old.scale != scale;
  }

  @override
  bool shouldRebuildSemantics(ZoomableScreenPainter oldDelegate) {
    return false;
  }

  @override
  bool hitTest(Offset position) {
    print("hit test" + position.toString());
    return true;
  }
}
