import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';

// Controller untuk mengelola operasi CRUD pada tabel Categories
class CategoryController {
  // Fungsi untuk menambahkan kategori baru ke tabel Categories
  Future<int> addCategory(String name) async {
    final db = await DBHelper.initDB(); // Inisialisasi database
    return await db.insert('categories', {
      'name': name, 
    });
  }

  // Fungsi untuk mengambil semua kategori dari tabel Categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await DBHelper.initDB(); 
    return await db.query('categories'); // Mengambil semua data dari tabel Categories
  }

  // Fungsi untuk memperbarui data kategori di tabel Categories
  Future<int> updateCategory(int id, String name) async {
    final db = await DBHelper.initDB(); 
    return await db.update(
      'categories',
      {
        'name': name, 
      },
      where: 'id = ?', 
      whereArgs: [id],
    );
  }

  // Fungsi untuk menghapus kategori dari tabel Categories berdasarkan ID
  Future<int> deleteCategory(int id) async {
    final db = await DBHelper.initDB();
    return await db.delete(
      'categories',
      where: 'id = ?', 
      whereArgs: [id],
    );
  }
}