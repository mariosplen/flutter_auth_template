import 'package:flutter/material.dart';
import 'package:flutter_auth_template/core/l10n/build_context_extensions.dart';
import 'package:flutter_auth_template/features/profile/domain/entities/profile.dart';
import 'package:intl/intl.dart';

class const ProfileDetails({required final Profile profile, super.key})
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
