import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/person_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Lista en memoria para web
  static List<PersonModel> _memoryStorage = [];
  static int _nextId = 1;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite no está soportado en web');
    }
    if (_database != null) return _database!;
    _database = await _initDB('migracion.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';
    const integerType = 'INTEGER';

    await db.execute('''
CREATE TABLE personas (
  id $idType,
  nombre $textType,
  edad_estimada $integerType,
  nacionalidad $textType,
  fecha_hora $integerType NOT NULL,
  ubicacion_gps $textType,
  descripcion $textType NOT NULL,
  foto_path $textType,
  audio_path $textType
)
''');
  }

  Future<int> insertPerson(PersonModel person) async {
    if (kIsWeb) {
      // Almacenamiento en memoria para web
      final newPerson = person.copyWith(id: _nextId++);
      _memoryStorage.add(newPerson);
      return newPerson.id!;
    } else {
      // SQLite para móvil
      final db = await instance.database;
      return await db.insert('personas', person.toMap());
    }
  }

  Future<List<PersonModel>> getAllPersons() async {
    if (kIsWeb) {
      // Retornar lista en memoria ordenada por fecha
      final sortedList = List<PersonModel>.from(_memoryStorage);
      sortedList.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
      return sortedList;
    } else {
      // SQLite para móvil
      final db = await instance.database;
      final result = await db.query('personas', orderBy: 'fecha_hora DESC');
      return result.map((map) => PersonModel.fromMap(map)).toList();
    }
  }

  Future<PersonModel?> getPerson(int id) async {
    if (kIsWeb) {
      // Buscar en memoria
      try {
        return _memoryStorage.firstWhere((person) => person.id == id);
      } catch (e) {
        return null;
      }
    } else {
      // SQLite para móvil
      final db = await instance.database;
      final result = await db.query(
        'personas',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        return PersonModel.fromMap(result.first);
      }
      return null;
    }
  }

  Future<int> updatePerson(PersonModel person) async {
    if (kIsWeb) {
      // Actualizar en memoria
      final index = _memoryStorage.indexWhere((p) => p.id == person.id);
      if (index != -1) {
        _memoryStorage[index] = person;
        return 1; // Éxito
      }
      return 0; // No encontrado
    } else {
      // SQLite para móvil
      final db = await instance.database;
      return await db.update(
        'personas',
        person.toMap(),
        where: 'id = ?',
        whereArgs: [person.id],
      );
    }
  }

  Future<int> deletePerson(int id) async {
    if (kIsWeb) {
      // Eliminar de memoria
      final index = _memoryStorage.indexWhere((p) => p.id == id);
      if (index != -1) {
        _memoryStorage.removeAt(index);
        return 1; // Éxito
      }
      return 0; // No encontrado
    } else {
      // SQLite para móvil
      final db = await instance.database;
      return await db.delete('personas', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<int> deleteAllPersons() async {
    if (kIsWeb) {
      // Limpiar memoria
      final count = _memoryStorage.length;
      _memoryStorage.clear();
      _nextId = 1; // Reiniciar contador
      return count;
    } else {
      // SQLite para móvil
      final db = await instance.database;
      return await db.delete('personas');
    }
  }

  Future close() async {
    if (kIsWeb) {
      // En web no hay base de datos que cerrar
      return;
    } else {
      // SQLite para móvil
      final db = await instance.database;
      db.close();
    }
  }
}
