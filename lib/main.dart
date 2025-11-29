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
  final double strokeWidth;

  MyPainter({this.zoom = 1.0, this.strokeWidth = 2.0});

  @override
  void paint(Canvas canvas, Size size) {
    
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
  
  double _zoom = 0.3;
  double _baseZoom = 0.3;
  
  double _strokeWidth = 2.0;
  double _baseStrokeWidth = 2.0;
  Offset _baseFocalPoint = Offset.zero;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    /*
    _zoomAnimation = Tween<double>(begin: 0.10, end: 0.20)
        .animate(_controller)
      ..addListener(() {
        setState(() {});
      });
      */

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
        child: GestureDetector(
          onScaleStart: (details) {
            _baseZoom = _zoom;
            _baseStrokeWidth = _strokeWidth;
            _baseFocalPoint = details.localFocalPoint;
          },
          onScaleUpdate: (details) {
            setState(() {
              _zoom = _baseZoom * details.scale;
              
              double dy = details.localFocalPoint.dy - _baseFocalPoint.dy;
              _strokeWidth = (_baseStrokeWidth - (dy * 0.01)).clamp(0.05, 30.0);
            });
          },
          child: CustomPaint(
            size: const Size(1440, 1440), // size of canvas
            painter: MyPainter(zoom: _zoom, strokeWidth: _strokeWidth)
          ),
        ),
      )
    );
  }
}
