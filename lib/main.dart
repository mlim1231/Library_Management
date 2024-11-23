import 'package:flutter/material.dart';
import 'views/book_list.dart';
import 'views/category_list.dart';
import 'views/member_list.dart';
import 'views/borrowed_books.dart';
import 'views/borrow_book.dart';
import 'views/book_list_page.dart';


void main() {
  runApp(MyApp()); 
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      home: HomePage(), 
    );
  }
}

// Halaman utama aplikasi
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Library Management'), // Judul AppBar
        centerTitle: true, // Posisi judul di tengah
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding horizontal untuk tombol
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Posisikan tombol di tengah secara vertikal
            crossAxisAlignment: CrossAxisAlignment.stretch, // Lebar tombol mengikuti lebar kolom
            children: [
              // Tombol untuk mengelola buku
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BookList()), // Navigasi ke halaman BookList
                  );
                },
                child: Text('Manage Books'), // Teks pada tombol
              ),
              SizedBox(height: 10), // Spasi antar tombol

              // Tombol untuk mengelola kategori
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoryList()), // Navigasi ke halaman CategoryList
                  );
                },
                child: Text('Manage Categories'), // Teks pada tombol
              ),
              SizedBox(height: 10), // Spasi antar tombol

              // Tombol untuk mengelola anggota
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MemberList()), // Navigasi ke halaman MemberList
                  );
                },
                child: Text('Manage Members'), // Teks pada tombol
              ),
              SizedBox(height: 10), // Spasi antar tombol

              // Tombol untuk meminjam buku
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BorrowBook()), // Navigasi ke halaman BorrowBook
                  );
                },
                child: Text('Borrow Book'), // Teks pada tombol
              ),
              SizedBox(height: 10), // Spasi antar tombol

              // Tombol untuk melihat buku yang dipinjam
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BorrowedBooks()), // Navigasi ke halaman BorrowedBooks
                  );
                },
                child: Text('Borrowed Books'), // Teks pada tombol
              ),
              SizedBox(height: 10), // Spasi antar tombol

              // Tombol untuk melihat daftar buku
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BookListPage()), // Navigasi ke halaman BookListPage
                  );
                },
                child: Text('View Books'), // Teks pada tombol
              ),
            ],
          ),
        ),
      ),
    );
  }
}