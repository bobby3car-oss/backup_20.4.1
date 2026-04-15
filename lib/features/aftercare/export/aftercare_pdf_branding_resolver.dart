import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../security/field_encryption_service.dart';

class AftercarePdfBrandingResolver {
  AftercarePdfBrandingResolver({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<AftercarePdfBranding> resolve(String? organizationId) async {
    if (organizationId == null || organizationId.isEmpty) {
      return const AftercarePdfBranding(
        appTitle: 'Operationsbegleiter',
      );
    }

    try {
      final doc = await _firestore.doc('organisations/$organizationId').get();
      var data = doc.data();
      if (data == null) {
        return const AftercarePdfBranding(appTitle: 'Operationsbegleiter');
      }

      // Decrypt identifying org fields.
      data = FieldEncryptionService.instance
          .decryptFields(organizationId, data, kEncryptedOrgFields);

      final name = (data['name'] ?? '').toString();
      final address = (data['address'] ?? '').toString();
      final contact = (data['contactPerson'] ?? '').toString();
      final phone = (data['phone'] ?? '').toString();
      final website = (data['website'] ?? '').toString();
      final email = (data['email'] ?? '').toString();
      final logoUrl = (data['logoUrl'] ?? data['logo'] ?? '').toString();

      final contactLines = <String>[
        if (address.isNotEmpty) address,
        if (contact.isNotEmpty) 'Kontakt: $contact',
        if (phone.isNotEmpty) 'Tel: $phone',
        if (email.isNotEmpty) 'E-Mail: $email',
        if (website.isNotEmpty) website,
      ];

      return AftercarePdfBranding(
        appTitle: name.isNotEmpty ? name : 'Operationsbegleiter',
        organizationName: name.isNotEmpty ? name : null,
        logoUrl: logoUrl.isNotEmpty ? logoUrl : null,
        contactLines: contactLines,
      );
    } catch (_) {
      return const AftercarePdfBranding(appTitle: 'Operationsbegleiter');
    }
  }
}

class AftercarePdfBranding {
  const AftercarePdfBranding({
    required this.appTitle,
    this.organizationName,
    this.logoUrl,
    this.contactLines = const <String>[],
  });

  final String appTitle;
  final String? organizationName;
  final String? logoUrl;
  final List<String> contactLines;
}
