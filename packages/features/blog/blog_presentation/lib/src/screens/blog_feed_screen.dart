import 'package:flutter/material.dart';
import '../controllers/blog_controller.dart';

class BlogFeedScreen extends StatefulWidget {
  final BlogController controller;

  const BlogFeedScreen({
    super.key,
    required this.controller,
  });

  @override
  State<BlogFeedScreen> createState() => _BlogFeedScreenState();
}

class _BlogFeedScreenState extends State<BlogFeedScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => widget.controller.fetchPosts(),
          ),
        ],
      ),
      body: ValueListenableBuilder<BlogFeedState>(
        valueListenable: widget.controller,
        builder: (context, state, _) {
          if (state.status == BlogFeedStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == BlogFeedStatus.error) {
            return Center(
              child: Text(
                state.errorMessage ?? 'An error occurred',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state.posts.isEmpty) {
            return const Center(child: Text('No posts found.'));
          }

          return ListView.builder(
            itemCount: state.posts.length,
            itemBuilder: (context, index) {
              final post = state.posts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(post.title),
                  subtitle: Text('${post.content}\n\nBy ${post.author}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
