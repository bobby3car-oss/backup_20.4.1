class FirestorePaths {
  FirestorePaths._();

  // Top-level collections
  static const String users = 'users';
  static const String patients = 'patients';

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

  static String linkDoc(String patientId, String linkId) =>
      '${linksCollection(patientId)}/$linkId';
  static String inviteDoc(String patientId, String inviteId) =>
      '${invitesCollection(patientId)}/$inviteId';
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
}
