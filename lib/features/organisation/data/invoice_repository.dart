import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/org_invoice.dart';

class InvoiceRepository {
  InvoiceRepository({required this.orgUid});

  final String orgUid;

  Stream<List<OrgInvoice>> watchInvoices() {
    return FirebaseFirestore.instance
        .collection('organisations')
        .doc(orgUid)
        .collection('invoices')
        .orderBy('date', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => OrgInvoice.fromFirestore(d.id, d.data()))
            .toList());
  }
}
