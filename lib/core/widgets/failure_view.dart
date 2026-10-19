import 'package:flutter/material.dart';

import 'package:flutter_auth_template/core/error/failure_message.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/l10n/build_context_extensions.dart';

class const FailureView({
  required final Failure failure,
  required final VoidCallback onRetry,
  super.key,
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
