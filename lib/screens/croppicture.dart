import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:bitmap/bitmap.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:monk/src/customwidgets/moveablecropmarker.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class PixPos {
  final double x;
  final double y;

  PixPos(this.x, this.y);
}

enum CropPoint { UL, UR, LL, LR }

class CropData {
  final double x1, x2, x3, x4;
  final double y1, y2, y3, y4;
  final int width;
  final int height;

  CropData(this.x1, this.y1, this.x2, this.y2, this.x3, this.y3, this.x4,
      this.y4, this.width, this.height);

  math.Point<double> getPixPos(CropPoint cp) {
    switch (cp) {
      case CropPoint.UL:
        return relToPix(x1, y1, height, width);
        break;
      case CropPoint.UR:
        return relToPix(x2, y2, height, width);
        break;
      case CropPoint.LL:
        return relToPix(x4, y4, height, width);
        break;
      case CropPoint.LR:
        return relToPix(x3, y3, height, width);
        break;
    }
  }

  Size getEffectiveSize() {
    double newWidth =
        (getPixPos(CropPoint.UL).distanceTo(getPixPos(CropPoint.UR)) +
                getPixPos(CropPoint.LL).distanceTo(getPixPos(CropPoint.LR))) /
            2;

    double newHeight =
        (getPixPos(CropPoint.UL).distanceTo(getPixPos(CropPoint.LL)) +
                getPixPos(CropPoint.UR).distanceTo(getPixPos(CropPoint.LR))) /
            2;

    return Size(newWidth, newHeight);
  }

  static math.Point<double> relToPix(
      double x, double y, int height, int width) {
    return math.Point<double>(x * width, y * height);
  }

  static int pointDistance(double x, double y, int width, int height) {}

  static int pixPosToIndex(
      math.Point<double> pos, int newWidth, int newHeight) {
    return ((pos.y.round() * newWidth) + pos.x.round()) * 4;
  }

  static Uint8List pixPosToInterp(
      math.Point<double> pos, int newWidth, int newHeight, ByteData buffer) {
    double r = 0;
    double g = 0;
    double b = 0;
    double a = 0;


    int currentr = ((pos.y.floor() * newWidth) + pos.x.floor()) * 4;
    int currentg = ((pos.y.floor() * newWidth) + pos.x.floor()) * 4 + 1;
    int currentb = ((pos.y.floor() * newWidth) + pos.x.floor()) * 4 + 2;
    int currenta = ((pos.y.floor() * newWidth) + pos.x.floor()) * 4 + 3;

    if (pos.x > 1 && pos.x < newWidth - 1) {
      double diff = pos.x - pos.x.floor();
      if (diff < 0.5) {
        double tothis = 1.0 - (0.5 - diff);
        double tobefore = 1.0 - (0.5 + diff);
        r += tothis * buffer.getUint8(currentr).toDouble() +
            tobefore * buffer.getUint8(currentr - 4).toDouble();
        g += tothis * buffer.getUint8(currentg).toDouble() +
            tobefore * buffer.getUint8(currentg - 4).toDouble();
        b += tothis * buffer.getUint8(currentb).toDouble() +
            tobefore * buffer.getUint8(currentb - 4).toDouble();
        a += tothis * buffer.getUint8(currenta).toDouble() +
            tobefore * buffer.getUint8(currenta - 4).toDouble();
    
      } else {
        double tothis = 1.0 - (diff - 0.5);
        double tonext = (diff - 0.5);
        r += tothis * buffer.getUint8(currentr).toDouble() +
            tonext * buffer.getUint8(currentr + 4).toDouble();
        g += tothis * buffer.getUint8(currentg).toDouble() +
            tonext * buffer.getUint8(currentg + 4).toDouble();
        b += tothis * buffer.getUint8(currentb).toDouble() +
            tonext * buffer.getUint8(currentb + 4).toDouble();
        a += tothis * buffer.getUint8(currenta).toDouble() +
            tonext * buffer.getUint8(currenta + 4).toDouble();
     
      }
    } else {
      r += buffer.getUint8(currentr).toDouble();
      g += buffer.getUint8(currentg).toDouble();
      b += buffer.getUint8(currentb).toDouble();
      a += buffer.getUint8(currenta).toDouble();
   
    }
    if (pos.y > 1 && pos.y < newHeight - 1) {
      double diff = pos.y - pos.y.floor();
      if (diff < 0.5) {
        double tothis = 1.0 - (0.5 - diff);
        double tobefore = 1.0 - (0.5 + diff);
        r += tothis * buffer.getUint8(currentr).toDouble() +
            tobefore * buffer.getUint8(currentr - 4*newWidth).toDouble();
        g += tothis * buffer.getUint8(currentg).toDouble() +
            tobefore * buffer.getUint8(currentg - 4*newWidth).toDouble();
        b += tothis * buffer.getUint8(currentb).toDouble() +
            tobefore * buffer.getUint8(currentb - 4*newWidth).toDouble();
        a += tothis * buffer.getUint8(currenta).toDouble() +
            tobefore * buffer.getUint8(currenta - 4*newWidth).toDouble();
     
      } else {
        double tothis = 1.0 - (diff - 0.5);
        double tonext = (diff - 0.5);
        r += tothis * buffer.getUint8(currentr).toDouble() +
            tonext * buffer.getUint8(currentr + 4*newWidth).toDouble();
        g += tothis * buffer.getUint8(currentg).toDouble() +
            tonext * buffer.getUint8(currentg + 4*newWidth).toDouble();
        b += tothis * buffer.getUint8(currentb).toDouble() +
            tonext * buffer.getUint8(currentb + 4*newWidth).toDouble();
        a += tothis * buffer.getUint8(currenta).toDouble() +
            tonext * buffer.getUint8(currenta + 4*newWidth).toDouble();
   
      }
    } else {
      r += buffer.getUint8(currentr).toDouble();
      g += buffer.getUint8(currentg).toDouble();
      b += buffer.getUint8(currentb).toDouble();
      a += buffer.getUint8(currenta).toDouble();
   
    }

    return Uint8List.fromList([(r/2).floor(),(g/2).floor(),(b/2).floor(),(a/2).floor()]);
  }

  static Future<MemoryImage> convert(RawImage rawImage) async {
    var byteData = await rawImage.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return MemoryImage(byteData.buffer.asUint8List());
  }

  Future<Uint8List> cropImage(Uint8List imageBuff) async {
    var decodedImage = await decodeImageFromList(imageBuff);

    ByteData byteData = await decodedImage.toByteData();

    Size si = getEffectiveSize();
    int newHeight = si.height.round() + (4 - si.height.round() % 4);
    int newWidth = si.width.round() + (4 - si.width.round() % 4);

    ByteData byteData2 = ByteData(newWidth * newHeight * 4);

    math.Point<double> UL = getPixPos(CropPoint.UL);
    math.Point<double> UR = getPixPos(CropPoint.UR);
    math.Point<double> LL = getPixPos(CropPoint.LL);
    math.Point<double> LR = getPixPos(CropPoint.LR);
    print(UL);
    print(UR);
    print(LL);
    print(LR);

    math.Point<double> unitL = (LL - UL) * (1 / newHeight);
    math.Point<double> unitR = (LR - UR) * (1 / newHeight);

    for (var h = 0; h < newHeight; h++) {
      math.Point<double> start = UL + (unitL * h);
      math.Point<double> stop = UR + (unitR * h);
      math.Point<double> unitHor = (stop - start) * (1 / newWidth);
      if (h == 0 || h == newHeight - 1) {
        print(start);
        print(unitL);
        print(unitR);
      }

      /*print(unitHor);*/
      for (var w = 0; w < newWidth; w++) {
        math.Point<double> dest = start + unitHor * w;
        Uint8List res = pixPosToInterp(dest, width, height, byteData);

        byteData2.setInt8((h * newWidth + w) * 4,
            res[0]);
        byteData2.setInt8((h * newWidth + w) * 4+1,
            res[1]);
        byteData2.setInt8((h * newWidth + w) * 4+2,
            res[2]);
        byteData2.setInt8((h * newWidth + w) * 4+3,
            res[3]);



        if (h == newHeight - 1 && w == newWidth - 1) {
          print(dest);
        }
      }
    }

    var bm = Bitmap.fromHeadless(
        newWidth, newHeight, byteData2.buffer.asUint8List());

    return bm.buildHeaded();
  }
}

class CropPainter extends CustomPainter {
  final double x1, x2, x3, x4;
  final double y1, y2, y3, y4;

  CropPainter(
      this.x1, this.y1, this.x2, this.y2, this.x3, this.y3, this.x4, this.y4);

  @override
  void paint(Canvas canvas, Size size) {
    final pointMode = ui.PointMode.polygon;
    /*print(size.toString());*/
    final points = [
      Offset(x1, y1),
      Offset(x2, y2),
      Offset(x3, y3),
      Offset(x4, y4),
      Offset(x1, y1),
    ];
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(pointMode, points, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CropPictureScreen extends StatefulWidget {
  final Uint8List imgBuff;
  final int imgWidth, imgHeight;

  const CropPictureScreen(this.imgBuff, this.imgWidth, this.imgHeight);

  @override
  CropPictureScreenState createState() => CropPictureScreenState();
}

class CropPictureScreenState extends State<CropPictureScreen> {
  File imageFile;
  double imageRotation = 0;
  double x1, x2, x3, x4;
  double y1, y2, y3, y4;
  double x1r, x2r, x3r, x4r;
  double y1r, y2r, y3r, y4r;
  GlobalKey stackKey = GlobalKey();
  GlobalKey stackKeyImg = GlobalKey();

  bool firstCall = false;
  Size stackSize;
  Size stackSizeImg;
  double displayedHeight;
  double displayedWidth;

  @override
  void initState() {
    super.initState();
    stackSize = null;
    // To display the current output from the Camera,

    x1 = 1;
    y1 = 1;
    x2 = 99;
    y2 = 1;
    x3 = 99;
    y3 = 99;
    x4 = 1;
    y4 = 99;
    x1r = 0.01;
    y1r = 0.01;
    x2r = 0.99;
    y2r = 0.01;
    x3r = 0.99;
    y3r = 0.99;
    x4r = 0.01;
    y4r = 0.99;
    // Next, initialize the controller. This returns a Future.
    WidgetsBinding.instance.addPostFrameCallback((_) => updateSize(context));
  }

  calcImageDims(Size stackSi) {
    var effWidth = stackSi.width;
    var effHeight = stackSi.height;

    double ratioStack = effWidth / effHeight;
    double ratioImg = widget.imgWidth / widget.imgHeight;
    print(effWidth);
    print(effHeight);
    print(ratioImg);
    print(ratioStack);
    if (ratioStack < ratioImg) {
      displayedWidth = effWidth;
      displayedHeight = effWidth / ratioImg;
    } else {
      displayedHeight = effHeight;
      displayedWidth = effHeight * ratioImg;
    }
    print(displayedHeight);
    print(displayedWidth);
  }

  void updateSize(BuildContext context) {
    if (stackKeyImg.currentContext.size != null &&
        stackSize != stackKey.currentContext.size) {
      calcImageDims(stackKeyImg.currentContext.size);

      stackSize = stackKey.currentContext.size;
      x1 = stackSize.width / 2 - displayedWidth / 2 + displayedWidth * x1r;
      x2 = stackSize.width / 2 - displayedWidth / 2 + displayedWidth * x2r;
      x3 = stackSize.width / 2 - displayedWidth / 2 + displayedWidth * x3r;
      x4 = stackSize.width / 2 - displayedWidth / 2 + displayedWidth * x4r;
      y1 = stackSize.height / 2 - displayedHeight / 2 + displayedHeight * y1r;
      y2 = stackSize.height / 2 - displayedHeight / 2 + displayedHeight * y2r;
      y3 = stackSize.height / 2 - displayedHeight / 2 + displayedHeight * y3r;
      y4 = stackSize.height / 2 - displayedHeight / 2 + displayedHeight * y4r;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bild zuschneiden'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(children: [
          FlatButton(
            child: Text("FERTIG"),
            onPressed: () {
              Navigator.pop(
                  context,
                  CropData(x1r, y1r, x2r, y2r, x3r, y3r, x4r, y4r,
                      widget.imgWidth, widget.imgHeight));
            },
          ),
        ]),
      ),
      body: Column(children: [
        Expanded(
            child: NotificationListener<CropMarkerNotification>(
                onNotification: (notification) {
                  switch (notification.id) {
                    case 0:
                      setState(() {
                        x1 = notification.x;
                        y1 = notification.y;
                        x1r =
                            (x1 - (stackSize.width / 2 - displayedWidth / 2)) /
                                displayedWidth;
                        y1r = (y1 -
                                (stackSize.height / 2 - displayedHeight / 2)) /
                            displayedHeight;
                        print(y1r * widget.imgHeight);
                        print(x1r * widget.imgWidth);
                      });
                      break;
                    case 1:
                      setState(() {
                        x2 = notification.x;
                        y2 = notification.y;
                        x2r =
                            (x2 - (stackSize.width / 2 - displayedWidth / 2)) /
                                displayedWidth;
                        y2r = (y2 -
                                (stackSize.height / 2 - displayedHeight / 2)) /
                            displayedHeight;
                        print(y2r * widget.imgHeight);
                        print(x2r * widget.imgWidth);
                      });
                      break;
                    case 2:
                      setState(() {
                        x3 = notification.x;
                        y3 = notification.y;
                        x3r =
                            (x3 - (stackSize.width / 2 - displayedWidth / 2)) /
                                displayedWidth;
                        y3r = (y3 -
                                (stackSize.height / 2 - displayedHeight / 2)) /
                            displayedHeight;

                        print(y3r * widget.imgHeight);
                        print(x3r * widget.imgWidth);
                      });
                      break;
                    case 3:
                      setState(() {
                        x4 = notification.x;
                        y4 = notification.y;
                        x4r =
                            (x4 - (stackSize.width / 2 - displayedWidth / 2)) /
                                displayedWidth;
                        y4r = (y4 -
                                (stackSize.height / 2 - displayedHeight / 2)) /
                            displayedHeight;

                        print(y4r * widget.imgHeight);
                        print(x4r * widget.imgWidth);
                      });
                      break;
                  }

                  return true;
                },
                child: Stack(children: [
                  Container(
                      key: stackKey,
                      padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width,
                      child: Transform.rotate(
                          angle: imageRotation,
                          child: Image.memory(
                            widget.imgBuff,
                            key: stackKeyImg,
                            fit: BoxFit.contain,
                          ))),
                  stackSize != null
                      ? CustomPaint(
                          painter: CropPainter(x1, y1, x2, y2, x3, y3, x4, y4),
                          size: Size(MediaQuery.of(context).size.width, 100))
                      : Container(),
                  stackSize != null
                      ? MoveableCropMarker(x1, y1, 0)
                      : Container(),
                  stackSize != null
                      ? MoveableCropMarker(x2, y2, 1)
                      : Container(),
                  stackSize != null
                      ? MoveableCropMarker(x3, y3, 2)
                      : Container(),
                  stackSize != null
                      ? MoveableCropMarker(x4, y4, 3)
                      : Container()
                ])))
      ]),

      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializin
    );
  }
}
