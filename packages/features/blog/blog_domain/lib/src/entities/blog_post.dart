class BlogPost {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime publishedAt;

  const BlogPost({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.publishedAt,
  });
}
