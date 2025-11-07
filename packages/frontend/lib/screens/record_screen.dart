import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  FlutterSoundRecorder? _audioRecorder;
  final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();

  bool _isRecorderInitialized = false;
  bool _isRecording = false;
  bool _isPaused = false;
  List<File> _recordings = [];
  String? _currentlyPlayingPath;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  String? _currentRecordingPath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _loadRecordings();
    _setupAudioPlayer();
  }

  Future<void> _initRecorder() async {
    _audioRecorder = FlutterSoundRecorder();
    await _audioRecorder!.openRecorder();
    setState(() {
      _isRecorderInitialized = true;
    });
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == ap.PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentlyPlayingPath = null;
          _currentPosition = Duration.zero;
        });
      }
    });
  }

  Future<void> _loadRecordings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordingsPath = path.join(directory.path, 'recordings');
      final recordingsDir = Directory(recordingsPath);

      if (await recordingsDir.exists()) {
        final files = recordingsDir.listSync();
        final audioFiles = files
            .whereType<File>()
            .where(
              (file) =>
                  file.path.endsWith('.aac') ||
                  file.path.endsWith('.mp3') ||
                  file.path.endsWith('.wav'),
            )
            .toList();

        // Ordenar por fecha de modificación (más reciente primero)
        audioFiles.sort(
          (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
        );

        if (mounted) {
          setState(() {
            _recordings = audioFiles;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading recordings: $e');
    }
  }

  Future<void> _startRecording() async {
    if (!_isRecorderInitialized) return;

    try {
      // Solicitar permisos
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se requiere permiso de micrófono'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Crear directorio de grabaciones
      final directory = await getApplicationDocumentsDirectory();
      final recordingsPath = path.join(directory.path, 'recordings');
      final recordingsDir = Directory(recordingsPath);
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      // Crear ruta para la nueva grabación
      final filePath = path.join(
        recordingsPath,
        'recording_${DateTime.now().millisecondsSinceEpoch}.aac',
      );

      _currentRecordingPath = filePath;

      // Iniciar grabación
      await _audioRecorder!.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
      );

      if (mounted) {
        setState(() {
          _isRecording = true;
          _isPaused = false;
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar grabación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pauseRecording() async {
    if (!_isRecorderInitialized) return;

    try {
      await _audioRecorder!.pauseRecorder();
      if (mounted) {
        setState(() {
          _isPaused = true;
        });
      }
    } catch (e) {
      debugPrint('Error pausing recording: $e');
    }
  }

  Future<void> _resumeRecording() async {
    if (!_isRecorderInitialized) return;

    try {
      await _audioRecorder!.resumeRecorder();
      if (mounted) {
        setState(() {
          _isPaused = false;
        });
      }
    } catch (e) {
      debugPrint('Error resuming recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecorderInitialized) return;

    try {
      await _audioRecorder!.stopRecorder();

      if (mounted) {
        setState(() {
          _isRecording = false;
          _isPaused = false;
        });
      }

      if (_currentRecordingPath != null) {
        debugPrint('Grabación guardada en: $_currentRecordingPath');
        await _loadRecordings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Grabación guardada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar grabación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _playRecording(String filePath) async {
    try {
      if (_currentlyPlayingPath == filePath && _isPlaying) {
        await _audioPlayer.pause();
      } else if (_currentlyPlayingPath == filePath && !_isPlaying) {
        await _audioPlayer.resume();
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.play(ap.DeviceFileSource(filePath));
        setState(() {
          _currentlyPlayingPath = filePath;
        });
      }
    } catch (e) {
      debugPrint('Error playing recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reproducir audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteRecording(File file) async {
    try {
      if (_currentlyPlayingPath == file.path) {
        await _audioPlayer.stop();
        setState(() {
          _currentlyPlayingPath = null;
          _isPlaying = false;
        });
      }

      await file.delete();
      await _loadRecordings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grabación eliminada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar grabación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _getRecordingName(File file) {
    final fileName = path.basename(file.path);
    final timestamp = fileName
        .replaceAll('recording_', '')
        .replaceAll('.aac', '')
        .replaceAll('.mp3', '')
        .replaceAll('.wav', '');
    try {
      final milliseconds = int.parse(timestamp);
      final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return fileName;
    }
  }

  @override
  void dispose() {
    _audioRecorder?.closeRecorder();
    _audioRecorder = null;
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Sección de grabación
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Column(
            children: [
              Icon(
                _isRecording ? Icons.mic : Icons.mic_none,
                size: 80,
                color: _isRecording ? Colors.red : theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                _isRecording
                    ? (_isPaused ? 'Grabación pausada' : 'Grabando...')
                    : 'Toca el botón para grabar',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isRecording) ...[
                    FloatingActionButton(
                      heroTag: 'pause',
                      onPressed: _isPaused ? _resumeRecording : _pauseRecording,
                      child: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                    ),
                    const SizedBox(width: 16),
                    FloatingActionButton(
                      heroTag: 'stop',
                      backgroundColor: Colors.red,
                      onPressed: _stopRecording,
                      child: const Icon(Icons.stop),
                    ),
                  ] else
                    FloatingActionButton.large(
                      heroTag: 'record',
                      onPressed: _isRecorderInitialized
                          ? _startRecording
                          : null,
                      child: const Icon(Icons.fiber_manual_record, size: 32),
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Lista de grabaciones
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(Icons.history, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Grabaciones (${_recordings.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Expanded(
          child: _recordings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.audiotrack, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay grabaciones',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Graba audio para verlo aquí',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _recordings.length,
                  itemBuilder: (context, index) {
                    final recording = _recordings[index];
                    final isPlaying =
                        _currentlyPlayingPath == recording.path && _isPlaying;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPlaying
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primaryContainer,
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: isPlaying
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(_getRecordingName(recording)),
                        subtitle: _currentlyPlayingPath == recording.path
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: _totalDuration.inMilliseconds > 0
                                        ? _currentPosition.inMilliseconds /
                                              _totalDuration.inMilliseconds
                                        : 0,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              )
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteDialog(recording),
                        ),
                        onTap: () => _playRecording(recording.path),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showDeleteDialog(File recording) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar grabación'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta grabación?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteRecording(recording);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
