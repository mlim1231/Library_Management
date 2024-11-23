import 'package:flutter/material.dart';
import '../controllers/category_controller.dart';

// Halaman untuk memilih kategori yang digunakan saat menambah/mengedit buku
class SelectCategoryPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedCategories; // Kategori yang telah dipilih sebelumnya

  SelectCategoryPage({required this.selectedCategories});

  @override
  _SelectCategoryPageState createState() => _SelectCategoryPageState();
}

class _SelectCategoryPageState extends State<SelectCategoryPage> {
  final CategoryController _categoryController = CategoryController(); // Controller untuk kategori
  List<Map<String, dynamic>> _categories = []; // Daftar kategori dari database
  Map<int, bool> _selectedCategories = {}; // Status kategori yang dipilih (id kategori: status)

  // Fungsi untuk mengambil daftar kategori dari database
  void _fetchCategories() async {
    final categories = await _categoryController.getCategories(); // Ambil kategori dari database
    setState(() {
      _categories = categories; // Perbarui daftar kategori

      // Tandai kategori yang telah dipilih sebelumnya
      _selectedCategories = {
        for (var category in _categories)
          category['id']: widget.selectedCategories
              .any((selected) => selected['id'] == category['id']),
      };
    });
  }

  // Fungsi yang dipanggil saat widget pertama kali diinisialisasi
  @override
  void initState() {
    super.initState();
    _fetchCategories(); // load daftar kategori
  }

  // Fungsi untuk membangun antarmuka halaman
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Categories'), // Judul halaman
        actions: [
          // Tombol untuk menyimpan kategori yang dipilih
          TextButton(
            onPressed: () {
              // Pilih kategori yang statusnya dipilih (true)
              final selected = _categories
                  .where((category) => _selectedCategories[category['id']] ?? false)
                  .toList();
              Navigator.pop(context, selected); // Kembalikan hasil pilihan ke halaman sebelumnya
            },
            child: Text(
              'Save',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      // Menampilkan daftar kategori menggunakan ListView
      body: ListView.builder(
        itemCount: _categories.length, // Jumlah kategori yang ditampilkan
        itemBuilder: (context, index) {
          final category = _categories[index]; // Data kategori berdasarkan indeks
          return CheckboxListTile(
            title: Text(category['name']), // Menampilkan nama kategori
            value: _selectedCategories[category['id']], // Status dipilih/tidak
            onChanged: (value) {
              setState(() {
                _selectedCategories[category['id']] = value ?? false; // Perbarui status pilihan
              });
            },
          );
        },
      ),
    );
  }
}