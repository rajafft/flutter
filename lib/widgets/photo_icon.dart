
import 'package:flutter/material.dart';

// EXAMPLE: Add this CustomPaint widget to the Widget Tree
// CustomPaint(
//     size: Size(WIDTH, (WIDTH*1).toDouble()), //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
//     painter: RPSCustomPainter(),
// )

//Copy this CustomPainter code to the Bottom of the File
class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.7916667, size.height * 0.1250000);
    path_0.lineTo(size.width * 0.2083333, size.height * 0.1250000);
    path_0.cubicTo(
        size.width * 0.1623096,
        size.height * 0.1250000,
        size.width * 0.1250000,
        size.height * 0.1623096,
        size.width * 0.1250000,
        size.height * 0.2083333);
    path_0.lineTo(size.width * 0.1250000, size.height * 0.7916667);
    path_0.cubicTo(
        size.width * 0.1250000,
        size.height * 0.8376917,
        size.width * 0.1623096,
        size.height * 0.8750000,
        size.width * 0.2083333,
        size.height * 0.8750000);
    path_0.lineTo(size.width * 0.7916667, size.height * 0.8750000);
    path_0.cubicTo(
        size.width * 0.8376917,
        size.height * 0.8750000,
        size.width * 0.8750000,
        size.height * 0.8376917,
        size.width * 0.8750000,
        size.height * 0.7916667);
    path_0.lineTo(size.width * 0.8750000, size.height * 0.2083333);
    path_0.cubicTo(
        size.width * 0.8750000,
        size.height * 0.1623096,
        size.width * 0.8376917,
        size.height * 0.1250000,
        size.width * 0.7916667,
        size.height * 0.1250000);
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
    path_1.moveTo(size.width * 0.3541667, size.height * 0.4166667);
    path_1.cubicTo(
        size.width * 0.3886846,
        size.height * 0.4166667,
        size.width * 0.4166667,
        size.height * 0.3886846,
        size.width * 0.4166667,
        size.height * 0.3541667);
    path_1.cubicTo(
        size.width * 0.4166667,
        size.height * 0.3196487,
        size.width * 0.3886846,
        size.height * 0.2916667,
        size.width * 0.3541667,
        size.height * 0.2916667);
    path_1.cubicTo(
        size.width * 0.3196487,
        size.height * 0.2916667,
        size.width * 0.2916667,
        size.height * 0.3196487,
        size.width * 0.2916667,
        size.height * 0.3541667);
    path_1.cubicTo(
        size.width * 0.2916667,
        size.height * 0.3886846,
        size.width * 0.3196487,
        size.height * 0.4166667,
        size.width * 0.3541667,
        size.height * 0.4166667);
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

    Path path_2 = Path();
    path_2.moveTo(size.width * 0.8750000, size.height * 0.6250000);
    path_2.lineTo(size.width * 0.6666667, size.height * 0.4166667);
    path_2.lineTo(size.width * 0.2083333, size.height * 0.8750000);

    Paint paint_2_stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    paint_2_stroke.color = Colors.black.withOpacity(1.0);
    paint_2_stroke.strokeCap = StrokeCap.round;
    paint_2_stroke.strokeJoin = StrokeJoin.round;
    canvas.drawPath(path_2, paint_2_stroke);

    Paint paint_2_fill = Paint()..style = PaintingStyle.fill;
    paint_2_fill.color = Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path_2, paint_2_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
