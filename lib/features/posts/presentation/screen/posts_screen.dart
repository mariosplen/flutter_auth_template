import 'package:flutter/material.dart';
import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/core/l10n/build_context_extensions.dart';
import 'package:flutter_auth_template/core/widgets/failure_view.dart';
import 'package:flutter_auth_template/core/widgets/loading_view.dart';
import 'package:flutter_auth_template/features/posts/domain/entities/post.dart';
import 'package:flutter_auth_template/features/posts/presentation/cubit/posts_cubit.dart';
import 'package:flutter_auth_template/features/posts/presentation/screen/create_post_screen.dart';
import 'package:flutter_auth_template/features/posts/presentation/widgets/no_posts_view.dart';
import 'package:flutter_auth_template/features/posts/presentation/widgets/posts_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class const PostsScreen({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final posts = context.select<PostsCubit, AsyncValue<List<Post>>>(
      (cubit) => cubit.state.posts,
    );
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.postsTab)),
      body: switch (posts) {
        AsyncError(:final failure) => FailureView(
          failure: failure,
          onRetry: () => context.read<PostsCubit>().load(),
        ),
        AsyncData(:final value) when value.isEmpty => const NoPostsView(),
        AsyncData(:final value) => PostsList(posts: value),
        AsyncInitial() || AsyncLoading() => const LoadingView(),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            // Pushed routes do not see AppTabs' providers, so pass the cubit.
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
