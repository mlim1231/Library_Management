class Member {
  final int? id;
  final String name;
  final String email;
  final String phone;

  Member({this.id, required this.name, required this.email, required this.phone});
  // Konversi objek ke map untuk operasi database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}