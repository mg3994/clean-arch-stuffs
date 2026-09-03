import 'package:core_domain/core_domain.dart';
import '../entities/blog_post.dart';
import '../repositories/blog_repository.dart';

class GetBlogPosts implements UseCase<List<BlogPost>, NoParams> {
  final BlogRepository repository;

  GetBlogPosts(this.repository);

  @override
  Future<Result<List<BlogPost>>> call(NoParams params) {
    return repository.getPosts();
  }
}
