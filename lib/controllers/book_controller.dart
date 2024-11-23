import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';

// Controller untuk mengelola operasi CRUD pada tabel Books
class BookController {
  // Fungsi untuk menambahkan buku baru ke tabel Books
  Future<int> addBook(String title, String author, String publishedDate) async {
    final db = await DBHelper.initDB(); // Inisialisasi database
    return await db.insert('books', {
      'title': title, // Judul buku
      'author': author, // Penulis buku
      'published_date': publishedDate, // Tanggal publikasi buku
    });
  }

  // Fungsi untuk mengambil semua buku dari tabel Books
  Future<List<Map<String, dynamic>>> getBooks() async {
    final db = await DBHelper.initDB(); // Inisialisasi database
    return await db.query('books'); // Mengambil semua data dari tabel Books
  }

  // Fungsi untuk memperbarui data buku di tabel Books
  Future<int> updateBook(int id, String title, String author, String publishedDate) async {
    final db = await DBHelper.initDB(); // Inisialisasi database
    return await db.update(
      'books',
      {
        'title': title, // Perbarui judul buku
        'author': author, // Perbarui penulis buku
        'published_date': publishedDate, // Perbarui tanggal publikasi buku
      },
      where: 'id = ?', 
      whereArgs: [id],
    );
  }

  // Fungsi untuk menghapus buku dari tabel Books berdasarkan ID
  Future<int> deleteBook(int id) async {
    final db = await DBHelper.initDB(); 
    return await db.delete(
      'books',
      where: 'id = ?', 
      whereArgs: [id],
    );
  }

  // Fungsi untuk mencatat peminjaman buku oleh anggota tertentu
  Future<int> borrowBook(int bookId, int memberId) async {
    final db = await DBHelper.initDB(); // Inisialisasi database
    return await db.update(
      'books',
      {'member_id': memberId}, 
      where: 'id = ?', 
      whereArgs: [bookId],
    );
  }

  // Fungsi untuk mencatat pengembalian buku
  Future<int> returnBook(int bookId) async {
    final db = await DBHelper.initDB(); 
    return await db.update(
      'books',
      {'member_id': null}, 
      where: 'id = ?', 
      whereArgs: [bookId],
    );
  }
}