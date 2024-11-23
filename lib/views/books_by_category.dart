import 'package:flutter/material.dart';
import '../controllers/book_category_controller.dart';

// Halaman untuk menampilkan daftar buku berdasarkan kategori tertentu
class BooksByCategory extends StatelessWidget {
  // ID kategori yang dipilih
  final int categoryId;
  // Nama kategori yang dipilih
  final String categoryName;

  // Constructor untuk menerima ID dan nama kategori
  const BooksByCategory({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar dengan judul kategori
      appBar: AppBar(title: Text('Books in $categoryName')),

      // Menggunakan FutureBuilder untuk memuat data buku
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // Mengambil data buku berdasarkan kategori
        future: BookCategoryController().getBooksForCategory(categoryId),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Menangani error jika terjadi kesalahan saat load data
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Mendapatkan data buku dari snapshot
          final books = snapshot.data ?? [];
          // Jika tidak ada buku dalam kategori, tampilkan pesan
          if (books.isEmpty) {
            return Center(child: Text('No books found in this category.'));
          }

          // Menampilkan daftar buku menggunakan ListView
          return ListView.builder(
            itemCount: books.length, // Jumlah buku dalam kategori
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 5), // Margin antar kartu
                child: ListTile(
                  title: Text(book['title']), 
                  subtitle: Text('Author: ${book['author']}'), 
                ),
              );
            },
          );
        },
      ),
    );
  }
}