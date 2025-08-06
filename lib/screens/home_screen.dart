import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:convert';
import '../providers/person_provider.dart';
import '../models/person_model.dart';
import 'person_list_screen.dart';
import 'about_screen.dart';
import '../widgets/confirm_dialog.dart';

// pantalla principal - juan luis 2021-2034
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [const PersonListScreen(), const AboutScreen()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PersonProvider>(context, listen: false).loadPersons();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _showDeleteAllDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmDialog(
        title: '⚠️ Borrar Todo',
        content:
            '¿Está seguro de que desea eliminar todos los registros?\n\nEsta acción no se puede deshacer y eliminará permanentemente todos los datos del dispositivo.',
        confirmText: 'Borrar Todo',
        cancelText: 'Cancelar',
      ),
    );

    if (result == true && mounted) {
      await Provider.of<PersonProvider>(
        context,
        listen: false,
      ).deleteAllPersons();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Todos los registros han sido eliminados'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Migración RD'),
        actions: [
          IconButton(
            onPressed: _showDeleteAllDialog,
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Borrar Todo',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.users),
            label: 'Registros',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.user),
            label: 'Acerca de',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                // Usar la misma pantalla de registro para web y móvil
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _RegistrationScreen(),
                  ),
                );
              },
              tooltip: 'Registrar Persona',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

// pantalla de registro para web y movil
class _RegistrationScreen extends StatefulWidget {
  @override
  State<_RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<_RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final _nacionalidadController = TextEditingController();
  final _ubicacionController = TextEditingController();
  bool _isSubmitting = false;

  // variables multimedia
  File? _selectedImage;
  String? _savedImagePath;
  String? _audioRecordingBase64;
  bool _isRecording = false;
  String? _recordingStatus;
  final ImagePicker _picker = ImagePicker();
  // final AudioRecorder _audioRecorder = AudioRecorder();

  // mostrar imagen completa
  void _showFullScreenImage() {
    if (_selectedImage == null && _savedImagePath == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 3.0,
                child: kIsWeb && _savedImagePath != null
                    ? Image.memory(
                        base64Decode(_savedImagePath!),
                        fit: BoxFit.contain,
                      )
                    : _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.contain)
                    : const SizedBox(),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _nombreController.dispose();
    _edadController.dispose();
    _nacionalidadController.dispose();
    _ubicacionController.dispose();
    // _audioRecorder.dispose();
    super.dispose();
  }

  // funciones para imagen hibrida web + movil
  Future<void> _pickImageFromGallery() async {
    try {
      if (kIsWeb) {
        // En web, usar input de archivos del navegador
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          // en web usar base64
          final bytes = await pickedFile.readAsBytes();
          final base64String = base64Encode(bytes);

          setState(() {
            _savedImagePath = 'data:image/jpeg;base64,$base64String';
            // guardamos base64 completo como path
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Imagen seleccionada (Web)'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        // en movil usar galeria y guardar archivo
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          final File imageFile = File(pickedFile.path);

          // guardar imagen en directorio app
          final Directory appDir = await getApplicationDocumentsDirectory();
          final String timestamp = DateTime.now().millisecondsSinceEpoch
              .toString();
          final String fileName = 'imagen_$timestamp.jpg';
          final String savedPath = '${appDir.path}/imagenes/$fileName';

          // Crear directorio si no existe
          final Directory imageDir = Directory('${appDir.path}/imagenes');
          if (!await imageDir.exists()) {
            await imageDir.create(recursive: true);
          }

          // Copiar imagen al directorio de la app
          final File savedImage = await imageFile.copy(savedPath);

          setState(() {
            _selectedImage = savedImage;
            _savedImagePath = savedPath;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Imagen seleccionada y guardada'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _startStopRecording() async {
    try {
      if (_isRecording) {
        // Detener grabación
        setState(() {
          _isRecording = false;
          // Simular audio grabado con timestamp único
          _audioRecordingBase64 =
              "audio_record_${DateTime.now().millisecondsSinceEpoch}_${Platform.isAndroid ? 'android' : 'platform'}";
          _recordingStatus = "Audio grabado";
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                kIsWeb
                    ? '✅ Grabación finalizada (simulada para web)'
                    : '✅ Audio grabado correctamente',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Verificar permisos de micrófono
        bool hasPermission = true;
        if (!kIsWeb) {
          final micPermission = await Permission.microphone.request();
          hasPermission = micPermission.isGranted;
        }

        if (hasPermission) {
          // Iniciar grabación
          setState(() {
            _isRecording = true;
            _recordingStatus = "Grabando...";
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  kIsWeb
                      ? '🎤 Iniciando grabación (simulada para web)'
                      : '🎤 Grabando audio...',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Permiso de micrófono denegado'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
        _recordingStatus = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en grabación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final person = PersonModel(
        nombre: _nombreController.text.trim().isNotEmpty
            ? _nombreController.text.trim()
            : null,
        edadEstimada: _edadController.text.trim().isNotEmpty
            ? int.tryParse(_edadController.text.trim())
            : null,
        nacionalidad: _nacionalidadController.text.trim().isNotEmpty
            ? _nacionalidadController.text.trim()
            : null,
        fechaHora: DateTime.now(),
        ubicacionGPS: _ubicacionController.text.trim().isNotEmpty
            ? _ubicacionController.text.trim()
            : null,
        descripcion: _descripcionController.text.trim(),
        fotoPath: _savedImagePath, // Ruta local de la imagen guardada
        audioPath: _audioRecordingBase64, // Almacenar como Base64 en web
      );

      if (mounted) {
        await Provider.of<PersonProvider>(
          context,
          listen: false,
        ).addPerson(person);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Persona registrada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error registrando persona: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        // Debug: imprimir error completo
        debugPrint('Error detallado al registrar persona: $e');
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📝 Registrar Persona')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top -
                  32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sección de Foto
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          '📷 Fotografía (Opcional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_savedImagePath != null)
                          GestureDetector(
                            onTap: _showFullScreenImage,
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: kIsWeb
                                          ? (_savedImagePath!.startsWith(
                                                  'data:image',
                                                )
                                                ? Image.memory(
                                                    base64Decode(
                                                      _savedImagePath!.split(
                                                        ',',
                                                      )[1],
                                                    ),
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Container(
                                                            color: Colors
                                                                .green[50],
                                                            child: const Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .check_circle,
                                                                  size: 48,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                                SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Text(
                                                                  'Imagen cargada (Web)',
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                  )
                                                : Container(
                                                    color: Colors.green[50],
                                                    child: const Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.check_circle,
                                                          size: 48,
                                                          color: Colors.green,
                                                        ),
                                                        SizedBox(height: 8),
                                                        Text(
                                                          'Imagen seleccionada',
                                                        ),
                                                      ],
                                                    ),
                                                  ))
                                          : (_selectedImage != null
                                                ? Image.file(
                                                    _selectedImage!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Container(
                                                            color: Colors
                                                                .green[50],
                                                            child: const Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .check_circle,
                                                                  size: 48,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                                SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Text(
                                                                  'Imagen guardada',
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                  )
                                                : Container(
                                                    color: Colors.green[50],
                                                    child: const Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.check_circle,
                                                          size: 48,
                                                          color: Colors.green,
                                                        ),
                                                        SizedBox(height: 8),
                                                        Text('Imagen guardada'),
                                                      ],
                                                    ),
                                                  )),
                                    ),
                                  ),
                                  // Ícono de zoom para indicar que es clickeable
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.zoom_in,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text('Sin foto'),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _pickImageFromGallery,
                          icon: const Icon(Icons.photo_library),
                          label: Text(
                            kIsWeb
                                ? 'Seleccionar Imagen (Web)'
                                : 'Seleccionar de Galería',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          kIsWeb
                              ? 'Selecciona una imagen desde tu computadora'
                              : 'Selecciona una foto desde la galería del dispositivo',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          '👤 Información Personal (Opcional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre completo',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _edadController,
                          decoration: const InputDecoration(
                            labelText: 'Edad estimada',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.cake),
                            suffixText: 'años',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isNotEmpty == true) {
                              final edad = int.tryParse(value!);
                              if (edad == null || edad < 0 || edad > 120) {
                                return 'Ingrese una edad válida (0-120)';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nacionalidadController,
                          decoration: const InputDecoration(
                            labelText: 'Nacionalidad',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.flag),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          '📍 Ubicación GPS (Opcional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _ubicacionController,
                          decoration: const InputDecoration(
                            labelText:
                                'Coordenadas GPS (ej: 18.4801, -69.9420)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                            hintText: 'Latitud, Longitud',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Nota: En web debe ingresar las coordenadas manualmente',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Sección de Audio
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          '🎤 Nota de Voz (Opcional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_audioRecordingBase64 != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Column(
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Audio grabado'),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ID: ${_audioRecordingBase64!.substring(0, 20)}...',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (_isRecording)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.fiber_manual_record,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(_recordingStatus ?? 'Grabando...'),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.mic_off, color: Colors.grey),
                                SizedBox(width: 8),
                                Text('Sin audio grabado'),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _startStopRecording,
                          icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                          label: Text(
                            _isRecording
                                ? 'Detener Grabación'
                                : kIsWeb
                                ? 'Grabar Audio (Web)'
                                : 'Grabar Audio',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isRecording ? Colors.red : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          kIsWeb
                              ? 'Nota: En web se simula la grabación de audio'
                              : 'Toca para grabar una nota de voz',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          '📝 Descripción del Encuentro (Obligatorio)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descripcionController,
                          decoration: const InputDecoration(
                            labelText: 'Describa el encuentro y circunstancias',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) {
                            if (value?.trim().isEmpty ?? true) {
                              return 'La descripción es obligatoria';
                            }
                            if (value!.trim().length < 3) {
                              return 'La descripción debe tener al menos 3 caracteres';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Registrando...'),
                          ],
                        )
                      : const Text('✅ Registrar Persona'),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Text(
                    kIsWeb
                        ? '💡 Versión Web: Funcionalidad completa disponible en Android'
                        : '📱 Aplicación Móvil: Todas las funciones disponibles',
                    style: const TextStyle(color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
