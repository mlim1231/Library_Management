import 'package:flutter/material.dart';
import '../controllers/category_controller.dart';

// Halaman untuk memilih kategori
class SelectCategoriesPage extends StatefulWidget {
  final Map<int, bool> selectedCategories; // Kategori yang telah dipilih sebelumnya

  SelectCategoriesPage({required this.selectedCategories});

  @override
  _SelectCategoriesPageState createState() => _SelectCategoriesPageState();
}

class _SelectCategoriesPageState extends State<SelectCategoriesPage> {
  final CategoryController _categoryController = CategoryController(); // Controller untuk operasi kategori
  List<Map<String, dynamic>> _categories = []; // Daftar kategori dari database
  Map<int, bool> _localSelectedCategories = {}; // Status kategori yang dipilih secara lokal

  // Fungsi untuk mengambil daftar kategori dari database
  void _fetchCategories() async {
    final categories = await _categoryController.getCategories();
    setState(() {
      _categories = categories;

      // Salin status kategori yang telah dipilih dari halaman sebelumnya
      _localSelectedCategories = Map.from(widget.selectedCategories);

      // Tambahkan kategori baru jika belum ada di _localSelectedCategories
      for (var category in categories) {
        if (!_localSelectedCategories.containsKey(category['id'])) {
          _localSelectedCategories[category['id']] = false;
        }
      }
    });
  }

  // Fungsi yang dipanggil saat halaman diinisialisasi
  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Memuat daftar kategori
  }

  // Tampilan utama halaman
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Categories'), // Judul halaman
        actions: [
          // Tombol untuk menyimpan kategori yang dipilih
          TextButton(
            onPressed: () {
              Navigator.pop(context, _localSelectedCategories); // Kembalikan hasil pilihan
            },
            child: Text('Save', style: TextStyle(color: Colors.black)), // Tombol "Save"
          ),
        ],
      ),
      // Daftar kategori dalam bentuk ListView
      body: ListView.builder(
        itemCount: _categories.length, // Jumlah kategori yang ditampilkan
        itemBuilder: (context, index) {
          final category = _categories[index]; // Data kategori berdasarkan indeks
          return CheckboxListTile(
            title: Text(category['name']), // Nama kategori
            value: _localSelectedCategories[category['id']], // Status kategori dipilih/tidak
            onChanged: (value) {
              setState(() {
                _localSelectedCategories[category['id']] = value ?? false; // Perbarui status lokal
              });
            },
          );
        },
      ),
    );
  }
}