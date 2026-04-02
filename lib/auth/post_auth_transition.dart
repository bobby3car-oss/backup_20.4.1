import 'package:flutter/material.dart';

import 'post_auth_transition_stub.dart'
    if (dart.library.html) 'post_auth_transition_web.dart' as impl;

Future<void> finishPostAuthTransition(BuildContext context) {
  return impl.finishPostAuthTransition(context);
}

Future<void> reloadCurrentPage() {
  return impl.reloadCurrentPage();
}