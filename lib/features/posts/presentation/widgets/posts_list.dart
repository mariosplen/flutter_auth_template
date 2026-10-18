import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/post.dart';
import '../cubit/posts_cubit.dart';

class const PostsList({super.key, required final List<Post> posts})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<PostsCubit>().load(),
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return ListTile(
            title: Text(post.title),
            subtitle: Text(post.content),
            trailing: Text(DateFormat.yMMMd().format(post.createdAt.toLocal())),
          );
        },
      ),
    );
  }
}
