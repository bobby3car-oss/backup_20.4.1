import 'package:cloud_firestore/cloud_firestore.dart';

class OrgInvoice {
  const OrgInvoice({
    required this.id,
    required this.amount,
    required this.currency,
    required this.date,
    required this.status,
    this.downloadUrl,
  });

  final String id;
  final double amount;
  final String currency;
  final DateTime date;
  final String status; // 'paid', 'open', 'cancelled'
  final String? downloadUrl;

  factory OrgInvoice.fromFirestore(String id, Map<String, dynamic> data) {
    return OrgInvoice(
      id: id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      currency: data['currency'] as String? ?? 'EUR',
      date: _toDateTime(data['date']) ?? DateTime.now(),
      status: data['status'] as String? ?? 'open',
      downloadUrl: data['downloadUrl'] as String?,
    );
  }

  static DateTime? _toDateTime(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
