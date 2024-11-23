import 'package:flutter/material.dart';
import '../controllers/book_controller.dart';
import '../controllers/book_category_controller.dart';
import '../controllers/category_controller.dart';
import 'select_categories_page.dart';

class BookListPage extends StatefulWidget {
  @override
  _BookListPageState createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  final BookController _bookController = BookController();
  final BookCategoryController _bookCategoryController = BookCategoryController();
  final CategoryController _categoryController = CategoryController();

  List<Map<String, dynamic>> _books = [];
  Map<int, bool> _selectedCategories = {};

  // Fungsi untuk mengambil buku berdasarkan kategori
  void _fetchBooks() async {
    final selectedCategoryIds = _selectedCategories.entries
        .where((entry) => entry.value) // Ambil kategori yang dipilih
        .map((entry) => entry.key)
        .toList();

    if (selectedCategoryIds.isEmpty) {
      // Jika tidak ada kategori yang dipilih, ambil semua buku
      final books = await _bookController.getBooks();
      setState(() {
        _books = books;
      });
    } else {
      // Ambil buku berdasarkan kategori yang dipilih
      Map<int, Map<String, dynamic>> uniqueBooks = {}; // Map untuk menghindari duplikasi buku

      for (int categoryId in selectedCategoryIds) {
        final booksByCategory =
            await _bookCategoryController.getBooksForCategory(categoryId);

        // Tambahkan buku ke Map dengan id sebagai kunci
        for (var book in booksByCategory) {
          uniqueBooks[book['id']] = book;
        }
      }

      setState(() {
        // Konversi Map kembali menjadi List
        _books = uniqueBooks.values.toList();
      });
    }
  }

  // Fungsi untuk mengambil data kategori
  void _fetchCategories() async {
    final categories = await _categoryController.getCategories();
    setState(() {
      _selectedCategories = {
        for (var category in categories) category['id']: false,
      };
    });
  }

  // Fungsi untuk menampilkan pop-up dengan detail buku
  void _showBookDetails(Map<String, dynamic> book) async {
    final categories = await _bookCategoryController.getCategoriesForBook(book['id']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(book['title']), // Judul buku
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Author: ${book['author']}'), // Nama penulis
            Text('Published Date: ${book['published_date']}'), // Tanggal publikasi
            SizedBox(height: 10), 
            Text('Categories:', style: TextStyle(fontWeight: FontWeight.bold)), // Header kategori
            ...categories.map((category) => Text('- ${category['name']}')).toList(), // List kategori
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'), // Tombol untuk menutup dialog
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Books List'),
        actions: [
          // Tombol untuk membuka halaman filter kategori
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () async {
              final selectedCategories = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SelectCategoriesPage(selectedCategories: _selectedCategories),
                ),
              );
              if (selectedCategories != null) {
                setState(() {
                  _selectedCategories = selectedCategories;
                });
                _fetchBooks();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _books.isEmpty
                  ? Center(child: Text('No books available.'))
                  : ListView.builder(
                      itemCount: _books.length,
                      itemBuilder: (context, index) {
                        final book = _books[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(book['title']), // Judul buku
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Author: ${book['author']}'), // Nama penulis
                                Text('Published Date: ${book['published_date']}'), // Tanggal publikasi
                              ],
                            ),
                            onTap: () => _showBookDetails(book), // Tampilkan detail buku saat ditekan
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