import 'package:flutter/material.dart';
import '../controllers/book_controller.dart';
import '../controllers/member_controller.dart';

class BorrowedBooks extends StatefulWidget {
  @override
  _BorrowedBooksState createState() => _BorrowedBooksState();
}

class _BorrowedBooksState extends State<BorrowedBooks> {
  final BookController _bookController = BookController();
  final MemberController _memberController = MemberController();

  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _borrowedBooks = [];
  int? _selectedMemberId;

  // Fungsi untuk mengambil daftar anggota dari database
  void _fetchMembers() async {
    final members = await _memberController.getMembers();
    setState(() {
      _members = members; // Update state dengan daftar anggota
    });
  }

  // Fungsi untuk mengambil daftar buku yang dipinjam oleh anggota tertentu
  void _fetchBorrowedBooks(int memberId) async {
    final books = await _bookController.getBooks();
    setState(() {
      // Filter buku yang sedang dipinjam oleh anggota berdasarkan member_id
      _borrowedBooks = books.where((book) => book['member_id'] == memberId).toList();
    });
  }

  // Fungsi untuk mengembalikan buku
  void _returnBook(int bookId) async {
    await _bookController.returnBook(bookId); // Kembalikan buku ke database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Book returned successfully!')), // Pesan sukses
    );
    if (_selectedMemberId != null) {
      _fetchBorrowedBooks(_selectedMemberId!); // Refresh daftar buku yang dipinjam
    }
  }

  // Fungsi yang dipanggil pertama kali saat widget dibuat
  @override
  void initState() {
    super.initState();
    _fetchMembers(); // Memuat daftar anggota
  }

  // Membangun UI halaman
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Borrowed Books')), // Judul AppBar
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding untuk keseluruhan halaman
        child: Column(
          children: [
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
                  _selectedMemberId = value; // Update state dengan ID anggota yang dipilih
                  if (value != null) {
                    _fetchBorrowedBooks(value); // Ambil daftar buku yang dipinjam
                  } else {
                    _borrowedBooks = []; // Kosongkan daftar buku jika tidak ada anggota dipilih
                  }
                });
              },
            ),
            SizedBox(height: 20), // Spasi antar widget

            // Daftar buku yang dipinjam
            Expanded(
              child: _borrowedBooks.isEmpty
                  ? Center(child: Text('No borrowed books for this member.')) // Pesan jika tidak ada buku
                  : ListView.builder(
                      itemCount: _borrowedBooks.length, // Jumlah buku yang dipinjam
                      itemBuilder: (context, index) {
                        final book = _borrowedBooks[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5), // Margin antar kartu
                          child: ListTile(
                            title: Text(book['title']), // Judul buku
                            subtitle: Text('Author: ${book['author']}'), // Penulis buku
                            trailing: IconButton(
                              icon: Icon(Icons.undo, color: Colors.green), // Ikon tombol "Return"
                              onPressed: () => _returnBook(book['id']), // Fungsi untuk mengembalikan buku
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}