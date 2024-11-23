import 'package:flutter/material.dart';
import '../controllers/book_controller.dart';
import '../controllers/member_controller.dart';

// Halaman untuk meminjam buku
class BorrowBook extends StatefulWidget {
  @override
  _BorrowBookState createState() => _BorrowBookState();
}

class _BorrowBookState extends State<BorrowBook> {
  // Controller untuk mengelola data buku
  final BookController _bookController = BookController();
  // Controller untuk mengelola data anggota
  final MemberController _memberController = MemberController();

  // List untuk menyimpan data buku yang dapat dipinjam
  List<Map<String, dynamic>> _books = [];
  // List untuk menyimpan data anggota
  List<Map<String, dynamic>> _members = [];
  // ID buku yang dipilih
  int? _selectedBookId;
  // ID anggota yang dipilih
  int? _selectedMemberId;

  // Fungsi untuk mengambil data buku dan anggota
  void _fetchData() async {
    final books = await _bookController.getBooks(); // Mengambil semua data buku
    final members = await _memberController.getMembers(); // Mengambil semua data anggota
    setState(() {
      // Filter buku yang belum dipinjam (member_id == null)
      _books = books.where((book) => book['member_id'] == null).toList();
      _members = members;
    });
  }

  // Fungsi untuk meminjam buku
  void _borrowBook() async {
    // Validasi: Pastikan buku dan anggota sudah dipilih
    if (_selectedBookId == null || _selectedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both a book and a member!')), // Tampilkan pesan kesalahan
      );
      return;
    }

    // Proses peminjaman buku
    await _bookController.borrowBook(_selectedBookId!, _selectedMemberId!);

    // Tampilkan pesan sukses
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Book borrowed successfully!')),
    );
    Navigator.pop(context); // Kembali ke halaman sebelumnya
  }

  // Fungsi yang dipanggil pertama kali saat widget dibuat
  @override
  void initState() {
    super.initState();
    _fetchData(); // Memuat data buku dan anggota
  }

  // Membangun UI halaman
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Borrow Book')), // Judul AppBar
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding untuk keseluruhan halaman
        child: Column(
          children: [
            // Dropdown untuk memilih buku
            DropdownButton<int>(
              value: _selectedBookId, // ID buku yang dipilih
              hint: Text('Select a Book'), // Placeholder jika belum ada yang dipilih
              items: _books.map((book) {
                return DropdownMenuItem<int>(
                  value: book['id'], // ID buku
                  child: Text(book['title']), // Judul buku
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBookId = value; // Update ID buku yang dipilih
                });
              },
            ),
            SizedBox(height: 10), // Spasi antar widget

            // Dropdown untuk memilih anggota
            DropdownButton<int>(
              value: _selectedMemberId, // ID anggota yang dipilih
              hint: Text('Select a Member'), // Placeholder jika belum ada yang dipilih
              items: _members.map((member) {
                return DropdownMenuItem<int>(
                  value: member['id'], // ID anggota
                  child: Text(member['name']), // Nama anggota
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMemberId = value; // Update ID anggota yang dipilih
                });
              },
            ),
            SizedBox(height: 20), // Spasi antar widget

            // Tombol untuk meminjam buku
            ElevatedButton(
              onPressed: _borrowBook, // Fungsi yang dipanggil saat tombol ditekan
              child: Text('Borrow Book'), // Teks pada tombol
            ),
          ],
        ),
      ),
    );
  }
}