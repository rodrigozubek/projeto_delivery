import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  static const _databaseName = 'bebidas_delivery.db';
  static const _databaseVersion = 3;

  Database? _database;

  Future<Database> get database async {
    final currentDatabase = _database;
    if (currentDatabase != null) return currentDatabase;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final databasesPath = await getDatabasesPath();
    final databasePath = path.join(databasesPath, _databaseName);

    _database = await openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bebidas (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        descricao TEXT NOT NULL,
        preco REAL NOT NULL,
        imagem_url TEXT NOT NULL,
        is_alcoolica INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE cart_items (
        bebida_id TEXT PRIMARY KEY,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (bebida_id) REFERENCES bebidas (id)
      )
    ''');

    await _createUsersTable(db);
    await _createPedidosTable(db);
    await _seedBebidas(db);
    await _seedUsers(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createUsersTable(db);
    }
    if (oldVersion < 3) {
      await _createPedidosTable(db);
      await _seedUsers(db);
    }
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createPedidosTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pedidos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_bebida TEXT NOT NULL,
        id_usuario TEXT NOT NULL,
        preco_total REAL NOT NULL,
        quantidade INTEGER NOT NULL,
        FOREIGN KEY (id_bebida) REFERENCES bebidas (id),
        FOREIGN KEY (id_usuario) REFERENCES users (id)
      )
    ''');
  }

  Future<void> _seedUsers(Database db) async {
    await db.insert('users', {
      'id': '1',
      'nome': 'Usuário Demonstração',
      'email': 'demo@example.com',
      'password_hash': 'dummy',
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> _seedBebidas(Database db) async {
    final bebidas = [
      {
        'id': '1',
        'nome': 'Cerveja Artesanal IPA',
        'descricao': '500ml - Notas citricas e amargor moderado.',
        'preco': 18.90,
        'imagem_url': 'assets/images/ipa.png',
        'is_alcoolica': 1,
      },
      {
        'id': '2',
        'nome': 'Suco de Laranja Natural',
        'descricao': '400ml - Sem adicao de acucar.',
        'preco': 9.50,
        'imagem_url': 'assets/images/suco.png',
        'is_alcoolica': 0,
      },
      {
        'id': '3',
        'nome': 'Cerveja Pilsen',
        'descricao': '350ml - Leve e refrescante.',
        'preco': 6.90,
        'imagem_url': 'assets/images/pilsen.png',
        'is_alcoolica': 1,
      },
      {
        'id': '4',
        'nome': 'Cerveja Weiss',
        'descricao': '500ml - Notas de banana e cravo.',
        'preco': 15.90,
        'imagem_url': 'assets/images/weiss.png',
        'is_alcoolica': 1,
      },
      {
        'id': '5',
        'nome': 'Cerveja Lager Premium',
        'descricao': '600ml - Sabor suave e equilibrado.',
        'preco': 12.90,
        'imagem_url': 'assets/images/lager.png',
        'is_alcoolica': 1,
      },
      {
        'id': '6',
        'nome': 'Caipirinha Tradicional',
        'descricao': 'Limao + cachaca + gelo.',
        'preco': 14.90,
        'imagem_url': 'assets/images/caipirinha.png',
        'is_alcoolica': 1,
      },
      {
        'id': '7',
        'nome': 'Mojito',
        'descricao': 'Rum, hortela e limao.',
        'preco': 16.90,
        'imagem_url': 'assets/images/mojito.png',
        'is_alcoolica': 1,
      },
      {
        'id': '8',
        'nome': 'Gin Tonica',
        'descricao': 'Gin premium + agua tonica.',
        'preco': 18.50,
        'imagem_url': 'assets/images/gin.png',
        'is_alcoolica': 1,
      },
    ];

    final batch = db.batch();
    for (final bebida in bebidas) {
      batch.insert('bebidas', bebida);
    }
    await batch.commit(noResult: true);
  }
}
