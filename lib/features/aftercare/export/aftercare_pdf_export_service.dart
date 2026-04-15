import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../security/field_encryption_service.dart';
import '../domain/aftercare_template.dart';
import '../domain/patient_aftercare_plan.dart';
import 'aftercare_export_mapper.dart';
import 'aftercare_pdf_branding_resolver.dart';
import 'aftercare_pdf_document_builder.dart';
import 'pdf_download.dart';

class AftercarePdfExportService {
  AftercarePdfExportService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    AftercarePdfBrandingResolver? brandingResolver,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _brandingResolver =
            brandingResolver ?? AftercarePdfBrandingResolver(firestore: firestore);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final AftercarePdfBrandingResolver _brandingResolver;

  static final DateFormat _date = DateFormat('yyyy-MM-dd');

  Future<void> exportPlanPdf(PatientAftercarePlan plan) async {
    final branding = await _brandingResolver.resolve(plan.organizationId);

    final patientName = await _resolvePatientName(plan.patientId);
    final doctorName = await _resolveDoctorName(plan.doctorId);

    final data = AftercareExportMapper.mapPlan(
      plan: plan,
      patientName: patientName,
      doctorName: doctorName,
      organizationName: branding.organizationName,
    );

    final bytes = await AftercarePdfDocumentBuilder.buildPersonalized(
      data: data,
      branding: branding,
    );

    final day = _date.format(DateTime.now());
    final filename = 'Nachbehandlungsplan_${plan.id}_$day.pdf';
    await downloadPdfBytes(bytes, filename);
  }

  Future<void> exportTemplateBlankPdf(AftercareTemplate template) async {
    final branding = await _brandingResolver.resolve(template.organizationId);

    final data = AftercareExportMapper.mapTemplate(
      template: template,
      organizationName: branding.organizationName,
    );

    final bytes = await AftercarePdfDocumentBuilder.buildBlankTemplate(
      data: data,
      branding: branding,
    );

    final day = _date.format(DateTime.now());
    final filename = 'Nachbehandlungsvorlage_${template.id}_$day.pdf';
    await downloadPdfBytes(bytes, filename);
  }

  Future<String?> _resolvePatientName(String patientId) async {
    try {
      final userDoc = await _firestore.doc('users/$patientId').get();
      var userData = userDoc.data();
      if (userData != null) {
        userData = FieldEncryptionService.instance
            .decryptFields(patientId, userData, kEncryptedUserFields);
        final displayName = (userData['displayName'] ?? '').toString().trim();
        if (displayName.isNotEmpty) return displayName;
        final email = (userData['email'] ?? '').toString().trim();
        if (email.isNotEmpty) return email;
      }

      final patientDoc = await _firestore.doc('patients/$patientId').get();
      final patientData = patientDoc.data();
      if (patientData != null && patientData['profile'] is Map) {
        final profile = Map<String, dynamic>.from(patientData['profile'] as Map);
        final profileName = (profile['displayName'] ?? '').toString().trim();
        if (profileName.isNotEmpty) return profileName;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _resolveDoctorName(String doctorId) async {
    try {
      final userDoc = await _firestore.doc('users/$doctorId').get();
      var userData = userDoc.data();
      if (userData != null) {
        userData = FieldEncryptionService.instance
            .decryptFields(doctorId, userData, kEncryptedDoctorFields);
        final displayName = (userData['displayName'] ?? '').toString().trim();
        if (displayName.isNotEmpty) return displayName;
      }

      final doctorDoc = await _firestore.doc('doctors/$doctorId').get();
      final doctorData = doctorDoc.data();
      if (doctorData != null) {
        final name = (doctorData['name'] ?? '').toString().trim();
        if (name.isNotEmpty) return name;
      }
      return null;
    } catch (_) {
      return _auth.currentUser?.displayName;
    }
  }
}
