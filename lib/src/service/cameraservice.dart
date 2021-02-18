import 'package:camera/camera.dart';



class CameraService {
  static final CameraService _instance = CameraService._internal();

  factory CameraService() => _instance;
  List<CameraDescription> cameras;
  CameraDescription firstCamera;

  CameraService._internal() {
    // init things inside this
  }

  init() {
    availableCameras().then((test) {
      cameras = test;
      firstCamera = cameras.first;
      print("Found cameras");
      print(test);
    });
  }

  CameraDescription getFirstCamera()
  {
    return firstCamera;
  }


}
