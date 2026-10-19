import 'package:flutter/material.dart';

import 'package:flutter_auth_template/core/l10n/build_context_extensions.dart';

class const NoPostsView({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(context.l10n.noPosts));
  }
}
