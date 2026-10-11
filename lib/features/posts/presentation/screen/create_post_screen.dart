import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/async/async_status.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../core/failures/app_failure_message.dart';
import '../cubit/posts_cubit.dart';
import '../cubit/posts_state.dart';

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
    final isCreating = context.select(
      (PostsCubit cubit) => cubit.state.createPost is Loading,
    );
    return BlocListener<PostsCubit, PostsState>(
      listenWhen: (previous, current) =>
          previous.createPost != current.createPost,
      listener: (context, state) {
        switch (state.createPost) {
          case Success():
            Navigator.of(context).pop();
          case Failure(:final error):
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(_failureMessage(error))));
          case _:
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

  String _failureMessage(AppFailure failure) => failure.message(context.l10n);
}
