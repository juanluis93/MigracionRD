import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'dart:convert';
import '../models/person_model.dart';

class PersonDetailScreen extends StatefulWidget {
  final PersonModel person;

  const PersonDetailScreen({super.key, required this.person});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildImageWidget() {
    if (kIsWeb) {
      // En web, verificar si es Base64
      if (widget.person.fotoPath!.startsWith('data:image')) {
        try {
          final bytes = base64Decode(widget.person.fotoPath!.split(',')[1]);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 48, color: Colors.red),
                    SizedBox(height: 8),
                    Text('Error cargando imagen (Web)'),
                  ],
                ),
              );
            },
          );
        } catch (e) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('Imagen guardada'),
              ],
            ),
          );
        }
      } else {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Imagen guardada'),
            ],
          ),
        );
      }
    } else {
      // En móvil, usar Image.file
      return Image.file(
        File(widget.person.fotoPath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 48, color: Colors.red),
                SizedBox(height: 8),
                Text('Error cargando imagen'),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> _playAudio() async {
    if (widget.person.audioPath == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
        setState(() {
          _isPlaying = false;
        });
      } else {
        await _audioPlayer.play(DeviceFileSource(widget.person.audioPath!));
        setState(() {
          _isPlaying = true;
        });

        _audioPlayer.onPlayerComplete.listen((_) {
          setState(() {
            _isPlaying = false;
          });
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reproduciendo audio: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.person.nombre?.isNotEmpty == true
              ? widget.person.nombre!
              : 'Registro sin nombre',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Foto
            if (widget.person.fotoPath != null) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        '📷 Fotografía',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 300,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildImageWidget(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Información personal
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '👤 Información Personal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.person,
                      label: 'Nombre',
                      value: widget.person.nombre?.isNotEmpty == true
                          ? widget.person.nombre!
                          : 'No especificado',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.cake,
                      label: 'Edad estimada',
                      value: widget.person.edadEstimada != null
                          ? '${widget.person.edadEstimada} años'
                          : 'No especificada',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: FontAwesomeIcons.flag,
                      label: 'Nacionalidad',
                      value: widget.person.nacionalidad?.isNotEmpty == true
                          ? widget.person.nacionalidad!
                          : 'No especificada',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Información del registro
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📋 Información del Registro',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.access_time,
                      label: 'Fecha y hora',
                      value: dateFormat.format(widget.person.fechaHora),
                    ),
                    if (widget.person.ubicacionGPS != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: Icons.location_on,
                        label: 'Ubicación GPS',
                        value: widget.person.ubicacionGPS!,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Descripción
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📝 Descripción del Encuentro',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        widget.person.descripcion,
                        style: const TextStyle(fontSize: 16, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Audio
            if (widget.person.audioPath != null) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🎤 Nota de Voz',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _playAudio,
                          icon: Icon(
                            _isPlaying ? Icons.stop : Icons.play_arrow,
                          ),
                          label: Text(_isPlaying ? 'Detener' : 'Reproducir'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isPlaying ? Colors.red : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
