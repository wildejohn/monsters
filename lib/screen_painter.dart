import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ZoomableScreenPainter extends CustomPainter {
  ZoomableScreenPainter({this.points, this.offset, this.scale, this.imageSize}) : super() {
    targetSize = imageSize * scale;
    scaledOffsetRect = offset & targetSize;
    print("paint rect" + scaledOffsetRect.toString());
    newPoints = points.map((pt) { return (pt + offset) * scale; } ).toList();
  }

  List<Offset> newPoints;
  Size targetSize;
  Rect scaledOffsetRect;
  final List<Offset> points;
  final Offset offset;
  final double scale;
  final Paint brushPaint = new Paint()
    ..color = Colors.red.withOpacity(.25)
    ..strokeWidth = 4.0
    ..style = PaintingStyle.stroke;

  Size imageSize;

  static void drawPoints(Canvas canvas, List<Offset> points, Color color) {
    final Paint paint = new Paint()
      ..color = color.withOpacity(.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawPoints(ui.PointMode.points, points, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    print("canvas:" + canvas.toString());
    print("canvas size:" + size.toString());
    print("painting screen scale: ${this.scale}");
    print("painting screen offset: ${this.offset}");
    print("painting screen points: ${this.points.length}");
    paint0(canvas, size);
  }

  void paint0(Canvas canvas, Size size) {

    // Resize and paint image to canvas
    // construct rect with top-left at `offset` from origin and of size `targetSize`
    canvas.scale(scale);
    canvas.clipRect(scaledOffsetRect);

    // white background
    canvas.drawColor(Colors.white, BlendMode.srcOver);

    canvas.drawPoints(ui.PointMode.points, newPoints, brushPaint);
  }

  void paint1(Canvas canvas, Size size) {
    drawPoints(canvas, points, Colors.red);
    canvas.drawColor(Colors.blue, BlendMode.src);
  }

  void paint2(Canvas canvas, Size size) {
    // Draw image to a canvas
    ui.PictureRecorder recorder = new ui.PictureRecorder();
    Canvas c = new Canvas(recorder);
    c.drawPoints(ui.PointMode.points, points, brushPaint);
    ui.Picture p = recorder.endRecording();
    ui.Image i = p.toImage(500, 1000);

    // todo: fix rect
//    print("new rect: ${rect.toString()}");
//    paintImage(
//      canvas: canvas,
//      rect: rect,
//      image: i,
//      fit: BoxFit.fill,
//    );
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
