import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/offlineORM.db';
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tbCliente (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        logradouro TEXT,
        numero TEXT,
        complemento TEXT,
        bairro TEXT,
        cidade TEXT,
        uf TEXT,
        isSelected INTEGER DEFAULT 0,
        isDeleted INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE tbProduto (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        descricao TEXT,
        precoCusto REAL,
        foto TEXT,
        isSelected INTEGER DEFAULT 0,
        isDeleted INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE tbPedido (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomeCliente TEXT,
        dataHora TEXT,
        valorTotal REAL,
        tbClienteId INTEGER,
        isSelected INTEGER DEFAULT 0,
        isDeleted INTEGER DEFAULT 0,
        FOREIGN KEY (tbClienteId) REFERENCES tbCliente(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE tbItensPedido (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        descricao TEXT,
        precoCusto REAL,
        quantidade INTEGER,
        tbPedidoId INTEGER,
        isSelected INTEGER DEFAULT 0,
        isDeleted INTEGER DEFAULT 0,
        FOREIGN KEY (tbPedidoId) REFERENCES tbPedido(id) ON DELETE CASCADE
      )
    ''');
  }
}
