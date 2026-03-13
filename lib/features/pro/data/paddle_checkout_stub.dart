// Stub implementation for non-web platforms – all calls are no-ops.

void paddleInit({required String token, bool sandbox = false}) {}

void paddleOpenCheckout({
  required String priceId,
  required String uid,
  String? email,
}) {}

void paddleVerifyPrice(String priceId) {}

String paddleDiag() => '';
