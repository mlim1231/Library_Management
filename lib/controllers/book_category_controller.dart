import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';

// Controller untuk mengelola relasi Many-to-Many antara Buku (Books) dan Kategori (Categories)
class BookCategoryController {
  // Menambahkan relasi antara buku dan kategori ke tabel pivot (book_category)
  Future<int> addBookCategory(int bookId, int categoryId) async {
    final db = await DBHelper.initDB(); // Inisialisasi database
    return await db.insert('book_category', {
      'book_id': bookId, // ID buku
      'category_id': categoryId, // ID kategori
    });
  }

  // Menghapus semua relasi kategori untuk buku tertentu
  Future<int> deleteBookCategoryByBookId(int bookId) async {
    final db = await DBHelper.initDB(); // Inisialisasi database
    return await db.delete(
      'book_category',
      where: 'book_id = ?', // Hapus berdasarkan ID buku
      whereArgs: [bookId],
    );
  }

  // Mengambil semua buku yang terkait dengan kategori tertentu
  Future<List<Map<String, dynamic>>> getBooksForCategory(int categoryId) async {
    final db = await DBHelper.initDB(); // Inisialisasi database
    return await db.rawQuery('''
      SELECT books.id, books.title, books.author, books.published_date 
      FROM books 
      INNER JOIN book_category 
      ON books.id = book_category.book_id 
      WHERE book_category.category_id = ?
    ''', [categoryId]); // Cari buku berdasarkan ID kategori
  }

  // Mengambil semua kategori yang terkait dengan buku tertentu
  Future<List<Map<String, dynamic>>> getCategoriesForBook(int bookId) async {
    final db = await DBHelper.initDB(); // Inisialisasi database
    return await db.rawQuery('''
      SELECT categories.id, categories.name 
      FROM categories 
      INNER JOIN book_category 
      ON categories.id = book_category.category_id 
      WHERE book_category.book_id = ?
    ''', [bookId]); // Cari kategori berdasarkan ID buku
  }
}