import 'package:flutter/material.dart';

Future<void> finishPostAuthTransition(BuildContext context) async {
  if (context.mounted) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

Future<void> reloadCurrentPage() async {}