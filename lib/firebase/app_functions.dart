import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';

const appFunctionsRegion = 'europe-west1';

FirebaseFunctions appFunctions() =>
    FirebaseFunctions.instanceFor(region: appFunctionsRegion);

String appFunctionHttpUrl(String functionName) {
  final projectId = Firebase.app().options.projectId;
  return 'https://$appFunctionsRegion-$projectId.cloudfunctions.net/$functionName';
}
