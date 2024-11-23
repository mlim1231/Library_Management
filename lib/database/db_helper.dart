import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'library.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabel buku
        // Kolom 'member_id' di tabel Books untuk merepresentasikan peminjam buku
        await db.execute('''
          CREATE TABLE books (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            author TEXT,
            published_date TEXT,
            member_id INTEGER
          )
        ''');

        // Tabel kategori
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          )
        ''');

        // Tabel relasi buku-kategori
        await db.execute('''
          CREATE TABLE book_category (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            book_id INTEGER,
            category_id INTEGER
          )
        ''');

        // Tabel anggota
        await db.execute('''
          CREATE TABLE members (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT,
            phone TEXT
          )
        ''');
      },
    );
  }
}