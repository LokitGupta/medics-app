class Article {
  final String id;
  final String title;
  final String content;
  final String? summary;
  final String? imageUrl;
  final String? author;
  final String? category;
  final DateTime publishedAt;
  final DateTime createdAt;

  Article({
    required this.id,
    required this.title,
    required this.content,
    this.summary,
    this.imageUrl,
    this.author,
    this.category,
    required this.publishedAt,
    required this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      summary: json['summary'],
      imageUrl: json['image_url'],
      author: json['author'],
      category: json['category'],
      publishedAt: DateTime.parse(json['published_at']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
