import 'package:flutter/material.dart';
import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/core/error/failure_message.dart';
import 'package:flutter_auth_template/core/l10n/build_context_extensions.dart';
import 'package:flutter_auth_template/features/posts/presentation/cubit/posts_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'create_post_screen.dart';

class const PostsScreen({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final posts = context.select((PostsCubit cubit) => cubit.state.posts);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.postsTab)),
      body: switch (posts) {
        AsyncError(:final failure) => Center(
          child: Column(
            mainAxisSize: .min,
            children: [
              Text(failure.message(context.l10n)),
              TextButton(
                onPressed: () => context.read<PostsCubit>().load(),
                child: Text(context.l10n.tryAgain),
              ),
            ],
          ),
        ),
        AsyncData(:final value) when value.isEmpty => Center(
          child: Text(context.l10n.noPosts),
        ),
        AsyncData(:final value) => RefreshIndicator(
          onRefresh: () => context.read<PostsCubit>().load(),
          child: ListView.builder(
            itemCount: value.length,
            itemBuilder: (context, index) {
              final post = value[index];
              return ListTile(
                title: Text(post.title),
                subtitle: Text(post.content),
                trailing: Text(
                  DateFormat.yMMMd().format(post.createdAt.toLocal()),
                ),
              );
            },
          ),
        ),
        AsyncInitial() ||
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider.value(
              value: context.read<PostsCubit>(),
              child: const CreatePostScreen(),
            ),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
