class FirestorePaths {
  FirestorePaths._();

  // Top-level collections
  static const String users = 'users';
  static const String userPushTokens = 'user_push_tokens';
  static const String patients = 'patients';
  static const String doctors = 'doctors';
  static const String doctorInvites = 'doctor_invites';
  static const String doctorPermanentCodes = 'doctor_permanent_codes';
  static const String orgInviteCodes = 'org_invite_codes';
  static const String orgJoinRequests = 'org_join_requests';

  // Patient sub-collections
  static const String links = 'links';
  static const String invites = 'invites';
  static const String timeline = 'timeline';
  static const String wounds = 'wounds';
  static const String pain = 'pain';
  static const String voiceMemos = 'voice_memos';
  static const String appointments = 'appointments';
  static const String documents = 'documents';
  static const String photos = 'photos';
  static const String packing = 'packing';
  static const String questions = 'questions';
  static const String warnings = 'warnings';
  static const String observations = 'observations';
  static const String redFlags = 'red_flags';
  static const String auditLog = 'auditLog';
  static const String gamification = 'gamification';
  static const String gamificationLog = 'gamification_log';
  static const String dailyChallenges = 'daily_challenges';
  static const String notifications = 'notifications';
  static const String symptomChecks = 'symptom_checks';
  static const String bellaChat = 'bella_chat';

  // Aftercare collections
  static const String systemAftercareTemplates = 'system_aftercare_templates';
  static const String organizationAftercareTemplates =
      'organization_aftercare_templates';
  static const String doctorAftercareTemplates = 'doctor_aftercare_templates';
  static const String patientAftercarePlans = 'patient_aftercare_plans';

  // Aftercare plan subcollections (patient-private)
  static const String aftercareProgress = 'progress';
  static const String aftercarePatientNotes = 'patient_notes';
  static const String aftercareChangeLog = 'change_log';

  static String aftercareProgressDoc(String planId) =>
      '$patientAftercarePlans/$planId/$aftercareProgress/items';

  static String aftercarePatientNotesCollection(String planId) =>
      '$patientAftercarePlans/$planId/$aftercarePatientNotes';

  static String aftercareChangeLogCollection(String planId) =>
      '$patientAftercarePlans/$planId/$aftercareChangeLog';

  static String userDoc(String uid) => '$users/$uid';
  static String userPushTokenDoc(String uid) => '$userPushTokens/$uid';
  static String patientDoc(String patientId) => '$patients/$patientId';

  static String linksCollection(String patientId) =>
      '${patientDoc(patientId)}/$links';
  static String invitesCollection(String patientId) =>
      '${patientDoc(patientId)}/$invites';
  static String timelineCollection(String patientId) =>
      '${patientDoc(patientId)}/$timeline';
  static String woundsCollection(String patientId) =>
      '${patientDoc(patientId)}/$wounds';
  static String painCollection(String patientId) =>
      '${patientDoc(patientId)}/$pain';
  static String voiceMemosCollection(String patientId) =>
      '${patientDoc(patientId)}/$voiceMemos';
  static String appointmentsCollection(String patientId) =>
      '${patientDoc(patientId)}/$appointments';
  static String documentsCollection(String patientId) =>
      '${patientDoc(patientId)}/$documents';
  static String photosCollection(String patientId) =>
      '${patientDoc(patientId)}/$photos';
  static String packingCollection(String patientId) =>
      '${patientDoc(patientId)}/$packing';
  static String questionsCollection(String patientId) =>
      '${patientDoc(patientId)}/$questions';
  static String warningsCollection(String patientId) =>
      '${patientDoc(patientId)}/$warnings';
  static String observationsCollection(String patientId) =>
      '${patientDoc(patientId)}/$observations';
  static String redFlagsCollection(String patientId) =>
      '${patientDoc(patientId)}/$redFlags';

  static String linkDoc(String patientId, String linkId) =>
      '${linksCollection(patientId)}/$linkId';
  static String inviteDoc(String patientId, String inviteId) =>
      '${invitesCollection(patientId)}/$inviteId';
  static String timelineDoc(String patientId, String itemId) =>
      '${timelineCollection(patientId)}/$itemId';
  static String observationDoc(String patientId, String observationId) =>
      '${observationsCollection(patientId)}/$observationId';

  static String gamificationDoc(String patientId) =>
      '${patientDoc(patientId)}/$gamification/state';
  static String gamificationLogCollection(String patientId) =>
      '${patientDoc(patientId)}/$gamificationLog';
  static String dailyChallengesCollection(String patientId) =>
      '${patientDoc(patientId)}/$dailyChallenges';
  static String notificationsCollection(String patientId) =>
      '${patientDoc(patientId)}/$notifications';
  static String symptomChecksCollection(String patientId) =>
      '${patientDoc(patientId)}/$symptomChecks';
  static String bellaChatCollection(String patientId) =>
      '${patientDoc(patientId)}/$bellaChat';

  // Audit log
  static String auditLogDoc(String eventId) => '$auditLog/$eventId';

  // Doctor-level paths
  static String doctorDoc(String doctorId) => '$doctors/$doctorId';
  static String doctorDocumentsCollection(String doctorId) =>
      '${doctorDoc(doctorId)}/documents';

  // Aftercare path helpers
  static String systemAftercareTemplateDoc(String templateId) =>
      '$systemAftercareTemplates/$templateId';
  static String organizationAftercareTemplateDoc(String templateId) =>
      '$organizationAftercareTemplates/$templateId';
  static String doctorAftercareTemplateDoc(String templateId) =>
      '$doctorAftercareTemplates/$templateId';
  static String patientAftercarePlanDoc(String planId) =>
      '$patientAftercarePlans/$planId';
}

class StoragePaths {
  StoragePaths._();

  static String woundImage(
    String patientId,
    String entryId, {
    String ext = 'jpg',
  }) {
    return 'patients/$patientId/wounds/$entryId.$ext';
  }

  static String documentPdf(String patientId, String docId) {
    return 'patients/$patientId/documents/$docId.pdf';
  }

  static String photoImage(
    String patientId,
    String photoId, {
    String ext = 'jpg',
  }) {
    return 'patients/$patientId/photos/$photoId.$ext';
  }

  static String voiceMemoAudio(
    String patientId,
    String memoId, {
    String ext = 'm4a',
  }) {
    return 'patients/$patientId/voice_memos/$memoId.$ext';
  }

  static String observationAttachment(
    String patientId,
    String observationId, {
    String ext = 'jpg',
  }) {
    return 'patients/$patientId/observations/$observationId.$ext';
  }

  static String doctorDocument(
    String doctorId,
    String docId, {
    String ext = 'pdf',
  }) {
    return 'doctors/$doctorId/documents/$docId.$ext';
  }
}
