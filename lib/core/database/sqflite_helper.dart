import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:rickandmorty/core/models/character_model.dart';

class SqfliteHelper {
  static final SqfliteHelper instance = SqfliteHelper._init();
  static Database? _database;

  SqfliteHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('rick_and_morty.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Favorites table
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        status TEXT NOT NULL,
        species TEXT NOT NULL,
        type TEXT NOT NULL,
        gender TEXT NOT NULL,
        originName TEXT NOT NULL,
        locationName TEXT NOT NULL,
        image TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Local Edits table (Task 2.4)
    await db.execute('''
      CREATE TABLE local_edits (
        id INTEGER PRIMARY KEY,
        name TEXT,
        status TEXT,
        species TEXT,
        type TEXT,
        gender TEXT,
        originName TEXT,
        locationName TEXT,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Characters cache table (Task 2.5)
    await db.execute('''
      CREATE TABLE characters_cache (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        status TEXT NOT NULL,
        species TEXT NOT NULL,
        type TEXT NOT NULL,
        gender TEXT NOT NULL,
        originName TEXT NOT NULL,
        locationName TEXT NOT NULL,
        image TEXT NOT NULL,
        page INTEGER NOT NULL
      )
    ''');
  }

  // Character Cache Methods

  Future<void> saveCharacters(List<Character> characters, int page) async {
    final db = await instance.database;
    final batch = db.batch();

    for (var character in characters) {
      batch.insert('characters_cache', {
        'id': character.id,
        'name': character.name,
        'status': character.status,
        'species': character.species,
        'type': character.type,
        'gender': character.gender,
        'originName': character.originName,
        'locationName': character.locationName,
        'image': character.image,
        'page': page,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Character>> getCachedCharacters({int? page}) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result;
    if (page != null) {
      result = await db.query(
        'characters_cache',
        where: 'page = ?',
        whereArgs: [page],
      );
    } else {
      result = await db.query('characters_cache', orderBy: 'id ASC');
    }
    return result.map((json) => Character.fromJson(json)).toList();
  }

  Future<void> toggleFavorite(Character character) async {
    final isFav = await isFavorite(character.id);
    if (isFav) {
      await _deleteFromFavorites(character.id);
    } else {
      await _addToFavorites(character);
    }
  }

  Future<void> setFavorite(Character character, bool isFav) async {
    if (isFav) {
      await _addToFavorites(character);
    } else {
      await _deleteFromFavorites(character.id);
    }
  }

  Future<void> _addToFavorites(Character character) async {
    final db = await instance.database;
    await db.insert('favorites', {
      'id': character.id,
      'name': character.name,
      'status': character.status,
      'species': character.species,
      'type': character.type,
      'gender': character.gender,
      'originName': character.originName,
      'locationName': character.locationName,
      'image': character.image,
      'createdAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _deleteFromFavorites(int id) async {
    final db = await instance.database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Character>> getFavorites() async {
    final db = await instance.database;
    final result = await db.query('favorites', orderBy: 'createdAt DESC');

    return result.map((json) => Character.fromJson(json)).toList();
  }

  Future<bool> isFavorite(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'favorites',
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  //Local Edits Methods

  Future<void> saveLocalEdit(Map<String, dynamic> editData) async {
    final db = await instance.database;
    await db.insert('local_edits', {
      ...editData,
      'updatedAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteLocalEdit(int id) async {
    final db = await instance.database;
    await db.delete('local_edits', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<int, Map<String, dynamic>>> getAllLocalEdits() async {
    final db = await instance.database;
    final result = await db.query('local_edits');

    final Map<int, Map<String, dynamic>> edits = {};
    for (var row in result) {
      final id = row['id'] as int;
      edits[id] = Map<String, dynamic>.from(row);
    }
    return edits;
  }

  Future<Map<String, dynamic>?> getLocalEdit(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'local_edits',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<void> clearAllLocalEdits() async {
    final db = await instance.database;
    await db.delete('local_edits');
  }
}
