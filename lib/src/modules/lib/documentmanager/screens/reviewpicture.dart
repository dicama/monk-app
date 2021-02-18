import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:monk/src/service/encryptedfs.dart';
import 'savefile.dart';
import 'takepicture.dart';

import '../../../../../screens/croppicture.dart';

class ReviewPictureScreen extends StatefulWidget {
  final Uint8List binaryImage;

  final FileSysDirectory fixedFolder;

  const ReviewPictureScreen(this.binaryImage, {this.fixedFolder = null});

  @override
  ReviewPictureScreenState createState() => ReviewPictureScreenState();
}

class ReviewPictureScreenState extends State<ReviewPictureScreen> {

  double imageRotation = 0;
  int width;
  int height;
  Map<int, CropData> cp = Map();
  Map<int, Uint8List> imageDatas = Map();
  Map<int, Uint8List> cropDatas = Map();
  int currentFile = 0;
  Uint8List currentImage;

  @override
  Future<void> initState() {
    super.initState();
    // To display the current output from the Camera,
    currentFile = 0;
    imageDatas[currentFile] = widget.binaryImage;
    currentImage = widget.binaryImage;
    decodeImageFromList(imageDatas[currentFile]).then((decodedImage) {
      width = decodedImage.width;
      height = decodedImage.height;
    });
    if(widget.fixedFolder != null)
    {

      print("Taking fixed dir rev");
    }
    // Next, initialize the controller. This returns a Future.
  }

  Widget croppedImage(BuildContext bc) {
    if (cp.keys.contains(currentFile)) {
      return FutureBuilder<Uint8List>(
          future: cp[currentFile].cropImage(currentImage),
          builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
            if (snapshot.hasData) {
              cropDatas[currentFile] = snapshot.data;
              /*img.Image image = img.decodeImage(snapshot.data);*/

              // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
              /*img.Image thumbnail = img.copyResize(image, width: 120);*/

              // Save the thumbnail as a PNG.
              /*new File('out/thumbnail-test.png')..writeAsBytesSync(img.encodePng(thumbnail));*/

              return Image.memory(snapshot.data, fit: BoxFit.contain);
            } else if (snapshot.hasError) {
              print(snapshot.error.toString());
              return Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              );
            } else {
              return SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              );
            }
          });
    } else {
      return Image.memory(currentImage, fit: BoxFit.contain);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Take a picture'),
            actions: [IconButton(icon: Icon(Icons.drive_file_rename_outline))]),
        bottomNavigationBar: BottomAppBar(
          child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.library_add),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TakePictureScreen(first: false, fixedFolder: widget.fixedFolder,),
                    ));
                    if(result != null){
                      currentFile +=1;
                      imageDatas[currentFile] = result;
                      currentImage = result;
                      decodeImageFromList(imageDatas[currentFile]).then((decodedImage) {
                        width = decodedImage.width;
                        height = decodedImage.height;
                      });
                    }
                    setState(() {

                    });

                  },
                ),
                FlatButton(
                  child: Text("WEITER"),
                  onPressed: () {
                    List<Uint8List> bundle = List();    //  build the bundle from collected data
                    for (int i=0; i < currentFile + 1; i++) {
                      if (cropDatas.keys.contains(i)) {
                        bundle.add(cropDatas[i]);  // add crop data if exists
                      } else {
                        bundle.add(imageDatas[i]);
                      }
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SaveFileScreen(bundle,fixedFolder: widget.fixedFolder,)),
                    );
                  },
                ),
              ]),
        ),
        body: Column(children: [
          Expanded(
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  child: Transform.rotate(
                      angle: imageRotation, child: croppedImage(context)))),
          Row(children: [
            Expanded(
                child: IconButton(
              icon: Icon(Icons.arrow_back_outlined),
              onPressed: () {},
            )),
            Expanded(
                child: IconButton(
              icon: Icon(Icons.brush),
              onPressed: () {},
            )),
            Expanded(
                child: IconButton(
              icon: Icon(Icons.rotate_90_degrees_ccw),
              onPressed: () {
                setState(() {
                  imageRotation -= math.pi / 2;
                });
              },
            )),
            Expanded(
                child: IconButton(
                    icon: Icon(Icons.crop),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CropPictureScreen(
                                imageDatas[currentFile], width, height)),
                      );
                      cp[currentFile] = result;
                      setState(() {
                      });
                    })),
          ])
        ])
        // Wait until the controller is initialized before displaying the
        // camera preview. Use a FutureBuilder to display a loading spinner
        // until the controller has finished initializin
        );
  }
}
