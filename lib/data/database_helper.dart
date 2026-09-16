import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/country.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  
  // Static list for web support (since sqflite doesn't work on web natively)
  List<Country>? _webCountries;

  DatabaseHelper._init();

  final List<Map<String, dynamic>> _initialCountries = [
    {'id': 1, 'country_name': 'Brasil', 'city_name': 'Brasília', 'timezone': 'America/Sao_Paulo', 'utc_offset': 'UTC-3', 'flag_code': 'BR', 'favorite': 0},
    {'id': 2, 'country_name': 'Estados Unidos', 'city_name': 'New York', 'timezone': 'America/New_York', 'utc_offset': 'UTC-5', 'flag_code': 'US', 'favorite': 0},
    {'id': 3, 'country_name': 'Canadá', 'city_name': 'Toronto', 'timezone': 'America/Toronto', 'utc_offset': 'UTC-5', 'flag_code': 'CA', 'favorite': 0},
    {'id': 4, 'country_name': 'Reino Unido', 'city_name': 'Londres', 'timezone': 'Europe/London', 'utc_offset': 'UTC+0', 'flag_code': 'GB', 'favorite': 0},
    {'id': 5, 'country_name': 'França', 'city_name': 'Paris', 'timezone': 'Europe/Paris', 'utc_offset': 'UTC+1', 'flag_code': 'FR', 'favorite': 0},
    {'id': 6, 'country_name': 'Alemanha', 'city_name': 'Berlim', 'timezone': 'Europe/Berlin', 'utc_offset': 'UTC+1', 'flag_code': 'DE', 'favorite': 0},
    {'id': 7, 'country_name': 'Espanha', 'city_name': 'Madrid', 'timezone': 'Europe/Madrid', 'utc_offset': 'UTC+1', 'flag_code': 'ES', 'favorite': 0},
    {'id': 8, 'country_name': 'Itália', 'city_name': 'Roma', 'timezone': 'Europe/Rome', 'utc_offset': 'UTC+1', 'flag_code': 'IT', 'favorite': 0},
    {'id': 9, 'country_name': 'Portugal', 'city_name': 'Lisboa', 'timezone': 'Europe/Lisbon', 'utc_offset': 'UTC+0', 'flag_code': 'PT', 'favorite': 0},
    {'id': 10, 'country_name': 'Rússia', 'city_name': 'Moscou', 'timezone': 'Europe/Moscow', 'utc_offset': 'UTC+3', 'flag_code': 'RU', 'favorite': 0},
    {'id': 11, 'country_name': 'Japão', 'city_name': 'Tóquio', 'timezone': 'Asia/Tokyo', 'utc_offset': 'UTC+9', 'flag_code': 'JP', 'favorite': 0},
    {'id': 12, 'country_name': 'China', 'city_name': 'Pequim', 'timezone': 'Asia/Shanghai', 'utc_offset': 'UTC+8', 'flag_code': 'CN', 'favorite': 0},
    {'id': 13, 'country_name': 'Índia', 'city_name': 'Nova Delhi', 'timezone': 'Asia/Kolkata', 'utc_offset': 'UTC+5:30', 'flag_code': 'IN', 'favorite': 0},
    {'id': 14, 'country_name': 'Coreia do Sul', 'city_name': 'Seul', 'timezone': 'Asia/Seoul', 'utc_offset': 'UTC+9', 'flag_code': 'KR', 'favorite': 0},
    {'id': 15, 'country_name': 'Singapura', 'city_name': 'Singapura', 'timezone': 'Asia/Singapore', 'utc_offset': 'UTC+8', 'flag_code': 'SG', 'favorite': 0},
    {'id': 16, 'country_name': 'Emirados Árabes', 'city_name': 'Dubai', 'timezone': 'Asia/Dubai', 'utc_offset': 'UTC+4', 'flag_code': 'AE', 'favorite': 0},
    {'id': 17, 'country_name': 'Austrália', 'city_name': 'Sydney', 'timezone': 'Australia/Sydney', 'utc_offset': 'UTC+10', 'flag_code': 'AU', 'favorite': 0},
    {'id': 18, 'country_name': 'África do Sul', 'city_name': 'Cidade do Cabo', 'timezone': 'Africa/Johannesburg', 'utc_offset': 'UTC+2', 'flag_code': 'ZA', 'favorite': 0},
    {'id': 19, 'country_name': 'México', 'city_name': 'Cidade do México', 'timezone': 'America/Mexico_City', 'utc_offset': 'UTC-6', 'flag_code': 'MX', 'favorite': 0},
    {'id': 20, 'country_name': 'Argentina', 'city_name': 'Buenos Aires', 'timezone': 'America/Argentina/Buenos_Aires', 'utc_offset': 'UTC-3', 'flag_code': 'AR', 'favorite': 0},
  ];

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('timezones.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';

    await db.execute('''
CREATE TABLE countries (
  id $idType,
  country_name $textType,
  city_name $textType,
  timezone $textType,
  utc_offset $textType,
  flag_code $textType,
  favorite $boolType
)
''');

    for (final country in _initialCountries) {
      await db.insert('countries', country);
    }
  }

  Future<Country> create(Country country) async {
    if (kIsWeb) return country; // No-op on web
    final db = await instance.database;
    final id = await db.insert('countries', country.toMap());
    return country.copyWith(id: id);
  }

  Future<Country?> readCountry(int id) async {
    if (kIsWeb) {
      if (_webCountries == null) {
        _webCountries = _initialCountries.map((e) => Country.fromMap(e)).toList();
      }
      return _webCountries!.firstWhere((c) => c.id == id);
    }
    
    final db = await instance.database;
    final maps = await db.query(
      'countries',
      columns: ['id', 'country_name', 'city_name', 'timezone', 'utc_offset', 'flag_code', 'favorite'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Country.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Country>> readAllCountries() async {
    if (kIsWeb) {
      if (_webCountries == null) {
        _webCountries = _initialCountries.map((e) => Country.fromMap(e)).toList();
      }
      return _webCountries!;
    }
    
    final db = await instance.database;
    const orderBy = 'country_name ASC';
    final result = await db.query('countries', orderBy: orderBy);
    return result.map((json) => Country.fromMap(json)).toList();
  }
}
