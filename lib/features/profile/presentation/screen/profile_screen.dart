import 'package:flutter/material.dart';
import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/core/l10n/build_context_extensions.dart';
import 'package:flutter_auth_template/core/widgets/failure_view.dart';
import 'package:flutter_auth_template/core/widgets/loading_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/profile_cubit.dart';
import '../widgets/profile_details.dart';

class const ProfileScreen({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profile = context.select((ProfileCubit cubit) => cubit.state.profile);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.profileTab)),
      body: switch (profile) {
        AsyncError(:final failure) => FailureView(
          failure: failure,
          onRetry: () => context.read<ProfileCubit>().load(),
        ),
        AsyncData(:final value) => ProfileDetails(profile: value),
        AsyncInitial() || AsyncLoading() => const LoadingView(),
      },
    );
  }
}
