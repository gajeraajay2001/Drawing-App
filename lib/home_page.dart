import 'dart:typed_data';
import 'dart:ui';
import 'package:clipper/models/draw_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ScreenshotController controller = ScreenshotController();
  List<DrawModel> points = [];
  SelectedMode? mode;
  bool openMode = false;
  Color color = Colors.black;
  double opacity = 1;
  double width = 3;

  Widget changeColor({Color? colors}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          color = colors ?? Colors.black;
        });
      },
      child: ClipOval(
        child: Container(
          height: 30,
          width: 30,
          color: colors,
        ),
      ),
    );
  }

  Widget drawingArea() {
    return GestureDetector(
      onPanStart: (val) {
        setState(() {
          RenderBox box = context.findRenderObject() as RenderBox;
          points.add(
            DrawModel(
              a: 1,
              offset: box.globalToLocal(val.globalPosition),
              paint: Paint()
                ..color = color.withOpacity(opacity)
                ..strokeWidth = width,
            ),
          );
        });
      },
      onPanUpdate: (val) {
        setState(() {
          RenderBox box = context.findRenderObject() as RenderBox;
          points.add(
            DrawModel(
              a: 1,
              offset: box.globalToLocal(val.globalPosition),
              paint: Paint()
                ..color = color.withOpacity(opacity)
                ..strokeWidth = width,
            ),
          );
        });
      },
      onPanEnd: (val) {
        setState(() {
          points.add(
            DrawModel(a: 0),
          );
        });
      },
      child: CustomPaint(
        painter: MyPainter(points: points),
        child: Container(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top,
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }

  Future<dynamic> showCaptureWidget(
      {BuildContext? context, Uint8List? capturedImage}) {
    return showDialog(
        context: context!,
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text("ScreenShot of your Drawing"),
              actions: [
                IconButton(
                  onPressed: () async {
                    final image = await controller.captureFromWidget(
                        Container(color: Colors.white, child: drawingArea()));
                    if (image == null) return;
                    await [Permission.storage].request();
                    final time = DateTime.now()
                        .toIso8601String()
                        .replaceAll('.', '-')
                        .replaceAll(':', '-');
                    final name = 'Screnshot${time}';
                    final result =
                        await ImageGallerySaver.saveImage(image, name: name);
                    print(result['path']);
                  },
                  icon: Icon(Icons.download),
                ),
              ],
            ),
            body: Center(
              child: capturedImage == null
                  ? Container()
                  : Image.memory(capturedImage),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Draw Your Thoughts"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              controller
                  .capture(delay: Duration(milliseconds: 10))
                  .then((capturedImage) async {
                showCaptureWidget(
                    context: context, capturedImage: capturedImage!);
              }).catchError((onError) {
                print(onError);
              });
            },
            icon: Icon(Icons.camera),
            tooltip: "Take ScreenShot",
          ),
        ],
      ),
      body: Screenshot(
        controller: controller,
        child: drawingArea(),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 60, maxHeight: 110),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Colors.tealAccent,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          openMode = true;
                          mode = SelectedMode.StrokeWidth;
                        });
                      },
                      icon: Icon(Icons.adjust),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          openMode = true;
                          mode = SelectedMode.Opacity;
                        });
                      },
                      icon: Icon(Icons.opacity),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          openMode = true;
                          mode = SelectedMode.Color;
                        });
                      },
                      icon: Icon(Icons.color_lens),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          openMode = false;
                          points.clear();
                        });
                      },
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              SizedBox(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Visibility(
                    visible: openMode,
                    child: (mode == SelectedMode.Color)
                        ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                changeColor(colors: Colors.red),
                                changeColor(colors: Colors.blue),
                                changeColor(colors: Colors.purple),
                                changeColor(colors: Colors.amber),
                                changeColor(colors: Colors.green),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text("Pick a Color!"),
                                            content: SingleChildScrollView(
                                              child: ColorPicker(
                                                pickerAreaHeightPercent: 0.8,
                                                onColorChanged: (Color value) {
                                                  setState(() {
                                                    color = value;
                                                  });
                                                },
                                                pickerColor: color,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text("Save"))
                                            ],
                                          );
                                        });
                                  },
                                  child: ClipOval(
                                    child: Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                        colors: [
                                          Colors.red,
                                          Colors.green,
                                          Colors.blue
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Slider(
                            onChanged: (val) {
                              setState(() {
                                (mode == SelectedMode.Opacity)
                                    ? opacity = val
                                    : width = val;
                              });
                            },
                            min: 0,
                            max: (mode == SelectedMode.Opacity) ? 1 : 40,
                            value: (mode == SelectedMode.Opacity)
                                ? opacity
                                : width,
                            activeColor: (mode == SelectedMode.Opacity)
                                ? Colors.blue.withOpacity(0.5)
                                : Colors.blue,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final List<DrawModel> points;
  MyPainter({required this.points});
  List<Offset> offsetPoints = [];
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].a != 0 && points[i + 1].a != 0) {
        canvas.drawLine(
            points[i].offset!, points[i + 1].offset!, points[i].paint!);
      } else if (points[i].a != 0 && points[i + 1].a == 0) {
        offsetPoints.clear();
        offsetPoints.add(points[i].offset!);
        offsetPoints.add(
            Offset(points[i].offset!.dx + 0.1, points[i].offset!.dy + 0.1));
        canvas.drawPoints(PointMode.points, offsetPoints, points[i].paint!);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

enum SelectedMode { StrokeWidth, Opacity, Color }
