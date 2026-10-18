import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/build_context_extensions.dart';
import '../../domain/entities/profile.dart';

class const ProfileDetails({super.key, required final Profile profile})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(title: Text(context.l10n.name), subtitle: Text(profile.name)),
        ListTile(
          title: Text(context.l10n.email),
          subtitle: Text(profile.email),
        ),
        ListTile(
          title: Text(context.l10n.joined),
          subtitle: Text(
            DateFormat.yMMMd().format(profile.createdAt.toLocal()),
          ),
        ),
      ],
    );
  }
}
