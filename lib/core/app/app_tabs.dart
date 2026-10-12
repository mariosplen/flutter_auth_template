import 'package:flutter/material.dart';
import 'package:flutter_auth_template/features/posts/presentation/screen/posts_screen.dart';
import 'package:flutter_auth_template/features/profile/presentation/screen/profile_screen.dart';
import 'package:flutter_auth_template/features/settings/presentation/screen/settings_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/posts/presentation/cubit/posts_cubit.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../di/injection.dart';
import '../l10n/build_context_extensions.dart';
import 'app_cubit.dart';
import 'app_state.dart';

class const AppTabs({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final selectedTab = context.select(
      (AppCubit cubit) => cubit.state.selectedTab,
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<PostsCubit>()..load()),
        BlocProvider(
          create: (context) => getIt<ProfileCubit>(
            param1: context.read<AuthCubit>().state.user!.id,
          )..load(),
        ),
      ],
      child: Scaffold(
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
