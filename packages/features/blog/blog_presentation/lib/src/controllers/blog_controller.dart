import 'package:flutter/foundation.dart';
import 'package:blog_domain/blog_domain.dart';
import 'package:core_domain/core_domain.dart';

enum BlogFeedStatus { initial, loading, loaded, error }

class BlogFeedState {
  final BlogFeedStatus status;
  final List<BlogPost> posts;
  final String? errorMessage;

  const BlogFeedState({
    this.status = BlogFeedStatus.initial,
    this.posts = const [],
    this.errorMessage,
  });

  BlogFeedState copyWith({
    BlogFeedStatus? status,
    List<BlogPost>? posts,
    String? errorMessage,
  }) {
    return BlogFeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class BlogController extends ValueNotifier<BlogFeedState> {
  final GetBlogPosts _getBlogPosts;

  BlogController(this._getBlogPosts) : super(const BlogFeedState());

  Future<void> fetchPosts() async {
    value = value.copyWith(status: BlogFeedStatus.loading, errorMessage: null);

    final result = await _getBlogPosts(const NoParams());

    result.fold(
      (failure) {
        value = value.copyWith(
          status: BlogFeedStatus.error,
          errorMessage: failure.message,
        );
      },
      (posts) {
        value = value.copyWith(
          status: BlogFeedStatus.loaded,
          posts: posts,
        );
      },
    );
  }
}
