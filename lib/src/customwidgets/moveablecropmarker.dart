import 'package:flutter/material.dart';

class MoveableCropMarker extends StatefulWidget {

  final double startX;
  final double startY;
  final int markerID;
  MoveableCropMarker(this.startX, this.startY, this.markerID);
  @override State<StatefulWidget> createState() {
    return _MoveableCropMarkerState();
  }
}

class CropMarkerNotification extends Notification {
  final double x;
  final double y;
  final  int id;

  CropMarkerNotification(this.x, this.y, this.id);
}


class _MoveableCropMarkerState extends State<MoveableCropMarker> {

  double xPosition = 5;
  double yPosition = 5;
  Color color;  @override
  void initState() {
    super.initState();
    xPosition = widget.startX;
    yPosition = widget.startY;
  }  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: yPosition-20,
      left: xPosition-20,
      child: GestureDetector(
        onPanUpdate: (tapInfo) {
          setState(() {
            xPosition += tapInfo.delta.dx;
            yPosition += tapInfo.delta.dy;
            CropMarkerNotification(xPosition, yPosition, widget.markerID).dispatch(context);
            /*print(context.size);*/
          });
        },
        child: Icon(Icons.add,size: 40,color: Colors.white

        ),
      ),
    );
  }
}