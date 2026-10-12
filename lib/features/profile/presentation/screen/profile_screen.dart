import 'package:flutter/material.dart';
import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/core/error/failure_message.dart';
import 'package:flutter_auth_template/core/l10n/build_context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/profile_cubit.dart';

class const ProfileScreen({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final email = context.select(
      (AuthCubit cubit) => cubit.state.user?.email ?? '',
    );
    final profile = context.select((ProfileCubit cubit) => cubit.state.profile);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.profileTab)),
      body: switch (profile) {
        AsyncError(:final failure) => Center(
          child: Column(
            mainAxisSize: .min,
            children: [
              Text(failure.message(context.l10n)),
              TextButton(
                onPressed: () => context.read<ProfileCubit>().load(),
                child: Text(context.l10n.tryAgain),
              ),
            ],
          ),
        ),
        AsyncData(:final value) => ListView(
          children: [
            ListTile(
              title: Text(context.l10n.name),
              subtitle: Text(value.name),
            ),
            ListTile(title: Text(context.l10n.email), subtitle: Text(email)),
            ListTile(
              title: Text(context.l10n.joined),
              subtitle: Text(
                DateFormat.yMMMd().format(value.createdAt.toLocal()),
              ),
            ),
          ],
        ),
        AsyncInitial() ||
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
