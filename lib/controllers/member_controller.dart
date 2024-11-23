import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';

// Controller untuk mengelola operasi CRUD pada tabel Members
class MemberController {
  // Fungsi untuk menambahkan anggota baru ke tabel Members
  Future<int> addMember(String name, String email, String phone) async {
    final db = await DBHelper.initDB(); // Inisialisasi database
    return await db.insert('members', {
      'name': name, // Nama anggota
      'email': email, // Email anggota
      'phone': phone, // Nomor telepon anggota
    });
  }

  // Fungsi untuk mengambil semua anggota dari tabel Members
  Future<List<Map<String, dynamic>>> getMembers() async {
    final db = await DBHelper.initDB(); // Inisialisasi database
    return await db.query('members'); // Mengambil semua data dari tabel Members
  }

  // Fungsi untuk memperbarui data anggota di tabel Members
  Future<int> updateMember(int id, String name, String email, String phone) async {
    final db = await DBHelper.initDB(); // Inisialisasi database
    return await db.update(
      'members',
      {
        'name': name, // Perbarui nama anggota
        'email': email, // Perbarui email anggota
        'phone': phone, // Perbarui nomor telepon anggota
      },
      where: 'id = ?', // Kondisi: berdasarkan ID anggota
      whereArgs: [id],
    );
  }

  // Fungsi untuk menghapus anggota dari tabel Members berdasarkan ID
  Future<int> deleteMember(int id) async {
    final db = await DBHelper.initDB(); // Inisialisasi database
    return await db.delete(
      'members',
      where: 'id = ?', // Kondisi: berdasarkan ID anggota
      whereArgs: [id],
    );
  }
}