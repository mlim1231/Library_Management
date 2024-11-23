class Book {
  final int? id;
  final String title;
  final String author;
  final DateTime publishedDate;
  final int? memberId; // Relasi ke anggota

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.publishedDate,
    this.memberId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'published_date': publishedDate.toIso8601String(),
      'member_id': memberId,
    };
  }
}