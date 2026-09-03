import 'package:core_domain/core_domain.dart';
import '../entities/blog_post.dart';

abstract class BlogRepository {
  Future<Result<List<BlogPost>>> getPosts();
}
