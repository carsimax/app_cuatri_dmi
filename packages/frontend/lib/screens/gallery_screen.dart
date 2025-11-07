import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with AutomaticKeepAliveClientMixin {
  List<File> _images = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar imágenes cada vez que la pantalla se hace visible
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = path.join(directory.path, 'images');
      final imageDir = Directory(imagePath);

      debugPrint('Buscando imágenes en: $imagePath');

      if (await imageDir.exists()) {
        final files = imageDir.listSync();
        debugPrint('Archivos encontrados: ${files.length}');

        final imageFiles = files
            .whereType<File>()
            .where(
              (file) =>
                  file.path.endsWith('.jpg') || file.path.endsWith('.png'),
            )
            .toList();

        debugPrint('Imágenes válidas: ${imageFiles.length}');

        // Ordenar por fecha de modificación (más reciente primero)
        imageFiles.sort(
          (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
        );

        if (mounted) {
          setState(() {
            _images = imageFiles;
            _isLoading = false;
          });
        }
      } else {
        debugPrint('El directorio no existe: $imagePath');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading images: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteImage(File image) async {
    try {
      await image.delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagen eliminada'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadImages(); // Recargar la galería
    } catch (e) {
      debugPrint('Error deleting image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageDialog(File image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(image),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteImage(image);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'Eliminar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Cerrar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay imágenes',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Toma fotos con la cámara para verlas aquí',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadImages,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadImages,
      child: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          final image = _images[index];
          return GestureDetector(
            onTap: () => _showImageDialog(image),
            child: Hero(
              tag: image.path,
              child: Image.file(image, fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }
}
