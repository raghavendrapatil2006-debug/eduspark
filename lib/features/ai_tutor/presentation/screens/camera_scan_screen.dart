import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'tutor_result_screen.dart';

import '../../../../core/services/gemini_service.dart';
import '../../../../core/constants/app_colors.dart';

class CameraScanScreen extends StatefulWidget {
  const CameraScanScreen({super.key});

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen> {
  CameraController? _controller;

  bool _loading = true;
  bool _analyzing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  String _getMimeType(String fileName) {
    final String extension = fileName.toLowerCase().split('.').last;

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      default:
        return 'image/jpeg';
    }
  }

  Future<void> _initializeCamera() async {
    try {
      if (mounted) {
        setState(() {
          _loading = true;
          _error = null;
        });
      }

      final cameras = await availableCameras();

      debugPrint('Available cameras: ${cameras.length}');

      if (cameras.isEmpty) {
        if (!mounted) return;

        setState(() {
          _error = 'No camera was found on this device.';
          _loading = false;
        });

        return;
      }

      CameraDescription selectedCamera = cameras.first;

      try {
        selectedCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
        );
      } catch (_) {}

      debugPrint('Selected camera: ${selectedCamera.name}');

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      debugPrint('Camera initialized successfully.');

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _loading = false;
        _error = null;
      });
    } on CameraException catch (e) {
      debugPrint('CameraException: ${e.code} - ${e.description}');

      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'CameraAccessDenied':
          message =
              'Camera permission was denied. Please allow camera access in browser settings.';
          break;

        case 'CameraAccessDeniedWithoutPrompt':
          message =
              'Camera permission was previously denied. Please enable camera access in browser settings.';
          break;

        case 'CameraAccessRestricted':
          message = 'Camera access is restricted on this device.';
          break;

        default:
          message = 'Camera error: ${e.description ?? e.code}';
      }

      setState(() {
        _error = message;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Unexpected camera error: $e');

      if (!mounted) return;

      setState(() {
        _error = 'Unable to access camera: $e';
        _loading = false;
      });
    }
  }

  Future<void> _analyzeImage(XFile image) async {
    if (_analyzing) return;

    try {
      debugPrint('Analyzing image: ${image.name}');

      if (mounted) {
        setState(() {
          _analyzing = true;
        });
      }

      final Uint8List bytes = await image.readAsBytes();
      final String mimeType = _getMimeType(image.name);

      debugPrint('Sending image to Gemini...');
      debugPrint('Mime type: $mimeType');
      debugPrint('Image bytes: ${bytes.length}');

      final String result = await GeminiService.instance.analyzeTextbookImage(
        imageBytes: bytes,
        mimeType: mimeType,
        language: 'English',
      );

      debugPrint('Gemini response received.');
      debugPrint(result);

      if (!mounted) return;

      setState(() {
        _analyzing = false;
      });

      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TutorResultScreen(result: result)),
      );
    } catch (e, stackTrace) {
      debugPrint('Image analysis error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _analyzing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not analyze the image: $e')),
      );
    }
  }

  Future<void> _captureImage() async {
    final controller = _controller;

    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera is unavailable. Please use Gallery.'),
        ),
      );

      return;
    }

    try {
      final XFile image = await controller.takePicture();

      debugPrint('Captured image: ${image.name}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reading your textbook page...')),
      );

      await _analyzeImage(image);
    } catch (e, stackTrace) {
      debugPrint('Capture error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not capture the page: $e')));
    }
  }

  Future<void> _pickFromGallery() async {
    if (_analyzing) return;

    try {
      final ImagePicker picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image == null) {
        return;
      }

      debugPrint('Selected image: ${image.name}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reading your textbook page...')),
      );

      await _analyzeImage(image);
    } catch (e, stackTrace) {
      debugPrint('Gallery error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not select the image: $e')));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool cameraReady =
        _controller != null && _controller!.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (cameraReady) CameraPreview(_controller!),

          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 170,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _analyzing
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),

                  const Expanded(
                    child: Text(
                      'Scan Textbook',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(width: 44),
                ],
              ),
            ),
          ),

          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.82,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
            ),
          ),

          if (_error != null)
            Positioned(
              left: 30,
              right: 30,
              top: 150,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.no_photography_rounded,
                        color: AppColors.danger,
                        size: 28,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Camera unavailable',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: _analyzing ? null : _initializeCamera,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            left: 30,
            right: 30,
            bottom: 155,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Place the textbook page inside the frame',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 35,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _analyzing ? null : _pickFromGallery,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),
                ),

                const SizedBox(width: 30),

                GestureDetector(
                  onTap: _analyzing ? null : _captureImage,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: AppColors.primary, width: 5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 25,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.background,
                      size: 30,
                    ),
                  ),
                ),

                const SizedBox(width: 82),
              ],
            ),
          ),

          if (_analyzing)
            Container(
              color: Colors.black.withValues(alpha: 0.78),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),

                      SizedBox(height: 20),

                      Text(
                        'Analyzing textbook...',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        'EduSpark AI is reading your page.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
