import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  static const _databaseName = 'bebidas_delivery.db';
  static const _databaseVersion = 7;

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
    await _createPedidosTables(db);
    await _seedBebidas(db);
    await _seedUsers(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createUsersTable(db);
    }
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS pedidos');
      await _createPedidosTables(db);
    }
    if (oldVersion < 4) {
      // Re-criando tabelas para a nova estrutura de agrupamento
      await db.execute('DROP TABLE IF EXISTS pedidos');
      await db.execute('DROP TABLE IF EXISTS pedido_items');
      await _createPedidosTables(db);
    }
    if (oldVersion < 5) {
      await db.execute('DROP TABLE IF EXISTS pedido_items');
      await db.execute('DROP TABLE IF EXISTS pedidos');
      await db.execute('DROP TABLE IF EXISTS users');
      await _createUsersTable(db);
      await _createPedidosTables(db);
      await _seedUsers(db);
    }
    if (oldVersion == 5) {
      await db.execute(
        "ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT 'comprador'",
      );
      await _seedUsers(db);
    }
    if (oldVersion < 7) {
      await _seedUsers(db);
    }
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'comprador',
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createPedidosTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pedidos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_usuario INTEGER NOT NULL,
        preco_total REAL NOT NULL,
        data_pedido TEXT NOT NULL,
        FOREIGN KEY (id_usuario) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS pedido_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_pedido INTEGER NOT NULL,
        id_bebida TEXT NOT NULL,
        quantidade INTEGER NOT NULL,
        preco_unitario REAL NOT NULL,
        FOREIGN KEY (id_pedido) REFERENCES pedidos (id),
        FOREIGN KEY (id_bebida) REFERENCES bebidas (id)
      )
    ''');
  }

  Future<void> _seedUsers(Database db) async {
    await _upsertSeedUser(
      db,
      id: 1,
      nome: 'Usuario',
      email: 'usuario@bebidas.com',
      role: 'comprador',
    );

    await _upsertSeedUser(
      db,
      id: 2,
      nome: 'Administrador',
      email: 'admin@bebidas.com',
      role: 'admin',
    );
  }

  Future<void> _upsertSeedUser(
    Database db, {
    required int id,
    required String nome,
    required String email,
    required String role,
  }) async {
    const passwordHash =
        '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92';
    final values = {
      'nome': nome,
      'email': email,
      'password_hash': passwordHash,
      'role': role,
    };

    final updated = await db.update(
      'users',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (updated > 0) return;

    await db.insert('users', {
      'id': id,
      ...values,
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
