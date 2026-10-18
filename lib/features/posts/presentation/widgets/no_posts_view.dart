import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_extensions.dart';

class const NoPostsView({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(context.l10n.noPosts));
  }
}
