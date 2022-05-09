import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class OtherStatus extends StatelessWidget {
  const OtherStatus(
      {Key? key,
      this.name,
      this.time,
      this.imageName,
      this.isSeen,
      this.statusNum})
      : super(key: key);
  final String? name;
  final String? time;
  final String? imageName;
  final bool? isSeen;
  final int? statusNum;
  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: CustomPaint(
          painter: StatusPainter(isSeen: isSeen, statusNum: statusNum),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: Colors.amber,
          ),
        ),
        title: Text(
          "Name",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          "Today at 8:00",
          style: TextStyle(color: Colors.grey[900], fontSize: 14),
        ));
  }
}
//đổi ra độ
degreeToAngle(double degree) {
  return degree * pi / 180;
}
//vẽ vòng tròn trạng thát avatar.....................................
class StatusPainter extends CustomPainter {
  late bool? isSeen;
  late int? statusNum;
  StatusPainter({this.isSeen, this.statusNum});
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 6
      ..color = isSeen! ? Colors.grey : Color(0xff21bfa6)
      ..style = PaintingStyle.stroke;
    drawArc(canvas, size, paint);
  }

  void drawArc(Canvas canvas, Size size, Paint paint) {
    if (statusNum == 1) {
      canvas.drawArc(Rect.fromLTWH(0, 0, size.width, size.height),
          degreeToAngle(0), degreeToAngle(360), false, paint);
    } else {
      double degree = -90;
      double arc = 360 / statusNum!;
      for (int i = 0; i < statusNum!; i++) {
        canvas.drawArc(Rect.fromLTWH(0, 0, size.width, size.height),
            degreeToAngle(degree + 4), degreeToAngle(arc - 8), false, paint);
        degree = degree + arc;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
