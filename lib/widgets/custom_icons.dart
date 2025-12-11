import 'package:flutter/material.dart';

class CustomIcons {
  /// Main DrinkTime app icon - "DT" in a rounded square with drink glass
  static Widget drinkTimeIcon({double size = 48.0, Color? backgroundColor}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF87CEEB),
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: size * 0.1,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background circle
          Center(
            child: Container(
              width: size * 0.75,
              height: size * 0.75,
              decoration: BoxDecoration(
                color: (backgroundColor ?? const Color(0xFF87CEEB)).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // DT text
          Center(
            child: Text(
              'DT',
              style: TextStyle(
                fontSize: size * 0.35,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(size * 0.02, size * 0.02),
                    blurRadius: size * 0.05,
                  ),
                ],
              ),
            ),
          ),
          // Small drink glass icon
          Positioned(
            bottom: size * 0.08,
            right: size * 0.08,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_bar,
                size: size * 0.15,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Beer and cocktail celebration icon
  static Widget celebrationIcon({double size = 48.0}) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Beer mug
          Positioned(
            left: 0,
            bottom: 0,
            child: CustomPaint(
              size: Size(size * 0.45, size * 0.6),
              painter: BeerMugPainter(),
            ),
          ),
          // Cocktail glass
          Positioned(
            right: 0,
            bottom: 0,
            child: CustomPaint(
              size: Size(size * 0.4, size * 0.5),
              painter: CocktailGlassPainter(),
            ),
          ),
          // Celebration lines
          Positioned(
            top: 0,
            right: size * 0.15,
            child: CustomPaint(
              size: Size(size * 0.3, size * 0.25),
              painter: CelebrationLinesPainter(),
            ),
          ),
        ],
      ),
    );
  }

  /// Drink tickets icon
  static Widget ticketsIcon({double size = 48.0}) {
    return SizedBox(
      width: size,
      height: size * 0.7,
      child: Stack(
        children: [
          // Back ticket
          Positioned(
            left: size * 0.1,
            top: size * 0.05,
            child: Transform.rotate(
              angle: -0.1,
              child: Container(
                width: size * 0.7,
                height: size * 0.4,
                decoration: BoxDecoration(
                  color: Colors.orange.shade400,
                  borderRadius: BorderRadius.circular(size * 0.05),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: size * 0.02,
                      offset: Offset(size * 0.01, size * 0.01),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'DRINK',
                    style: TextStyle(
                      fontSize: size * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Front ticket
          Positioned(
            right: size * 0.1,
            bottom: 0,
            child: Transform.rotate(
              angle: 0.1,
              child: Container(
                width: size * 0.7,
                height: size * 0.4,
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(size * 0.05),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: size * 0.02,
                      offset: Offset(size * 0.01, size * 0.01),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'TIME',
                    style: TextStyle(
                      fontSize: size * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Person with drink badge icon
  static Widget personBadgeIcon({double size = 48.0}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF4682B4),
        border: Border.all(
          color: const Color(0xFF1E3A8A),
          width: size * 0.05,
        ),
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: PersonWithDrinkPainter(),
      ),
    );
  }
}

class BeerMugPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.shade600
      ..style = PaintingStyle.fill;

    final handlePaint = Paint()
      ..color = Colors.brown.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08;

    // Beer body
    final beerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.2, size.width * 0.7, size.height * 0.8),
      Radius.circular(size.width * 0.05),
    );
    canvas.drawRRect(beerRect, paint);

    // Foam
    final foamPaint = Paint()..color = Colors.white;
    final foamRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.2, size.width * 0.7, size.height * 0.15),
      Radius.circular(size.width * 0.05),
    );
    canvas.drawRRect(foamRect, foamPaint);

    // Handle
    final handlePath = Path();
    handlePath.addOval(Rect.fromLTWH(
      size.width * 0.6,
      size.height * 0.4,
      size.width * 0.3,
      size.height * 0.3,
    ));
    canvas.drawPath(handlePath, handlePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CocktailGlassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glassPaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08;

    final liquidPaint = Paint()
      ..color = Colors.green.shade400
      ..style = PaintingStyle.fill;

    // Glass triangle
    final glassPath = Path();
    glassPath.moveTo(size.width * 0.1, size.height * 0.1);
    glassPath.lineTo(size.width * 0.9, size.height * 0.1);
    glassPath.lineTo(size.width * 0.5, size.height * 0.6);
    glassPath.close();

    // Liquid
    canvas.drawPath(glassPath, liquidPaint);

    // Glass outline
    canvas.drawPath(glassPath, glassPaint);

    // Stem
    final stemPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05;

    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.9),
      stemPaint,
    );

    // Base
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.9),
      Offset(size.width * 0.8, size.height * 0.9),
      stemPaint,
    );

    // Olive
    final olivePaint = Paint()..color = Colors.green.shade800;
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.25),
      size.width * 0.05,
      olivePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CelebrationLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.yellow.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    // Three celebration lines
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.3, 0),
      linePaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.3),
      Offset(size.width * 0.5, 0),
      linePaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.7, size.height * 0.2),
      Offset(size.width * 0.9, 0),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PersonWithDrinkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final personPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final drinkPaint = Paint()
      ..color = Colors.orange.shade400
      ..style = PaintingStyle.fill;

    final radius = size.width * 0.4;
    final center = Offset(size.width * 0.5, size.height * 0.5);

    // Person head
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.3),
      radius * 0.25,
      personPaint,
    );

    // Person body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.1),
        width: radius * 0.4,
        height: radius * 0.6,
      ),
      Radius.circular(radius * 0.1),
    );
    canvas.drawRRect(bodyRect, personPaint);

    // Raised arm with drink
    canvas.drawLine(
      Offset(center.dx + radius * 0.15, center.dy - radius * 0.1),
      Offset(center.dx + radius * 0.4, center.dy - radius * 0.4),
      Paint()
        ..color = Colors.white
        ..strokeWidth = radius * 0.1
        ..strokeCap = StrokeCap.round,
    );

    // Drink glass
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.45, center.dy - radius * 0.5),
        width: radius * 0.15,
        height: radius * 0.2,
      ),
      drinkPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}