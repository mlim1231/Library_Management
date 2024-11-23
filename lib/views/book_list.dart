import 'package:flutter/material.dart';
import '../controllers/book_controller.dart';
import '../controllers/book_category_controller.dart';
import 'select_category_page.dart';

// Halaman untuk mengelola daftar buku
class BookList extends StatefulWidget {
  @override
  _BookListState createState() => _BookListState();
}

// State untuk BookList yang mencakup logika CRUD buku
class _BookListState extends State<BookList> {
  final BookController _bookController = BookController(); // Controller untuk operasi data buku
  final BookCategoryController _bookCategoryController = BookCategoryController(); // Controller untuk relasi buku-kategori
  final TextEditingController _titleController = TextEditingController(); // Controller input judul buku
  final TextEditingController _authorController = TextEditingController(); // Controller input penulis buku

  DateTime? _selectedDate; // Variabel untuk menyimpan tanggal publikasi buku
  bool _isDateSelected = false; // Status untuk menampilkan teks 'Date selected'

  List<Map<String, dynamic>> _books = []; // Daftar buku dari database
  List<Map<String, dynamic>> _selectedCategories = []; // Daftar kategori yang dipilih
  int? _editingBookId; // ID buku yang sedang di-edit 

  // Fungsi untuk mengambil data buku dari database
  void _fetchBooks() async {
    final books = await _bookController.getBooks(); // Ambil daftar buku dari database
    setState(() {
      _books = books; 
    });
  }

  // Fungsi untuk mengambil kategori yang terkait dengan buku tertentu
  void _fetchSelectedCategories(int bookId) async {
    final categories = await _bookCategoryController.getCategoriesForBook(bookId);
    setState(() {
      _selectedCategories = categories; 
    });
  }

  // Menampilkan detail buku dalam dialog (pop-up)
  void _showBookDetails(Map<String, dynamic> book) async {
    final categories = await _bookCategoryController.getCategoriesForBook(book['id']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book Details'), // Judul dialog
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${book['title']}'), // Menampilkan judul buku
            Text('Author: ${book['author']}'), // Menampilkan penulis buku
            Text('Published Date: ${book['published_date']}'), // Menampilkan tanggal publikasi
            Text(
              'Categories: ${categories.map((e) => e['name']).join(', ')}', // Menampilkan daftar kategori
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Menutup dialog
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  // Menampilkan dialog untuk menambah atau mengedit buku
  void _showAddOrEditDialog({Map<String, dynamic>? book}) async {
    if (book != null) {
      // Mode edit: isi data buku yang ada
      _titleController.text = book['title'];
      _authorController.text = book['author'];
      _selectedDate = DateTime.parse(book['published_date']);
      _isDateSelected = true; // Set status ke 'Date selected'
      _editingBookId = book['id'];
      _fetchSelectedCategories(book['id']);
    } else {
      // Mode tambah: reset form
      _titleController.clear();
      _authorController.clear();
      _selectedDate = null;
      _isDateSelected = false; // Reset status ke 'No selected date'
      _selectedCategories = [];
      _editingBookId = null;
    }

    // Menampilkan dialog input
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(book == null ? 'Add Book' : 'Edit Book'), // Judul dialog
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'), // Input judul buku
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _authorController,
                  decoration: InputDecoration(labelText: 'Author'), // Input penulis buku
                ),
                SizedBox(height: 10),
                // Input tanggal publikasi buku
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isDateSelected
                            ? 'Date selected: ${_selectedDate?.toLocal().toString().split(' ')[0]}'
                            : 'Publish Date:',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Membuka DatePicker untuk memilih tanggal
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        );
                        if (selected != null) {
                          setState(() {
                            _selectedDate = selected; // Simpan tanggal yang dipilih
                            _isDateSelected = true;
                          });
                        }
                      },
                      child: Text('Select Date'),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Input kategori buku
                TextButton(
                  onPressed: () async {
                    final selected = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectCategoryPage(
                          selectedCategories: _selectedCategories,
                        ),
                      ),
                    );
                    if (selected != null) {
                      setState(() {
                        _selectedCategories = selected; // Perbarui daftar kategori yang dipilih
                      });
                    }
                  },
                  child: Text('Select Categories'),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  children: _selectedCategories
                      .map((category) => Chip(
                            label: Text(category['name']),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Menutup dialog
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Validasi input
                if (_titleController.text.isEmpty ||
                    _authorController.text.isEmpty ||
                    _selectedCategories.isEmpty ||
                    _selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All fields are required!')),
                  );
                  return;
                }

                if (_editingBookId == null) {
                  _addBook(); // Tambahkan buku baru
                } else {
                  _updateBook(); // Perbarui buku yang ada
                }
                Navigator.pop(context);
              },
              child: Text(book == null ? 'Add' : 'Update'), // Teks tombol
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menambahkan buku baru
  void _addBook() async {
    final bookId = await _bookController.addBook(
      _titleController.text,
      _authorController.text,
      _selectedDate!.toIso8601String().split('T').first,
    );
    _saveBookCategories(bookId); // Simpan relasi buku-kategori
    _fetchBooks(); // Ambil daftar buku terbaru
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Book added successfully!')),
    );
  }

  // Fungsi untuk memperbarui buku yang ada
  void _updateBook() async {
    await _bookController.updateBook(
      _editingBookId!,
      _titleController.text,
      _authorController.text,
      _selectedDate!.toIso8601String().split('T').first,
    );
    await _bookCategoryController.deleteBookCategoryByBookId(_editingBookId!); // Hapus relasi lama
    _saveBookCategories(_editingBookId!); // Simpan relasi baru
    _fetchBooks();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Book updated successfully!')),
    );
  }

  // Fungsi untuk menyimpan relasi buku-kategori
  void _saveBookCategories(int bookId) async {
    for (var category in _selectedCategories) {
      await _bookCategoryController.addBookCategory(bookId, category['id']);
    }
  }

  // Fungsi untuk menghapus buku
  void _deleteBook(int id) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Book'),
        content: Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      await _bookController.deleteBook(id);
      await _bookCategoryController.deleteBookCategoryByBookId(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book deleted successfully!')),
      );
      _fetchBooks(); // Ambil daftar buku terbaru
    }
  }

  // Fungsi yang dipanggil saat widget pertama kali diinisialisasi
  @override
  void initState() {
    super.initState();
    _fetchBooks(); // Memuat daftar buku
  }

  // Widget utama untuk daftar buku
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Books')), // Judul halaman
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditDialog(), // Tambah buku baru
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _books.length, // Jumlah buku
          itemBuilder: (context, index) {
            final book = _books[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                title: Text(book['title']), // Menampilkan judul buku
                onTap: () => _showBookDetails(book), // Menampilkan detail buku
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue), // Ikon edit
                      onPressed: () => _showAddOrEditDialog(book: book), // Edit buku
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red), // Ikon hapus
                      onPressed: () => _deleteBook(book['id']), // Hapus buku
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}