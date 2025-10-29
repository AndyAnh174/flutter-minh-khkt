import 'package:flutter/material.dart';

class PoseOverlayData {
  final Map<String, Offset> points; // in canvas space (scaled)
  const PoseOverlayData(this.points);
}

class OverlayPainter extends CustomPainter {
  final PoseOverlayData? data;
  final bool warning;
  OverlayPainter({this.data, this.warning = false});

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()
      ..color = warning ? Colors.redAccent : Colors.greenAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final joint = Paint()
      ..color = warning ? Colors.orange : Colors.yellow
      ..style = PaintingStyle.fill;

    // khung demo nhẹ
    canvas.drawRect(Rect.fromLTWH(8, 8, size.width - 16, size.height - 16), outline);

    final d = data;
    if (d == null) return;
    // Vẽ joints
    for (final p in d.points.values) {
      canvas.drawCircle(p, 4, joint);
    }
    // Vẽ các connections cơ bản
    void line(String a, String b) {
      final pa = d.points[a];
      final pb = d.points[b];
      if (pa == null || pb == null) return;
      canvas.drawLine(pa, pb, outline);
    }
    // thân trên
    line('leftShoulder', 'rightShoulder');
    line('leftShoulder', 'leftElbow');
    line('leftElbow', 'leftWrist');
    line('rightShoulder', 'rightElbow');
    line('rightElbow', 'rightWrist');
    // thân dưới
    line('leftHip', 'rightHip');
    line('leftShoulder', 'leftHip');
    line('rightShoulder', 'rightHip');
    line('leftHip', 'leftKnee');
    line('leftKnee', 'leftAnkle');
    line('rightHip', 'rightKnee');
    line('rightKnee', 'rightAnkle');
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


