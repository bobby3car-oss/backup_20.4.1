import 'package:cloud_functions/cloud_functions.dart';

/// Single source of truth for the Cloud Functions region used by admin calls.
const adminFunctionsRegion = 'europe-west1';

/// Returns the [FirebaseFunctions] instance configured for the admin region.
FirebaseFunctions adminFunctions() =>
    FirebaseFunctions.instanceFor(region: adminFunctionsRegion);
