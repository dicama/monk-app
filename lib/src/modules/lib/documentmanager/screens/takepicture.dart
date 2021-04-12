import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:monk/src/modules/lib/documentmanager/screens/reviewpicture.dart';
import 'package:monk/src/service/cameraservice.dart';
import 'package:monk/src/service/encryptedfs.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class TakePictureScreen extends StatefulWidget {
  final bool first;
  final FileSysDirectory fixedFolder;

  const TakePictureScreen(
      {Key key, this.first = false, this.fixedFolder = null})
      : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      CameraService().getFirstCamera(),
      // Define the resolution to use.
      ResolutionPreset.high,
    );
    if(widget.fixedFolder != null)
    {

      print("Taking fixed dir take");
    }
    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Construct the path where the image should be saved using the
            // pattern package.
            final path = join(
              // Store the picture in the temp directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );

            XFile imageFile2 = await _controller.takePicture();
            var imgData = await imageFile2
                .readAsBytes(); // If the picture was taken, display it on a new screen.

            if (widget.first) {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, __, ___) => ReviewPictureScreen(
                            imgData,
                            fixedFolder: widget.fixedFolder,
                          ),
                      transitionDuration: Duration(seconds: 0)));
            } else {
              Navigator.pop(context, imgData);
            }
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }
}
