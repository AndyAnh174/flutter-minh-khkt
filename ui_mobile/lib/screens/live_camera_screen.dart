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
  bool _streaming = false;
  int _frameCount = 0;
  PoseOverlayData? _overlayData;
  bool _warning = false;
  String _warningText = '';

  @override
  void initState() {
    super.initState();
    _initFuture = _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return;
    final cameras = await availableCameras();
    final camera = cameras.first;
    final controller = CameraController(camera, ResolutionPreset.medium, enableAudio: false);
    _controller = controller;
    await controller.initialize();
    await _ml.initialize();
    if (mounted) setState(() {});
    _sessionId = await _repo.startSession();
    // Bắt đầu stream frame → suy luận mỗi N khung
    if (!_streaming) {
      _streaming = true;
      _controller!.startImageStream((image) async {
        _frameCount++;
        // Throttle: chỉ xử lý mỗi 5 khung
        if (_frameCount % 5 != 0) return;
        final rotation = _controller!.description.sensorOrientation;
        try {
          final res = await _ml.processCameraImage(image, rotation);
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
          // Cập nhật overlay: scale điểm từ image space → canvas space
          if (mounted && _controller != null && _controller!.value.isInitialized) {
            final size = MediaQuery.of(context).size;
            final previewW = res.imageWidth.toDouble();
            final previewH = res.imageHeight.toDouble();
            // Fit: scale theo chiều ngắn (giữ tỉ lệ). Ở đây đơn giản scale theo width.
            final sx = size.width / previewW;
            final sy = size.height / previewH;
            final Map<String, Offset> mapped = {};
            res.posePoints.forEach((k, v) {
              mapped[k] = Offset(v.x * sx, v.y * sy);
            });
            setState(() {
              _overlayData = PoseOverlayData(mapped);
              _warning = isClosed || badPosture;
              _warningText = isClosed
                  ? 'Cảnh báo: Mắt đang nhắm'
                  : (badPosture ? 'Cảnh báo: Ngồi chưa thẳng' : '');
            });
          }
        } catch (_) {}
      });
    }
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
      appBar: AppBar(title: const Text('Live Camera')),
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
}


