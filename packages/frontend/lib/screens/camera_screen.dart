import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  int _currentCameraIndex = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndInitialize();
  }

  Future<void> _requestPermissionsAndInitialize() async {
    // Solicitar permisos
    final cameraStatus = await Permission.camera.request();

    if (cameraStatus.isGranted) {
      await _initializeCamera();
    } else {
      if (mounted) {
        setState(() {
          _errorMessage = 'Se requiere permiso de cámara';
        });
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _currentCameraIndex = 0;
        await _initControllerForIndex(_currentCameraIndex);
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _initControllerForIndex(int index) async {
    try {
      // dispose previous controller if any
      await _controller?.dispose();
      _controller = CameraController(_cameras![index], ResolutionPreset.high);
      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing controller for index $index: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    if (!mounted) return;
    setState(() {
      _isInitialized = false;
    });
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
    await _initControllerForIndex(_currentCameraIndex);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      // Tomar la foto
      final image = await _controller!.takePicture();
      debugPrint('Foto tomada: ${image.path}');

      // Obtener el directorio de documentos
      final directory = await getApplicationDocumentsDirectory();
      debugPrint('Directorio de documentos: ${directory.path}');

      // Crear la ruta para la imagen
      final imagePath = path.join(
        directory.path,
        'images',
        '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      debugPrint('Ruta de destino: $imagePath');

      // Crear el directorio si no existe
      final imageDir = Directory(path.dirname(imagePath));
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
        debugPrint('Directorio creado: ${imageDir.path}');
      }

      // Copiar la imagen al almacenamiento permanente
      final savedFile = await File(image.path).copy(imagePath);
      debugPrint('Imagen guardada exitosamente en: ${savedFile.path}');

      // Verificar que el archivo existe
      final exists = await savedFile.exists();
      debugPrint('Archivo existe: $exists');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto guardada: ${path.basename(imagePath)}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error taking picture: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await openAppSettings();
              },
              child: const Text('Abrir configuración'),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        SizedBox.expand(child: CameraPreview(_controller!)),
        Positioned(
          top: 40,
          right: 16,
          child: FloatingActionButton(
            onPressed: _switchCamera,
            mini: true,
            child: const Icon(Icons.switch_camera),
          ),
        ),
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton(
              onPressed: _takePicture,
              child: const Icon(Icons.camera_alt),
            ),
          ),
        ),
      ],
    );
  }
}
