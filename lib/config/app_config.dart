// Archivo de configuración para personalizar la aplicación
// Edita estos valores para personalizar la app según tu información

class AppConfig {
  // Información del agente - CAMBIAR ESTOS VALORES
  static const String agenteNombre = 'Juan Luis Almonte';
  static const String agenteMatricula = '2021-2034';
  static const String agenteFotoPath =
      'assets/images/juan_luis_foto.png'; // Tu foto convertida a PNG

  // Información de la aplicación
  static const String appName = 'Migración RD';
  static const String appVersion = '1.0.0';

  // Colores de la aplicación
  static const int primaryColorValue = 0xFF1565C0; // Azul institucional
  static const int secondaryColorValue =
      0xFFD32F2F; // Rojo para acciones críticas

  // Textos personalizables
  static const String fraseMotivadora =
      '"Protegemos nuestras fronteras con honor y dedicación, '
      'garantizando la seguridad y el orden migratorio de la '
      'República Dominicana. Cada acción que realizamos fortalece nuestra nación."';

  static const String logoText = '🛡️ MIGRACIÓN RD 🛡️';

  // Configuración de la base de datos
  static const String databaseName = 'migracion.db';
  static const int databaseVersion = 1;

  // Configuración de archivos multimedia
  static const int maxImageQuality = 85;
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;

  // Mensajes de la aplicación
  static const String registroExitosoMessage =
      '✅ Persona registrada exitosamente';
  static const String borradoExitosoMessage =
      '✅ Todos los registros han sido eliminados';
  static const String confirmBorrarTodo =
      '¿Está seguro de que desea eliminar todos los registros?\n\n'
      'Esta acción no se puede deshacer y eliminará permanentemente '
      'todos los datos del dispositivo.';
}

// Instrucciones de personalización:
//
// 1. Para cambiar tu información personal:
//    - Edita 'agenteNombre' con tu nombre completo
//    - Edita 'agenteMatricula' con tu matrícula de estudiante
//
// 2. Para agregar tu foto:
//    - Coloca tu foto en 'assets/images/agente_foto.jpg'
//    - Asegúrate de agregar la ruta en pubspec.yaml bajo 'assets:'
//
// 3. Para cambiar el ícono de la app:
//    - El nombre debe incluir tu matrícula: "migracion_[TU_MATRÍCULA]"
//    - Reemplaza los archivos en android/app/src/main/res/mipmap-*/
//
// 4. Para cambiar colores:
//    - Modifica primaryColorValue y secondaryColorValue
//    - Los valores están en formato hexadecimal (0xFFRRGGBB)
//
// 5. Para personalizar mensajes:
//    - Edita cualquiera de los textos según tus preferencias
