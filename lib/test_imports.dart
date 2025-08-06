// Archivo de verificación para probar imports
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_person_screen.dart';
import 'screens/person_list_screen.dart';
import 'screens/person_detail_screen.dart';
import 'screens/about_screen.dart';
import 'models/person_model.dart';
import 'providers/person_provider.dart';
import 'helpers/database_helper.dart';
import 'widgets/confirm_dialog.dart';
import 'config/app_config.dart';

void main() {
  // Este archivo es solo para verificar que todos los imports funcionan
  print('Todos los imports están funcionando correctamente');

  // Verificar que las clases existen
  const HomeScreen();
  const AddPersonScreen();
  const PersonListScreen();
  const AboutScreen();

  print('Todas las clases principales están definidas');
}
