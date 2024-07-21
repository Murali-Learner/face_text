import 'dart:math';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:face_filters/coordinate_translator.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(
    this.faces,
    this.imageSize,
    this.rotation,
    this.text,
    this.cameraLensDirection,
  );

  final List<Face> faces;
  final Size imageSize;
  final String text;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.red;
    final Paint paint2 = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 5.0
      ..color = Colors.green;

    for (final Face face in faces) {
      final left = translateX(
        face.boundingBox.left,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final top = translateY(
        face.boundingBox.top,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final right = translateX(
        face.boundingBox.right,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final bottom = translateY(
        face.boundingBox.bottom,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final double centerX = (left + right) / 2;
      final double centerY = (top + bottom) / 2;

      // Calculate the face's angle (yaw)
      final double angle = face.headEulerAngleY! * pi / 180;

      // Save the canvas state before rotating
      canvas.save();

      // Translate to the center of the rectangle
      canvas.translate(centerX, centerY);

      // Rotate the canvas based on the face's angle
      canvas.rotate(-angle);

      // Translate back
      canvas.translate(-centerX, -centerY);

      const double rectHeight = 50;
      final double rectTop = top - rectHeight;
      final double rectBottom = top;

      canvas.drawRect(
        Rect.fromLTRB(left, rectTop, right, rectBottom),
        paint1,
      );

      const textStyle = TextStyle(
        color: Colors.red,
        fontSize: 20,
      );
      final textSpan = TextSpan(
        text: text,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: (right - left).abs(),
      );
      final xCenter = (left + right - textPainter.width) / 2;
      final yCenter = (rectTop + rectBottom - textPainter.height) / 2;
      final offset = Offset(xCenter, yCenter);
      textPainter.paint(canvas, offset);

      // Restore the canvas state after rotating
      canvas.restore();

      // Draw the top center point
      final paint4 = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
          Offset(centerX, top), 5.0, paint4); // Adjust the radius as needed

      canvas.drawPoints(
        PointMode.points,
        [
          Offset(left, top),
          Offset(right, top),
        ],
        paint2,
      );
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.faces != faces;
  }
}
