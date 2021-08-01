import 'dart:ui';

import 'package:clipper/models/draw_model.dart';
import 'package:flutter/material.dart';

class Temp extends StatefulWidget {
  @override
  _TempState createState() => _TempState();
}

class _TempState extends State<Temp> {
  List<DrawModel> points = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanStart: (val) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            points.add(DrawModel(
              offset: renderBox.globalToLocal(val.globalPosition),
              paint: Paint()
                ..color = Colors.teal
                ..strokeCap = StrokeCap.round
                ..strokeWidth = 3,
            ));
          });
        },
        onPanUpdate: (val) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            points.add(DrawModel(
                offset: renderBox.globalToLocal(val.globalPosition),
                paint: Paint()
                  ..strokeCap = StrokeCap.round
                  ..isAntiAlias = true
                  ..color = Colors.teal
                  ..strokeWidth = 3));
          });
        },
        onPanEnd: (val) {
          setState(() {});
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: CustomPaint(
            // size: Size.infinite,
            painter: MyPainter(pointsList: points),
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final List<DrawModel>? pointsList;
  MyPainter({this.pointsList});
  late List<Offset> offsetPoints;
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < (pointsList?.length ?? 2 - 1); i++) {
      if (pointsList?[i].offset != null && pointsList?[i + 1].offset != null) {
        canvas.drawLine(
            pointsList?[i].offset ?? Offset(0, 0),
            pointsList?[i + 1].offset ?? Offset(0, 0),
            pointsList?[i].paint ?? Paint());
      } else if (pointsList?[i].offset != null &&
          pointsList?[i + 1].offset == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList?[i].offset ?? Offset(0, 0));
        offsetPoints.add(Offset((pointsList?[i].offset?.dx ?? 0) + 0.1,
            pointsList?[i].offset?.dy ?? 0 + 0.1));
        canvas.drawPoints(
            PointMode.points, offsetPoints, pointsList?[i].paint ?? Paint());
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
