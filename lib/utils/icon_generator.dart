import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class IconGenerator {
  static Future<void> generateAppIcon() async {
    // Create a custom painter for the app icon
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = 1024.0;

    // Background with rounded corners
    final bgPaint = Paint()
      ..color = const Color(0xFF87CEEB) // Sky blue
      ..style = PaintingStyle.fill;

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size, size),
      Radius.circular(size * 0.22), // iOS-style rounded corners
    );
    canvas.drawRRect(bgRect, bgPaint);

    // Inner circle background
    final circlePaint = Paint()
      ..color = const Color(0xFF4682B4).withOpacity(0.3) // Steel blue with opacity
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size * 0.5, size * 0.5),
      size * 0.35,
      circlePaint,
    );

    // Shadow for depth
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(
      Offset(size * 0.5, size * 0.52),
      size * 0.33,
      shadowPaint,
    );

    // Create text painter for "DT"
    final textStyle = TextStyle(
      fontSize: size * 0.35,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontFamily: 'Arial', // Using system font for reliability
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.3),
          offset: Offset(size * 0.015, size * 0.015),
          blurRadius: size * 0.02,
        ),
      ],
    );

    final textSpan = TextSpan(text: 'DT', style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Center the text
    final textOffset = Offset(
      (size - textPainter.width) * 0.5,
      (size - textPainter.height) * 0.5,
    );
    textPainter.paint(canvas, textOffset);

    // Small drink glass icon in bottom-right
    final glassSize = size * 0.2;
    final glassCenter = Offset(size * 0.78, size * 0.78);

    // Glass background circle
    final glassBgPaint = Paint()
      ..color = const Color(0xFFFF8C00).withOpacity(0.9) // Dark orange
      ..style = PaintingStyle.fill;

    canvas.drawCircle(glassCenter, glassSize * 0.5, glassBgPaint);

    // Draw simple glass shape
    final glassPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Glass bowl (triangle)
    final glassPath = Path();
    glassPath.moveTo(glassCenter.dx - glassSize * 0.25, glassCenter.dy - glassSize * 0.15);
    glassPath.lineTo(glassCenter.dx + glassSize * 0.25, glassCenter.dy - glassSize * 0.15);
    glassPath.lineTo(glassCenter.dx, glassCenter.dy + glassSize * 0.1);
    glassPath.close();
    canvas.drawPath(glassPath, glassPaint);

    // Glass stem
    final stemPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.008;

    canvas.drawLine(
      Offset(glassCenter.dx, glassCenter.dy + glassSize * 0.1),
      Offset(glassCenter.dx, glassCenter.dy + glassSize * 0.25),
      stemPaint,
    );

    // Glass base
    canvas.drawLine(
      Offset(glassCenter.dx - glassSize * 0.15, glassCenter.dy + glassSize * 0.25),
      Offset(glassCenter.dx + glassSize * 0.15, glassCenter.dy + glassSize * 0.25),
      stemPaint,
    );

    // Convert to image
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // Save to file
    final file = File('assets/icons/app_icon_1024.png');
    await file.create(recursive: true);
    await file.writeAsBytes(pngBytes);

    print('App icon generated successfully: ${file.path}');
  }
}