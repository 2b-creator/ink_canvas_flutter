import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: LayoutBuilder(
        builder: (_, constraints) => Container(
          width: constraints.widthConstraints().maxWidth,
          height: constraints.heightConstraints().maxHeight,
          color: const Color.fromARGB(255, 3, 61, 13),
          child: DrawingCanvas(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({super.key});

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  List<Offset> points = [];
  List<double> strokeWidths = [];
  Offset? lastPoint;
  DateTime? lastTime;
  double lastStrokeWidth = 5.0; // 上一个点的线条宽度
  double thickestStroke = 5.0;
  double thinestStroke = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (detials) {
        setState(() {
          lastPoint = detials.localPosition;
          lastTime = DateTime.now();
          points.add(detials.localPosition);
          strokeWidths.add(1.0); // 初始线条粗细
          lastStrokeWidth = 1.0; // 记录初始线条宽度
        });
      },
      onPanUpdate: (details) {
        setState(() {
          final currentPoint = details.localPosition;
          final currentTime = DateTime.now();

          // 计算两点间的距离
          final distance =
              (lastPoint != null) ? (currentPoint - lastPoint!).distance : 0.0;
          // 计算时间差
          final timeDelta = (lastTime != null)
              ? currentTime.difference(lastTime!).inMilliseconds
              : 1;

          // 根据速度调整线条粗细，速度越快，线条越细；速度越慢，线条越粗
          double speed = distance / timeDelta; // 简单速度计算，单位为像素/毫秒
          double targetStrokeWidth = max(
              thinestStroke, min(thickestStroke, thickestStroke / (speed + 1)));
          if (targetStrokeWidth.isNaN) {
            targetStrokeWidth = thickestStroke;
          }
          double smoothedStrokeWidth =
              lerpDouble(lastStrokeWidth, targetStrokeWidth, 0.3)!;
          points.add(currentPoint); // 添加当前点
          strokeWidths.add(smoothedStrokeWidth); // 添加当前点的线条粗细

          // 更新上一个点和时间
          lastPoint = currentPoint;
          lastTime = currentTime;
          lastStrokeWidth = smoothedStrokeWidth;
        });
      },
      onPanEnd: (details) {
        setState(() {
          points.add(Offset.zero); // 添加一个分隔点，以区分不同的笔画
          strokeWidths.add(0.0);
        });
      },
      child: CustomPaint(
        size: Size.infinite,
        painter: PencilPainter(points, strokeWidths),
      ),
    );
  }
}

class PencilPainter extends CustomPainter {
  final List<Offset> points;
  final List<double> strokeWidths;

  PencilPainter(this.points, this.strokeWidths);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        // 设置当前线条的粗细
        paint.strokeWidth = strokeWidths[i];
        // 绘制两点之间的线
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // 每次有新点时都需要重绘
  }
}
