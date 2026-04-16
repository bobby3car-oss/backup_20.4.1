import 'package:cloud_functions/cloud_functions.dart';

const appFunctionsRegion = 'europe-west1';

FirebaseFunctions appFunctions() =>
    FirebaseFunctions.instanceFor(region: appFunctionsRegion);