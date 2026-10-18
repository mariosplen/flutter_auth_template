import 'package:flutter/material.dart';

import '../error/failure_message.dart';
import '../error/failures.dart';
import '../l10n/build_context_extensions.dart';

class const FailureView({
  super.key,
  required final Failure failure,
  required final VoidCallback onRetry,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: .min,
        children: [
          Text(failure.message(context.l10n)),
          TextButton(onPressed: onRetry, child: Text(context.l10n.tryAgain)),
        ],
      ),
    );
  }
}
