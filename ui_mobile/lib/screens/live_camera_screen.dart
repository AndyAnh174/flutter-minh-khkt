import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/tts_service.dart';
import '../data/repositories/session_repository.dart';
import 'dart:async';
import '../widgets/overlay_painter.dart';
import '../services/ml_service.dart';

class LiveCameraScreen extends StatefulWidget {
  const LiveCameraScreen({super.key});

  @override
  State<LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends State<LiveCameraScreen> {
  CameraController? _controller;
  Future<void>? _initFuture;
  final TtsService _tts = TtsService();
  final SessionRepository _repo = SessionRepository();
  int? _sessionId;
  Timer? _timer;
  final MlService _ml = MlService();
  // streaming mode removed in favor of still-capture periodic
  PoseOverlayData? _overlayData;
  bool _warning = false;
  String _warningText = '';
  int _landmarkCount = 0;
  bool _usingFrontCamera = false;
  int _cameraIndex = 0;
  List<CameraDescription> _cameras = const [];

  @override
  void initState() {
    super.initState();
    _initFuture = _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return;
    _cameras = await availableCameras();
    final camera = _cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );
    _cameraIndex = _cameras.indexOf(camera);
    _usingFrontCamera = camera.lensDirection == CameraLensDirection.front;
    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    _controller = controller;
    await controller.initialize();
    await _ml.initialize();
    if (mounted) setState(() {});
    _sessionId = await _repo.startSession();
    // Dùng chế độ chụp ảnh định kỳ để ML Kit ổn định hơn
    _timer = Timer.periodic(const Duration(milliseconds: 800), (_) async {
      if (!mounted || _controller == null || !_controller!.value.isInitialized) return;
      if (_controller!.value.isTakingPicture) return;
      try {
        final file = await _controller!.takePicture();
        final rotation = _controller!.description.sensorOrientation;
        final previewSize = _controller!.value.previewSize;
        final w = (previewSize?.width ?? 640).toInt();
        final h = (previewSize?.height ?? 480).toInt();
        final res = await _ml.processFile(file.path, rotation, w, h);
        final sid = _sessionId;
        if (sid != null) {
          final now = DateTime.now().millisecondsSinceEpoch;
          await _repo.addFrame(
            sessionId: sid,
            tsMs: now,
            poseStatus: res.poseStatus,
            eyeState: res.eyeState,
            eyeDistanceCm: res.eyeDistanceCm,
          );
        }
        final isClosed = res.eyeState == 'closed';
        final badPosture = res.poseStatus == 'not_straight';
        if (isClosed) _tts.speak('Bạn đang buồn ngủ, hãy mở mắt nhé.');
        if (mounted && _controller != null && _controller!.value.isInitialized) {
          final screenSize = MediaQuery.of(context).size;
          final previewW = w.toDouble();
          final previewH = h.toDouble();
          final sx = screenSize.width / previewW;
          final sy = screenSize.height / previewH;
          final Map<String, Offset> mapped = {};
          res.posePoints.forEach((k, v) {
            final double x = _usingFrontCamera ? (previewW - v.x) : v.x;
            mapped[k] = Offset(x * sx, v.y * sy);
          });
          setState(() {
            _overlayData = PoseOverlayData(mapped);
            _warning = isClosed || badPosture;
            _warningText = isClosed
                ? 'Cảnh báo: Mắt đang nhắm'
                : (badPosture ? 'Cảnh báo: Ngồi chưa thẳng' : '');
            _landmarkCount = res.posePoints.length;
          });
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_sessionId != null) {
      _repo.endSession(_sessionId!);
    }
    _ml.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Camera'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: _switchCamera,
            tooltip: 'Đổi camera',
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller == null || !_controller!.value.isInitialized) {
            return const Center(child: Text('Không thể khởi tạo camera'));
          }
          return Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(_controller!),
              IgnorePointer(
                child: CustomPaint(
                  painter: OverlayPainter(data: _overlayData, warning: _warning),
                ),
              ),
              if (_warning && _warningText.isNotEmpty)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _warningText,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Landmarks: $_landmarkCount',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _tts.speak('Xin chào, đây là cảnh báo thử nghiệm.'),
        child: const Icon(Icons.volume_up),
      ),
    );
  }

  Future<void> _switchCamera() async {
    if (_cameras.isEmpty) return;
    _timer?.cancel();
    await _controller?.dispose();
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    final camera = _cameras[_cameraIndex];
    _usingFrontCamera = camera.lensDirection == CameraLensDirection.front;
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await _controller!.initialize();
    if (!mounted) return;
    setState(() {});
    // Khởi động lại timer chụp định kỳ
    _timer = Timer.periodic(const Duration(milliseconds: 800), (_) async {
      if (!mounted || _controller == null || !_controller!.value.isInitialized) return;
      if (_controller!.value.isTakingPicture) return;
      try {
        final file = await _controller!.takePicture();
        final rotation = _controller!.description.sensorOrientation;
        final previewSize = _controller!.value.previewSize;
        final w = (previewSize?.width ?? 640).toInt();
        final h = (previewSize?.height ?? 480).toInt();
        final res = await _ml.processFile(file.path, rotation, w, h);
        final isClosed = res.eyeState == 'closed';
        final badPosture = res.poseStatus == 'not_straight';
        if (mounted && _controller != null && _controller!.value.isInitialized) {
          final screenSize = MediaQuery.of(context).size;
          final previewW = w.toDouble();
          final previewH = h.toDouble();
          final sx = screenSize.width / previewW;
          final sy = screenSize.height / previewH;
          final Map<String, Offset> mapped = {};
          res.posePoints.forEach((k, v) {
            final double x = _usingFrontCamera ? (previewW - v.x) : v.x;
            mapped[k] = Offset(x * sx, v.y * sy);
          });
          setState(() {
            _overlayData = PoseOverlayData(mapped);
            _warning = isClosed || badPosture;
            _warningText = isClosed
                ? 'Cảnh báo: Mắt đang nhắm'
                : (badPosture ? 'Cảnh báo: Ngồi chưa thẳng' : '');
            _landmarkCount = res.posePoints.length;
          });
        }
      } catch (_) {}
    });
  }
}


