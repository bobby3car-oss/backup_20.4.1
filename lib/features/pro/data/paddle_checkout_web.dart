import 'dart:js_interop';

@JS('_paddleInit')
external void _jsInit(JSString token, JSBoolean sandbox);

@JS('_paddleCheckout')
external void _jsCheckout(
  JSString priceId,
  JSString uid,
  JSString email,
  JSString entitlementScope,
  JSString productId,
);

@JS('_paddleVerifyPrice')
external void _jsVerifyPrice(JSString priceId);

@JS('_paddleDiag')
external JSString? get _jsDiag;

void paddleInit({required String token, bool sandbox = false}) {
  _jsInit(token.toJS, sandbox.toJS);
}

void paddleOpenCheckout({
  required String priceId,
  required String uid,
  String? email,
  String? entitlementScope,
  String? productId,
}) {
  _jsCheckout(
    priceId.toJS,
    uid.toJS,
    (email ?? '').toJS,
    (entitlementScope ?? '').toJS,
    (productId ?? '').toJS,
  );
}

void paddleVerifyPrice(String priceId) {
  _jsVerifyPrice(priceId.toJS);
}

String paddleDiag() {
  return _jsDiag?.toDart ?? '';
}
