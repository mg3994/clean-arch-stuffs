import 'package:blog_domain/blog_domain.dart';
import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import '../models/blog_post_dto.dart';

class BlogRepositoryImpl implements BlogRepository {
  final NetworkClient networkClient;

  BlogRepositoryImpl(this.networkClient);

  @override
  Future<Result<List<BlogPost>>> getPosts() async {
    try {
      final response = await networkClient.get('/api/v1/posts');
      final list = (response['items'] as List?) ?? [];
      final posts = list
          .map((item) => BlogPostDto.fromJson(item as Map<String, dynamic>).toDomain())
          .toList();
      return Result.success(posts);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
