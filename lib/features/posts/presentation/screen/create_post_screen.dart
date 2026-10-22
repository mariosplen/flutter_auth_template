import 'package:flutter/material.dart';
import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/core/l10n/build_context_extensions.dart';
import 'package:flutter_auth_template/core/l10n/failure_message.dart';
import 'package:flutter_auth_template/features/posts/presentation/cubit/posts_cubit.dart';
import 'package:flutter_auth_template/features/posts/presentation/cubit/posts_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class const CreatePostScreen({super.key}) extends StatefulWidget {
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _title = TextEditingController();
  final _content = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = context.select<PostsCubit, bool>(
      (cubit) => cubit.state.createPost is AsyncLoading,
    );
    return BlocListener<PostsCubit, PostsState>(
      listenWhen: (previous, current) =>
          previous.createPost != current.createPost,
      listener: (context, state) {
        switch (state.createPost) {
          case AsyncData():
            Navigator.of(context).pop();
          case AsyncError(:final failure):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message(context.l10n))),
            );
          case AsyncInitial() || AsyncLoading():
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.newPost)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _title,
              decoration: InputDecoration(labelText: context.l10n.postTitle),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _content,
              minLines: 4,
              maxLines: null,
              decoration: InputDecoration(labelText: context.l10n.postContent),
            ),
            const SizedBox(height: 24),
            ListenableBuilder(
              listenable: Listenable.merge([_title, _content]),
              builder: (context, _) {
                final title = _title.text.trim();
                final content = _content.text.trim();
                return FilledButton(
                  onPressed: isCreating || title.isEmpty || content.isEmpty
                      ? null
                      : () => context.read<PostsCubit>().create(
                          title: title,
                          content: content,
                        ),
                  child: Text(context.l10n.publish),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
