import 'package:blog_domain/blog_domain.dart';

class BlogPostDto {
  final String id;
  final String title;
  final String content;
  final String author;
  final String publishedAtIso;

  BlogPostDto({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.publishedAtIso,
  });

  factory BlogPostDto.fromJson(Map<String, dynamic> json) {
    return BlogPostDto(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      author: json['author'] as String,
      publishedAtIso: json['publishedAtIso'] as String,
    );
  }

  BlogPost toDomain() {
    return BlogPost(
      id: id,
      title: title,
      content: content,
      author: author,
      publishedAt: DateTime.parse(publishedAtIso),
    );
  }
}
