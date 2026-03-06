class FirestorePaths {
  FirestorePaths._();

  // Top-level collections
  static const String users = 'users';
  static const String patients = 'patients';
  static const String doctors = 'doctors';
  static const String doctorInvites = 'doctor_invites';

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

  static String userDoc(String uid) => '$users/$uid';
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

  // Audit log
  static String auditLogDoc(String eventId) => '$auditLog/$eventId';

  // Doctor-level paths
  static String doctorDoc(String doctorId) => '$doctors/$doctorId';
  static String doctorDocumentsCollection(String doctorId) =>
      '${doctorDoc(doctorId)}/documents';
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
