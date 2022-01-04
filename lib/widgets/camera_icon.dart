
import 'package:flutter/material.dart';

// EXAMPLE:// Add this CustomPaint widget to the Widget Tree
// CustomPaint(
//     size: Size(WIDTH, (WIDTH*1).toDouble()), //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
//     painter: RPSCustomPainter(),
// )

//Copy this CustomPainter code to the Bottom of the File
class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.9583333, size.height * 0.7916667);
    path_0.cubicTo(
        size.width * 0.9583333,
        size.height * 0.8137667,
        size.width * 0.9495542,
        size.height * 0.8349625,
        size.width * 0.9339250,
        size.height * 0.8505917);
    path_0.cubicTo(
        size.width * 0.9182958,
        size.height * 0.8662208,
        size.width * 0.8971000,
        size.height * 0.8750000,
        size.width * 0.8750000,
        size.height * 0.8750000);
    path_0.lineTo(size.width * 0.1250000, size.height * 0.8750000);
    path_0.cubicTo(
        size.width * 0.1028987,
        size.height * 0.8750000,
        size.width * 0.08170250,
        size.height * 0.8662208,
        size.width * 0.06607458,
        size.height * 0.8505917);
    path_0.cubicTo(
        size.width * 0.05044625,
        size.height * 0.8349625,
        size.width * 0.04166667,
        size.height * 0.8137667,
        size.width * 0.04166667,
        size.height * 0.7916667);
    path_0.lineTo(size.width * 0.04166667, size.height * 0.3333333);
    path_0.cubicTo(
        size.width * 0.04166667,
        size.height * 0.3112321,
        size.width * 0.05044625,
        size.height * 0.2900358,
        size.width * 0.06607458,
        size.height * 0.2744079);
    path_0.cubicTo(
        size.width * 0.08170250,
        size.height * 0.2587796,
        size.width * 0.1028987,
        size.height * 0.2500000,
        size.width * 0.1250000,
        size.height * 0.2500000);
    path_0.lineTo(size.width * 0.2916667, size.height * 0.2500000);
    path_0.lineTo(size.width * 0.3750000, size.height * 0.1250000);
    path_0.lineTo(size.width * 0.6250000, size.height * 0.1250000);
    path_0.lineTo(size.width * 0.7083333, size.height * 0.2500000);
    path_0.lineTo(size.width * 0.8750000, size.height * 0.2500000);
    path_0.cubicTo(
        size.width * 0.8971000,
        size.height * 0.2500000,
        size.width * 0.9182958,
        size.height * 0.2587796,
        size.width * 0.9339250,
        size.height * 0.2744079);
    path_0.cubicTo(
        size.width * 0.9495542,
        size.height * 0.2900358,
        size.width * 0.9583333,
        size.height * 0.3112321,
        size.width * 0.9583333,
        size.height * 0.3333333);
    path_0.lineTo(size.width * 0.9583333, size.height * 0.7916667);
    path_0.close();

    Paint paint_0_stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    paint_0_stroke.color = Colors.black.withOpacity(1.0);
    paint_0_stroke.strokeCap = StrokeCap.round;
    paint_0_stroke.strokeJoin = StrokeJoin.round;
    canvas.drawPath(path_0, paint_0_stroke);

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path_0, paint_0_fill);

    Path path_1 = Path();
    path_1.moveTo(size.width * 0.5000000, size.height * 0.7083333);
    path_1.cubicTo(
        size.width * 0.5920458,
        size.height * 0.7083333,
        size.width * 0.6666667,
        size.height * 0.6337125,
        size.width * 0.6666667,
        size.height * 0.5416667);
    path_1.cubicTo(
        size.width * 0.6666667,
        size.height * 0.4496208,
        size.width * 0.5920458,
        size.height * 0.3750000,
        size.width * 0.5000000,
        size.height * 0.3750000);
    path_1.cubicTo(
        size.width * 0.4079525,
        size.height * 0.3750000,
        size.width * 0.3333333,
        size.height * 0.4496208,
        size.width * 0.3333333,
        size.height * 0.5416667);
    path_1.cubicTo(
        size.width * 0.3333333,
        size.height * 0.6337125,
        size.width * 0.4079525,
        size.height * 0.7083333,
        size.width * 0.5000000,
        size.height * 0.7083333);
    path_1.close();

    Paint paint_1_stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    paint_1_stroke.color = Colors.black.withOpacity(1.0);
    paint_1_stroke.strokeCap = StrokeCap.round;
    paint_1_stroke.strokeJoin = StrokeJoin.round;
    canvas.drawPath(path_1, paint_1_stroke);

    Paint paint_1_fill = Paint()..style = PaintingStyle.fill;
    paint_1_fill.color = Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path_1, paint_1_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
