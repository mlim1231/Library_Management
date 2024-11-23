import 'package:flutter/material.dart';
import '../controllers/category_controller.dart';
import '../controllers/book_category_controller.dart';

// Halaman untuk mengelola daftar kategori (CRUD kategori)
class CategoryList extends StatefulWidget {
  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  // Controller untuk mengelola data kategori
  final CategoryController _categoryController = CategoryController();
  // Controller untuk mengelola relasi buku-kategori
  final BookCategoryController _bookCategoryController = BookCategoryController();

  // Controller untuk input teks pada form kategori
  final TextEditingController _nameController = TextEditingController();

  // List untuk menyimpan daftar kategori dari database
  List<Map<String, dynamic>> _categories = [];
  // ID kategori yang sedang diedit (jika null berarti tambah kategori baru)
  int? _editingCategoryId;

  // Fungsi untuk mengambil data kategori dari database
  void _fetchCategories() async {
    final categories = await _categoryController.getCategories();
    setState(() {
      _categories = categories; // Update state dengan daftar kategori
    });
  }

  // Fungsi untuk menyimpan kategori baru atau memperbarui kategori yang ada
  void _saveCategory() async {
    // Validasi input: nama kategori tidak boleh kosong
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category name is required!')), // Pesan kesalahan
      );
      return;
    }

    if (_editingCategoryId == null) {
      // Jika kategori baru, tambahkan ke database
      await _categoryController.addCategory(_nameController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category added successfully!')), // Pesan sukses
      );
    } else {
      // Jika mengedit kategori, perbarui data di database
      await _categoryController.updateCategory(_editingCategoryId!, _nameController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category updated successfully!')), // Pesan sukses
      );
    }

    _nameController.clear(); // Kosongkan input
    _editingCategoryId = null; // Reset ID kategori yang sedang diedit
    _fetchCategories(); // Refresh daftar kategori
  }

  // Fungsi untuk menghapus kategori
  void _deleteCategory(int id) async {
    // Konfirmasi sebelum menghapus
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Category'), // Judul dialog
        content: Text('Are you sure you want to delete this category?'), // Pesan dialog
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')), // Tombol batal
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')), // Tombol hapus
        ],
      ),
    );

    if (confirmed == true) {
      // Jika dikonfirmasi, hapus kategori dari database
      await _categoryController.deleteCategory(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category deleted successfully!')), // Pesan sukses
      );
      _fetchCategories(); // Refresh daftar kategori
    }
  }

  // Fungsi untuk melihat buku berdasarkan kategori
  void _viewBooksInCategory(int categoryId, String categoryName) async {
    final books = await _bookCategoryController.getBooksForCategory(categoryId);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Books in $categoryName'), // Judul dialog
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: books.map((book) {
            return ListTile(
              title: Text(book['title']), // Judul buku
              subtitle: Text('Author: ${book['author']}'), // Penulis buku
            );
          }).toList(),
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

  // Fungsi yang dipanggil pertama kali saat widget dibuat
  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Memuat daftar kategori
  }

  // Membangun UI halaman
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Categories')), // Judul AppBar
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding untuk keseluruhan halaman
        child: Column(
          children: [
            // Input untuk nama kategori
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Category Name'), // Placeholder untuk input
            ),
            SizedBox(height: 10), // Spasi antar widget

            // Tombol untuk menyimpan kategori
            ElevatedButton(
              onPressed: _saveCategory, // Fungsi yang dipanggil saat tombol ditekan
              child: Text(_editingCategoryId == null ? 'Add Category' : 'Update Category'), // Teks pada tombol
            ),
            SizedBox(height: 20), // Spasi antar widget

            // Daftar kategori
            Expanded(
              child: ListView.builder(
                itemCount: _categories.length, // Jumlah kategori
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5), // Margin antar kartu
                    child: ListTile(
                      title: Text(category['name']), // Nama kategori
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tombol untuk melihat buku dalam kategori
                          IconButton(
                            icon: Icon(Icons.visibility, color: Colors.green),
                            onPressed: () => _viewBooksInCategory(category['id'], category['name']),
                          ),
                          // Tombol untuk mengedit kategori
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              setState(() {
                                _nameController.text = category['name']; // Isi input dengan nama kategori
                                _editingCategoryId = category['id']; // Set ID kategori yang sedang diedit
                              });
                            },
                          ),
                          // Tombol untuk menghapus kategori
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCategory(category['id']),
                          ),
                        ],
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