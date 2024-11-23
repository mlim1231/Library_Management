import 'package:flutter/material.dart';
import '../controllers/member_controller.dart';

// Widget utama untuk daftar anggota
class MemberList extends StatefulWidget {
  @override
  _MemberListState createState() => _MemberListState();
}

// State untuk MemberList yang mencakup logika CRUD
class _MemberListState extends State<MemberList> {
  // Controller untuk operasi data anggota
  final MemberController _memberController = MemberController();

  // Controller untuk input teks (nama, email, nomor telepon)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // List untuk menyimpan data anggota yang diambil dari database
  List<Map<String, dynamic>> _members = [];
  int? _editingMemberId; // ID anggota yang sedang di-edit (null jika tidak ada)

  // Fungsi untuk mengambil data anggota dari database
  void _fetchMembers() async {
    final members = await _memberController.getMembers();
    setState(() {
      _members = members; // Memperbarui state dengan data anggota
    });
  }

  // Menampilkan detail anggota dalam dialog (pop-up)
  void _showMemberDetails(Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Member Details'), // Judul dialog
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${member['name']}'), // Menampilkan nama
            Text('Email: ${member['email']}'), // Menampilkan email
            Text('Phone: ${member['phone']}'), // Menampilkan nomor telepon
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

  // Fungsi untuk menyimpan anggota baru atau memperbarui anggota yang ada
  void _saveMember() async {
    // Validasi input: tidak boleh kosong
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields are required!')),
      );
      return;
    }

    // Validasi format email
    final emailPattern = r'^[^@]+@[^@]+\.[^@]+$';
    if (!RegExp(emailPattern).hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid email address!')),
      );
      return;
    }

    // Validasi format nomor telepon
    final phonePattern = r'^\d{10,13}$';
    if (!RegExp(phonePattern).hasMatch(_phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid phone number!')),
      );
      return;
    }

    // Jika tidak ada ID editing, tambahkan anggota baru
    if (_editingMemberId == null) {
      await _memberController.addMember(
        _nameController.text,
        _emailController.text,
        _phoneController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Member added successfully!')),
      );
    } else {
      // Jika ada ID editing, perbarui anggota yang ada
      await _memberController.updateMember(
        _editingMemberId!,
        _nameController.text,
        _emailController.text,
        _phoneController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Member updated successfully!')),
      );
    }

    _clearForm(); // Bersihkan form setelah penyimpanan
    _fetchMembers(); // Ambil data anggota terbaru
  }

  // Fungsi untuk menghapus anggota berdasarkan ID
  void _deleteMember(int id) async {
    // Konfirmasi penghapusan anggota
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Member'), // Judul dialog
        content: Text('Are you sure you want to delete this member?'), // Pesan konfirmasi
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
        ],
      ),
    );

    // Jika pengguna mengonfirmasi, hapus anggota
    if (confirmed == true) {
      await _memberController.deleteMember(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Member deleted successfully!')),
      );
      _fetchMembers(); // Ambil data anggota terbaru
    }
  }

  // Membersihkan form input dan reset ID editing
  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _editingMemberId = null;
  }

  // Inisialisasi: ambil data anggota saat widget dibangun
  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  // Widget utama untuk daftar anggota
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Members')), // Judul halaman
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input nama anggota
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 10),

            // Input email anggota
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 10),

            // Input nomor telepon anggota
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            SizedBox(height: 20),

            // Tombol untuk menyimpan anggota baru atau memperbarui anggota
            ElevatedButton(
              onPressed: _saveMember,
              child: Text(_editingMemberId == null ? 'Add Member' : 'Update Member'),
            ),
            SizedBox(height: 20),

            // Daftar anggota
            Expanded(
              child: ListView.builder(
                itemCount: _members.length,
                itemBuilder: (context, index) {
                  final member = _members[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(member['name']), // Menampilkan nama anggota
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Ikon untuk menampilkan detail anggota
                          IconButton(
                            icon: Icon(Icons.visibility, color: Colors.green),
                            onPressed: () => _showMemberDetails(member),
                          ),

                          // Ikon untuk mengedit anggota
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              setState(() {
                                _nameController.text = member['name'];
                                _emailController.text = member['email'];
                                _phoneController.text = member['phone'];
                                _editingMemberId = member['id'];
                              });
                            },
                          ),

                          // Ikon untuk menghapus anggota
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteMember(member['id']),
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