import 'package:flutter/material.dart';
import 'package:flutter_auth_template/core/async/async_status.dart';
import 'package:flutter_auth_template/core/extensions/build_context_extensions.dart';
import 'package:flutter_auth_template/core/failures/app_failure_message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/profile.dart';
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
        Failure(:final error) => Center(
          child: Column(
            mainAxisSize: .min,
            children: [
              Text(error.message(context.l10n)),
              TextButton(
                onPressed: () => context.read<ProfileCubit>().load(),
                child: Text(context.l10n.tryAgain),
              ),
            ],
          ),
        ),
        Success<Profile>(:final data) => ListView(
          children: [
            ListTile(title: Text(context.l10n.name), subtitle: Text(data.name)),
            ListTile(title: Text(context.l10n.email), subtitle: Text(email)),
            ListTile(
              title: Text(context.l10n.joined),
              subtitle: Text(
                DateFormat.yMMMd().format(data.createdAt.toLocal()),
              ),
            ),
          ],
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
