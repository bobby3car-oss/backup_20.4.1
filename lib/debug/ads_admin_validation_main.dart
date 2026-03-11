import '../main.dart' as app;

Future<void> main() {
  app.debugInitialRouteOverride = '/debug/ads-admin';
  return app.main();
}