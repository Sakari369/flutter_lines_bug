import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter lines antialiasing bug on Impeller',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage()
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class MyPainter extends CustomPainter {
  final double zoom;

  MyPainter({this.zoom = 0.3});

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 2.0;

    Paint paintRed = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFFFF0000);

    Paint paintBlue = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF0000FF);

    Paint paintGreen = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF00FF00);

    double dist = 48;

    canvas.save();
    canvas.translate((size.width/2) - dist, size.height/2);
    canvas.scale(zoom, zoom);

    for (double radius=1100; radius>2; radius -= 64) {
      final path = Path();
      path.moveTo(radius * cos(0), radius * sin(0));
      for (int i = 0; i < 6; i++) {
        path.lineTo(
            radius * cos(pi * i / 3),
            radius * sin(pi * i / 3)
        );
      }
      path.close();
      canvas.drawPath(path, paintRed);
    }

    canvas.restore();

    canvas.save();
    canvas.translate((size.width/2), size.height/2);
    canvas.scale(zoom, zoom);

    for (double radius=1100; radius>2; radius -= 64) {
      final path = Path();
      path.moveTo(radius * cos(0), radius * sin(0));
      for (int i = 0; i < 6; i++) {
        path.lineTo(
            radius * cos(pi * i / 3),
            radius * sin(pi * i / 3)
        );
      }
      path.close();
      canvas.drawPath(path, paintBlue);
    }

    canvas.restore();

    canvas.save();
    canvas.translate((size.width/2) + dist, size.height/2);
    canvas.scale(zoom, zoom);

    for (double radius=1100; radius>2; radius -= 64) {
      final path = Path();
      path.moveTo(radius * cos(0), radius * sin(0));
      for (int i = 0; i < 6; i++) {
        path.lineTo(
            radius * cos(pi * i / 3),
            radius * sin(pi * i / 3)
        );
      }
      path.close();
      canvas.drawPath(path, paintGreen);
    }

    canvas.restore();

  }

  @override bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _MyHomePageState extends State<MyHomePage>
  with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _zoomAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    _zoomAnimation = Tween<double>(begin: 0.10, end: 0.20)
        .animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();
  }

  @override void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Center(
        child: CustomPaint(
          size: const Size(1280, 1280), // size of canvas
          painter: MyPainter(zoom: _zoomAnimation.value),
        ),
      )
    );
  }
}
