import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import '../models/transaction.dart' as models;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('transactions.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 6, // Upgrade untuk tambah kolom isQris
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idTransaksi TEXT,
        idWeb TEXT,
        bankName TEXT NOT NULL,
        amount TEXT,
        detail TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isSynced INTEGER DEFAULT 0,
        retryCount INTEGER DEFAULT 0,
        lastSyncAttempt TEXT,
        isQris INTEGER DEFAULT 0
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Tambahkan kolom idTransaksi untuk database version 1
      await db.execute('ALTER TABLE transactions ADD COLUMN idTransaksi TEXT');
    }
    
    if (oldVersion < 3) {
      // Drop table lama dan buat baru dengan schema yang lebih sederhana
      await db.execute('DROP TABLE IF EXISTS transactions');
      await _createDB(db, newVersion);
    }
    
    if (oldVersion < 4) {
      // Tambahkan kolom untuk sync status
      try {
        await db.execute('ALTER TABLE transactions ADD COLUMN isSynced INTEGER DEFAULT 0');
        await db.execute('ALTER TABLE transactions ADD COLUMN retryCount INTEGER DEFAULT 0');
        await db.execute('ALTER TABLE transactions ADD COLUMN lastSyncAttempt TEXT');
      } catch (e) {
        // Jika kolom sudah ada, skip
        print('Column already exists or error: $e');
      }
    }
    
    if (oldVersion < 5) {
      // Tambahkan kolom idWeb
      try {
        await db.execute('ALTER TABLE transactions ADD COLUMN idWeb TEXT');
      } catch (e) {
        // Jika kolom sudah ada, skip
        print('Column idWeb already exists or error: $e');
      }
    }
    
    if (oldVersion < 6) {
      // Tambahkan kolom isQris
      try {
        await db.execute('ALTER TABLE transactions ADD COLUMN isQris INTEGER DEFAULT 0');
      } catch (e) {
        // Jika kolom sudah ada, skip
        print('Column isQris already exists or error: $e');
      }
    }
  }

  Future<int> insertTransaction(models.Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toJson());
  }

  // Insert atau update jika sudah ada (cek duplikat berdasarkan timestamp+detail)
  Future<int> insertOrUpdateTransaction(models.Transaction transaction) async {
    final db = await database;
    
    // Cek apakah sudah ada transaksi dengan timestamp dan detail yang sama
    final existing = await db.query(
      'transactions',
      where: 'timestamp = ? AND detail = ?',
      whereArgs: [transaction.timestamp.toIso8601String(), transaction.detail],
      limit: 1,
    );
    
    if (existing.isNotEmpty) {
      // Sudah ada, skip (tidak insert duplikat)
      return existing.first['id'] as int;
    }
    
    // Belum ada, insert baru
    return await db.insert('transactions', transaction.toJson());
  }

  // Update status sync transaksi
  Future<int> updateTransactionSyncStatus({
    required int id,
    required bool isSynced,
    int? retryCount,
  }) async {
    final db = await database;
    
    final data = {
      'isSynced': isSynced ? 1 : 0,
      'lastSyncAttempt': DateTime.now().toIso8601String(),
    };
    
    if (retryCount != null) {
      data['retryCount'] = retryCount;
    }
    
    return await db.update(
      'transactions',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get transaksi yang belum terkirim (untuk retry)
  Future<List<models.Transaction>> getUnsyncedTransactions({int maxRetries = 5}) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'isSynced = ? AND retryCount < ?',
      whereArgs: [0, maxRetries],
      orderBy: 'timestamp DESC',
    );

    return result.map((json) => models.Transaction.fromJson(json)).toList();
  }

  Future<List<models.Transaction>> getAllTransactions() async {
    final db = await database;
    final result = await db.query(
      'transactions',
      orderBy: 'timestamp DESC',
    );

    return result.map((json) => models.Transaction.fromJson(json)).toList();
  }

  Future<List<models.Transaction>> getTransactionsByBank(String bankName) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'bankName = ?',
      whereArgs: [bankName],
      orderBy: 'timestamp DESC',
    );

    return result.map((json) => models.Transaction.fromJson(json)).toList();
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllTransactions() async {
    final db = await database;
    return await db.delete('transactions');
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
