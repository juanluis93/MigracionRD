<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Instrucciones para Copilot - Aplicación de Migración RD

## Contexto del Proyecto
Esta es una aplicación móvil Flutter desarrollada para agentes de migración en República Dominicana. La aplicación permite registrar personas indocumentadas de forma segura y offline durante operativos de campo.

## Arquitectura y Patrones
- **Framework**: Flutter con Dart
- **Gestión de estado**: Provider pattern
- **Base de datos**: SQLite local con sqflite
- **Almacenamiento**: Archivos locales para multimedia
- **Navegación**: MaterialPageRoute

## Reglas de Desarrollo

### Seguridad y Privacidad
- SIEMPRE priorizar el almacenamiento local sobre conexiones externas
- NUNCA implementar funciones que envíen datos a servidores externos
- La función "Borrar Todo" debe eliminar TODOS los rastros de datos
- Validar permisos antes de acceder a recursos del dispositivo

### UI/UX Guidelines
- Usar colores institucionales: #1565C0 (azul primario)
- Emojis para mejorar la experiencia visual
- Material Design con elevaciones para cards
- FontAwesome para iconos específicos
- Responsive design para diferentes tamaños de pantalla

### Manejo de Datos
- Todos los campos personales son opcionales EXCEPTO la descripción
- Fecha/hora se registra automáticamente
- Multimedia (fotos/audio) se almacena en rutas locales
- Base de datos debe ser robusta contra corrupción

### Funcionalidades Críticas
- Registro de personas con multimedia opcional
- Visualización de registros con reproducción de audio
- Función de borrado total irreversible
- Sección "Acerca de" personalizable para cada agente

### Convenciones de Código
- Usar español para nombres de variables relacionadas con datos de dominio
- Comentarios en español para lógica específica del dominio
- Manejo robusto de errores con try-catch
- Loading states para operaciones asíncronas
- Validación de formularios obligatoria

### Dependencias Importantes
- sqflite: Base de datos local
- image_picker: Captura de fotos
- record: Grabación de audio
- audioplayers: Reproducción de audio
- geolocator: Ubicación GPS
- permission_handler: Gestión de permisos
- provider: Gestión de estado

### Testing y Debugging
- Probar en dispositivos reales para funciones de multimedia y ubicación
- Verificar permisos en diferentes versiones de Android
- Testear función de borrado total completamente
- Validar que la app funcione completamente offline

### Entrega y Distribución
- Generar APK firmado para distribución
- Ícono personalizado con matrícula del estudiante
- Documentación completa para instalación y uso
