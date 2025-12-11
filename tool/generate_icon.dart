import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

void main() async {
  print('Generating app icon...');
  await generateAppIcon();
  print('Icon generation complete!');
}

Future<void> generateAppIcon() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const size = 1024.0;

  // Background with rounded corners - Sky blue
  final bgPaint = Paint()
    ..color = const Color(0xFF87CEEB)
    ..style = PaintingStyle.fill;

  final bgRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, size, size),
    const Radius.circular(size * 0.22),
  );
  canvas.drawRRect(bgRect, bgPaint);

  // Inner circle for depth
  final circlePaint = Paint()
    ..color = const Color(0xFF4682B4).withOpacity(0.3)
    ..style = PaintingStyle.fill;

  canvas.drawCircle(
    const Offset(size * 0.5, size * 0.5),
    size * 0.35,
    circlePaint,
  );

  // Create text for "DT"
  final textBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
    textAlign: TextAlign.center,
    fontSize: size * 0.35,
    fontWeight: FontWeight.bold,
  ));

  textBuilder.pushStyle(ui.TextStyle(
    color: const Color(0xFFFFFFFF),
    fontSize: size * 0.35,
    fontWeight: FontWeight.bold,
    shadows: [
      const ui.Shadow(
        color: Color(0x4D000000),
        offset: Offset(8, 8),
        blurRadius: 12,
      ),
    ],
  ));

  textBuilder.addText('DT');
  final paragraph = textBuilder.build();
  paragraph.layout(const ui.ParagraphConstraints(width: size));

  // Center the text
  final textOffset = Offset(
    (size - paragraph.minIntrinsicWidth) * 0.5,
    (size - paragraph.height) * 0.5,
  );
  canvas.drawParagraph(paragraph, textOffset);

  // Small drink glass icon in bottom-right
  const glassSize = size * 0.18;
  const glassCenter = Offset(size * 0.78, size * 0.78);

  // Glass background circle - Orange
  final glassBgPaint = Paint()
    ..color = const Color(0xFFFF8C00).withOpacity(0.9)
    ..style = PaintingStyle.fill;

  canvas.drawCircle(glassCenter, glassSize * 0.5, glassBgPaint);

  // Draw simple martini glass shape
  final glassPaint = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.fill;

  // Glass bowl (triangle)
  final glassPath = Path();
  glassPath.moveTo(glassCenter.dx - glassSize * 0.3, glassCenter.dy - glassSize * 0.2);
  glassPath.lineTo(glassCenter.dx + glassSize * 0.3, glassCenter.dy - glassSize * 0.2);
  glassPath.lineTo(glassCenter.dx, glassCenter.dy + glassSize * 0.1);
  glassPath.close();
  canvas.drawPath(glassPath, glassPaint);

  // Glass stem
  final stemPaint = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = size * 0.01
    ..strokeCap = StrokeCap.round;

  canvas.drawLine(
    Offset(glassCenter.dx, glassCenter.dy + glassSize * 0.1),
    Offset(glassCenter.dx, glassCenter.dy + glassSize * 0.3),
    stemPaint,
  );

  // Glass base
  final basePaint = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = size * 0.015
    ..strokeCap = StrokeCap.round;

  canvas.drawLine(
    Offset(glassCenter.dx - glassSize * 0.2, glassCenter.dy + glassSize * 0.3),
    Offset(glassCenter.dx + glassSize * 0.2, glassCenter.dy + glassSize * 0.3),
    basePaint,
  );

  // Convert to image and save
  final picture = recorder.endRecording();
  final img = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final pngBytes = byteData!.buffer.asUint8List();

  // Create directories and save file
  final file = File('assets/icons/app_icon_1024.png');
  await file.create(recursive: true);
  await file.writeAsBytes(pngBytes);

  print('✅ App icon saved to: ${file.path}');
}