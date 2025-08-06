import 'package:flutter/material.dart';
import '../models/person_model.dart';
import '../helpers/database_helper.dart';
import 'dart:io';

class PersonProvider with ChangeNotifier {
  List<PersonModel> _persons = [];
  bool _isLoading = false;

  List<PersonModel> get persons => _persons;
  bool get isLoading => _isLoading;

  Future<void> loadPersons() async {
    _isLoading = true;
    notifyListeners();

    try {
      _persons = await DatabaseHelper.instance.getAllPersons();
    } catch (e) {
      debugPrint('Error loading persons: $e');
      _persons = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPerson(PersonModel person) async {
    try {
      await DatabaseHelper.instance.insertPerson(person);
      await loadPersons();
    } catch (e) {
      debugPrint('Error adding person: $e');
    }
  }

  Future<void> updatePerson(PersonModel person) async {
    try {
      await DatabaseHelper.instance.updatePerson(person);
      await loadPersons();
    } catch (e) {
      debugPrint('Error updating person: $e');
    }
  }

  Future<void> deletePerson(int id) async {
    try {
      await DatabaseHelper.instance.deletePerson(id);
      await loadPersons();
    } catch (e) {
      debugPrint('Error deleting person: $e');
    }
  }

  Future<void> deleteAllPersons() async {
    try {
      // Eliminar archivos de fotos y audios (solo en móvil)
      for (final person in _persons) {
        if (person.fotoPath != null) {
          try {
            final fotoFile = File(person.fotoPath!);
            if (await fotoFile.exists()) {
              await fotoFile.delete();
            }
          } catch (e) {
            debugPrint('Error eliminando foto: $e');
          }
        }
        if (person.audioPath != null) {
          try {
            final audioFile = File(person.audioPath!);
            if (await audioFile.exists()) {
              await audioFile.delete();
            }
          } catch (e) {
            debugPrint('Error eliminando audio: $e');
          }
        }
      }

      // Eliminar registros de la base de datos
      await DatabaseHelper.instance.deleteAllPersons();
      await loadPersons();
    } catch (e) {
      debugPrint('Error deleting all persons: $e');
    }
  }
}
