import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_auth_template/core/app/presentation/cubit/app_cubit.dart';
import 'package:flutter_auth_template/core/app/presentation/cubit/app_state.dart';
import 'package:flutter_auth_template/core/l10n/build_context_extensions.dart';
import 'package:flutter_auth_template/features/posts/presentation/cubit/posts_cubit.dart';
import 'package:flutter_auth_template/features/posts/presentation/screen/posts_screen.dart';
import 'package:flutter_auth_template/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_auth_template/features/profile/presentation/screen/profile_screen.dart';
import 'package:flutter_auth_template/features/settings/presentation/screen/settings_screen.dart';
import 'package:flutter_auth_template/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class const AppTabs({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final selectedTab = context.select<AppCubit, AppTab>(
      (cubit) => cubit.state.selectedTab,
    );
    // Created on every sign-in, so each user starts with fresh data.
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = sl<PostsCubit>();
            unawaited(cubit.load());
            return cubit;
          },
        ),
        BlocProvider(
          create: (_) {
            final cubit = sl<ProfileCubit>();
            unawaited(cubit.load());
            return cubit;
          },
        ),
      ],
      child: Scaffold(
        // Keep every tab alive, so switching tabs does not reload them.
        body: IndexedStack(
          index: selectedTab.index,
          children: [
            for (final tab in AppTab.values)
              switch (tab) {
                .posts => const PostsScreen(),
                .profile => const ProfileScreen(),
                .settings => const SettingsScreen(),
              },
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedTab.index,
          onTap: (index) =>
              context.read<AppCubit>().selectTab(AppTab.values[index]),
          items: [
            for (final tab in AppTab.values)
              switch (tab) {
                .posts => BottomNavigationBarItem(
                  icon: const Icon(Icons.article),
                  label: context.l10n.postsTab,
                ),
                .profile => BottomNavigationBarItem(
                  icon: const Icon(Icons.person),
                  label: context.l10n.profileTab,
                ),
                .settings => BottomNavigationBarItem(
                  icon: const Icon(Icons.settings),
                  label: context.l10n.settingsTab,
                ),
              },
          ],
        ),
      ),
    );
  }
}
