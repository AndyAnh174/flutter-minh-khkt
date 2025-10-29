import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:camera/camera.dart';

class MlResult {
  final String poseStatus;
  final String eyeState;
  final double? eyeDistanceCm;
  final Map<String, PointF> posePoints; // key: landmark name, value: pixel coords in image space
  final int imageWidth;
  final int imageHeight;
  MlResult({
    required this.poseStatus,
    required this.eyeState,
    this.eyeDistanceCm,
    required this.posePoints,
    required this.imageWidth,
    required this.imageHeight,
  });
}

class MlService {
  late final FaceDetector _faceDetector;
  late final PoseDetector _poseDetector;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
      ),
    );
    _initialized = true;
  }

  Future<void> dispose() async {
    await _faceDetector.close();
    await _poseDetector.close();
    _initialized = false;
  }

  Future<MlResult> processCameraImage(CameraImage image, int rotationDegrees) async {
    final inputImage = _toInputImage(image, rotationDegrees);
    final faces = await _faceDetector.processImage(inputImage);
    final poses = await _poseDetector.processImage(inputImage);

    String eyeState = 'unknown';
    double? distance;
    if (faces.isNotEmpty) {
      final f = faces.first;
      final lp = f.leftEyeOpenProbability;
      final rp = f.rightEyeOpenProbability;
      if (lp != null && rp != null) {
        final avg = (lp + rp) / 2.0;
        eyeState = avg < 0.3 ? 'closed' : 'open';
      }
      // distance: cần calib, tạm bỏ trống
    }

    String poseStatus = 'unknown';
    final Map<String, PointF> posePoints = {};
    if (poses.isNotEmpty) {
      // Heuristic rất đơn giản: nếu có pose → assume sitting
      poseStatus = 'straight';
      final p = poses.first;
      // Trích xuất một số key landmarks phổ biến (nếu có)
      PointF? _get(PoseLandmarkType t) {
        try {
          final lm = p.landmarks[t];
          if (lm == null) return null;
          return PointF(lm.x, lm.y);
        } catch (_) {
          return null;
        }
      }
      void setIf(String key, PoseLandmarkType t) {
        final v = _get(t);
        if (v != null) posePoints[key] = v;
      }
      setIf('nose', PoseLandmarkType.nose);
      setIf('leftEye', PoseLandmarkType.leftEye);
      setIf('rightEye', PoseLandmarkType.rightEye);
      setIf('leftShoulder', PoseLandmarkType.leftShoulder);
      setIf('rightShoulder', PoseLandmarkType.rightShoulder);
      setIf('leftElbow', PoseLandmarkType.leftElbow);
      setIf('rightElbow', PoseLandmarkType.rightElbow);
      setIf('leftWrist', PoseLandmarkType.leftWrist);
      setIf('rightWrist', PoseLandmarkType.rightWrist);
      setIf('leftHip', PoseLandmarkType.leftHip);
      setIf('rightHip', PoseLandmarkType.rightHip);
      setIf('leftKnee', PoseLandmarkType.leftKnee);
      setIf('rightKnee', PoseLandmarkType.rightKnee);
      setIf('leftAnkle', PoseLandmarkType.leftAnkle);
      setIf('rightAnkle', PoseLandmarkType.rightAnkle);

      // Đánh giá tư thế: nếu chênh lệch vai lớn → không ngồi thẳng
      final ls = posePoints['leftShoulder'];
      final rs = posePoints['rightShoulder'];
      if (ls != null && rs != null) {
        final dy = (ls.y - rs.y).abs();
        final threshold = image.height * 0.04; // ~4% chiều cao khung hình
        if (dy > threshold) {
          poseStatus = 'not_straight';
        }
      }
    }

    return MlResult(
      poseStatus: poseStatus,
      eyeState: eyeState,
      eyeDistanceCm: distance,
      posePoints: posePoints,
      imageWidth: image.width,
      imageHeight: image.height,
    );
  }

  InputImage _toInputImage(CameraImage image, int rotationDegrees) {
    // Gộp planes YUV420 thành bytes cho InputImage.fromBytes
    final bytesBuilder = BytesBuilder();
    for (final Plane plane in image.planes) {
      bytesBuilder.add(plane.bytes);
    }
    final bytes = bytesBuilder.takeBytes();

    final ui.Size imageSize = ui.Size(image.width.toDouble(), image.height.toDouble());
    final InputImageRotation rotation = _rotationFromDegrees(rotationDegrees);
    final InputImageFormat format = InputImageFormat.yuv420;
    final metadata = InputImageMetadata(
      size: imageSize,
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  InputImageRotation _rotationFromDegrees(int degrees) {
    switch (degrees) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      case 0:
      default:
        return InputImageRotation.rotation0deg;
    }
  }
}

class PointF {
  final double x;
  final double y;
  const PointF(this.x, this.y);
}


