import 'package:cloud_functions/cloud_functions.dart';

import '../../firebase/app_functions.dart';

/// Single source of truth for the Cloud Functions region used by admin calls.
const adminFunctionsRegion = appFunctionsRegion;

/// Returns the [FirebaseFunctions] instance configured for the admin region.
FirebaseFunctions adminFunctions() => appFunctions();
