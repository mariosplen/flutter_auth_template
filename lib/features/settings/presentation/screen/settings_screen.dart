import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app/app_cubit.dart';
import '../../../../core/app/app_state.dart';
import '../../../../core/l10n/build_context_extensions.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class const SettingsScreen({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsTab)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(context.l10n.theme),
          const SizedBox(height: 8),
          SegmentedButton<AppThemeMode>(
            segments: [
              for (final themeMode in AppThemeMode.values)
                ButtonSegment(
                  value: themeMode,
                  label: Text(switch (themeMode) {
                    .system => context.l10n.themeSystem,
                    .light => context.l10n.themeLight,
                    .dark => context.l10n.themeDark,
                  }),
                ),
            ],
            selected: {
              context.select((AppCubit cubit) => cubit.state.themeMode),
            },
            onSelectionChanged: (selection) =>
                context.read<AppCubit>().setThemeMode(selection.single),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => context.read<AuthCubit>().signOut(),
            child: Text(context.l10n.signOut),
          ),
        ],
      ),
    );
  }
}
