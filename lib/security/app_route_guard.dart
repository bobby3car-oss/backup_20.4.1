const Set<String> kAllowedExternalRoutes = <String>{
  '/alerts',
  '/appointment',
  '/appointments',
  '/doctor-questions',
  '/meds',
  '/notifications',
  '/nutrition',
  '/packing',
  '/pain',
  '/photos',
  '/rehab',
  '/settings',
  '/speech',
  '/vitals',
  '/wound',
};

String? sanitizeExternalRoute(String? route) {
  final normalized = route?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  if (!normalized.startsWith('/')) {
    return null;
  }
  if (normalized.contains('://') || normalized.contains('?')) {
    return null;
  }
  return kAllowedExternalRoutes.contains(normalized) ? normalized : null;
}
