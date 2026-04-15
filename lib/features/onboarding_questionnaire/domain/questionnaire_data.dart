import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../security/field_encryption_service.dart';

/// All data collected during the patient onboarding questionnaire.
class QuestionnaireData {
  QuestionnaireData({
    this.opDate,
    required this.opType,
    required this.opModus,
    this.hospitalName,
    this.doctorName,
    this.preExistingConditions = const [],
    this.allergies = const [],
    this.currentMedications = const [],
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.weight,
    this.height,
    this.smokerStatus,
  });

  // ── Page 1: OP info (mandatory) ──
  final DateTime? opDate;
  final String opType;
  final String opModus; // "ambulant" | "stationär"

  // ── Page 2: Clinic & doctor ──
  final String? hospitalName;
  final String? doctorName;

  // ── Page 3: Health profile ──
  final List<String> preExistingConditions;
  final List<String> allergies;
  final List<String> currentMedications;
  final double? weight; // kg
  final double? height; // cm
  final String? smokerStatus; // "Nichtraucher" | "Raucher" | "Ex-Raucher"

  // ── Page 4: Emergency contact ──
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  /// Converts to a Firestore-compatible map for `users/{uid}`.
  ///
  /// [uid] is required to encrypt identifying fields (hospital, doctor,
  /// emergency contacts). Pass the current user's UID.
  Map<String, dynamic> toFirestore({String? uid}) {
    final enc = FieldEncryptionService.instance;
    String? e(String? v) =>
        uid != null ? enc.encryptField(uid, v) : v;

    return <String, dynamic>{
      if (opDate != null) 'opDate': opDate!.toIso8601String(),
      'opType': opType,
      'opModus': opModus,
      if (hospitalName != null && hospitalName!.isNotEmpty)
        'hospitalName': e(hospitalName) ?? hospitalName,
      if (doctorName != null && doctorName!.isNotEmpty)
        'doctorName': e(doctorName) ?? doctorName,
      if (preExistingConditions.isNotEmpty)
        'preExistingConditions': preExistingConditions,
      if (allergies.isNotEmpty) 'allergies': allergies,
      if (currentMedications.isNotEmpty)
        'currentMedications': currentMedications,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (smokerStatus != null && smokerStatus!.isNotEmpty)
        'smokerStatus': smokerStatus,
      if (emergencyContactName != null && emergencyContactName!.isNotEmpty)
        'emergencyContactName': e(emergencyContactName) ?? emergencyContactName,
      if (emergencyContactPhone != null && emergencyContactPhone!.isNotEmpty)
        'emergencyContactPhone': e(emergencyContactPhone) ?? emergencyContactPhone,
      'onboardingComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

/// A category of surgeries shown in the onboarding drill-down picker.
class SurgeryGroup {
  const SurgeryGroup({
    required this.category,
    required this.icon,
    required this.operations,
  });

  /// Display name of the category (German).
  final String category;

  /// Icon code point for visual identification.
  final int icon; // Icons.* codePoint

  /// Individual surgery types within this category.
  final List<String> operations;
}

/// All known surgery categories and their operations.
///
/// The [SurgeryGroup.category] is **not** stored – only the individual
/// operation string goes into Firestore `opType`.
const List<SurgeryGroup> kSurgeryGroups = [
  // ── Orthopädie — Knie ──
  SurgeryGroup(
    category: 'Knie',
    icon: 0xf04b6, // accessibility_new
    operations: [
      'Knie-TEP',
      'Knie-TEP-Wechsel',
      'Kreuzband-OP (VKB)',
      'Hintere Kreuzband-OP (HKB)',
      'Meniskus-OP',
      'Kniearthroskopie',
      'Umstellungsosteotomie (HTO)',
      'Patellastabilisierung',
      'Knorpeltransplantation',
      'Baker-Zysten-OP',
    ],
  ),
  // ── Orthopädie — Hüfte ──
  SurgeryGroup(
    category: 'Hüfte',
    icon: 0xf04b6,
    operations: [
      'Hüft-TEP',
      'Hüft-TEP-Wechsel',
      'Hüftarthroskopie',
      'Schenkelhalsfraktur-OP',
      'Hüftkopfnekrose-OP',
      'Periazetabuläre Osteotomie',
    ],
  ),
  // ── Orthopädie — Schulter ──
  SurgeryGroup(
    category: 'Schulter',
    icon: 0xf04b6,
    operations: [
      'Schulter-TEP',
      'Inverse Schulter-TEP',
      'Rotatorenmanschetten-OP',
      'Schulterarthroskopie',
      'Schulterstabilisierung (Bankart)',
      'AC-Gelenk-OP',
      'Impingement-OP',
      'Schulter-Dekompression',
    ],
  ),
  // ── Wirbelsäule ──
  SurgeryGroup(
    category: 'Wirbelsäule',
    icon: 0xe1d3, // straighten
    operations: [
      'Bandscheiben-OP (Diskektomie)',
      'Bandscheibenprothese',
      'Spinalkanalstenose-OP',
      'Spondylodese (Versteifung)',
      'Kyphoplastie / Vertebroplastie',
      'Laminektomie',
      'Skoliose-OP',
      'Facettengelenk-OP',
    ],
  ),
  // ── Hand & Handgelenk ──
  SurgeryGroup(
    category: 'Hand & Handgelenk',
    icon: 0xe263, // back_hand
    operations: [
      'Karpaltunnel-OP',
      'Dupuytren-OP',
      'Ganglion-Entfernung',
      'Sehnenscheiden-OP',
      'Handgelenksfraktur-OP',
      'Daumensattelgelenk-OP (Rhizarthrose)',
      'Finger-Replantation',
      'Handgelenksarthroskopie',
    ],
  ),
  // ── Fuß & Sprunggelenk ──
  SurgeryGroup(
    category: 'Fuß & Sprunggelenk',
    icon: 0xf04b6,
    operations: [
      'Hallux valgus-OP',
      'Achillessehnen-OP',
      'Sprunggelenksfraktur-OP',
      'Fersensporn-OP',
      'Hammerzehen-OP',
      'Sprunggelenksarthroskopie',
      'Mittelfußfraktur-OP',
      'Arthrodese (Versteifung)',
    ],
  ),
  // ── Herz- & Thoraxchirurgie ──
  SurgeryGroup(
    category: 'Herz & Thorax',
    icon: 0xe3e7, // favorite (heart)
    operations: [
      'Bypass-OP (CABG)',
      'Herzklappenersatz',
      'Herzklappen-Rekonstruktion',
      'Schrittmacher-Implantation',
      'Defibrillator-Implantation (ICD)',
      'Thorakoskopie (VATS)',
      'Lungen-OP (Lobektomie)',
      'Aortenaneurysma-OP',
      'Mediastinoskopie',
    ],
  ),
  // ── Viszeralchirurgie (Bauch) ──
  SurgeryGroup(
    category: 'Bauch & Verdauung',
    icon: 0xf0624, // gastroenterology (fallback)
    operations: [
      'Appendektomie (Blinddarm)',
      'Cholezystektomie (Gallenblase)',
      'Leistenhernie-OP',
      'Nabelhernie-OP',
      'Narbenhernie-OP',
      'Darm-OP (Resektion)',
      'Magen-Bypass / Schlauchmagen',
      'Schilddrüsen-OP',
      'Milz-OP (Splenektomie)',
      'Leber-OP (Resektion)',
      'Pankreas-OP',
    ],
  ),
  // ── Urologie ──
  SurgeryGroup(
    category: 'Urologie',
    icon: 0xe548, // medical_services
    operations: [
      'Prostata-OP (TUR-P)',
      'Radikale Prostatektomie',
      'Nieren-OP (Nephrektomie)',
      'Blasen-OP',
      'Nierenstein-OP (URS / PCNL)',
      'Vasektomie',
      'Zirkumzision',
      'Hoden-OP (Orchidopexie)',
      'Nebennierenentfernung',
    ],
  ),
  // ── Gynäkologie ──
  SurgeryGroup(
    category: 'Gynäkologie',
    icon: 0xe548,
    operations: [
      'Hysterektomie',
      'Kaiserschnitt (Sectio)',
      'Myom-Entfernung',
      'Eierstock-OP',
      'Brust-OP (Mastektomie)',
      'Brusterhaltende OP',
      'Gebärmutterspiegelung',
      'Endometriose-OP',
      'Eileiterschwangerschaft-OP',
      'Beckenboden-OP',
    ],
  ),
  // ── HNO ──
  SurgeryGroup(
    category: 'HNO',
    icon: 0xe023, // hearing
    operations: [
      'Tonsillektomie (Mandeln)',
      'Nasennebenhöhlen-OP (FESS)',
      'Septumplastik (Nasenscheidewand)',
      'Ohren-OP (Tympanoplastik)',
      'Adenotomie (Polypen)',
      'Parotidektomie (Speicheldrüse)',
      'Cochlea-Implantat',
      'Kehlkopf-OP (Laryngoskopie)',
      'Nasenmuschel-OP',
    ],
  ),
  // ── Augenheilkunde ──
  SurgeryGroup(
    category: 'Augenheilkunde',
    icon: 0xe8f4, // visibility
    operations: [
      'Katarakt-OP (Grauer Star)',
      'Glaukom-OP (Grüner Star)',
      'Vitrektomie (Glaskörper)',
      'Netzhaut-OP',
      'Schiel-OP',
      'Lidkorrektur (Blepharoplastik)',
      'Hornhauttransplantation',
      'Lasik / PRK',
    ],
  ),
  // ── Neurochirurgie ──
  SurgeryGroup(
    category: 'Neurochirurgie',
    icon: 0xe7fb, // psychology
    operations: [
      'Hirntumor-OP',
      'Aneurysma-Clipping',
      'Shunt-OP (Hydrozephalus)',
      'Trigeminusneuralgie-OP',
      'Epilepsie-OP',
      'Tiefe Hirnstimulation (DBS)',
    ],
  ),
  // ── Gefäßchirurgie ──
  SurgeryGroup(
    category: 'Gefäßchirurgie',
    icon: 0xe0b1, // timeline
    operations: [
      'Krampfadern-OP (Varizen)',
      'Carotis-OP (Halsschlagader)',
      'Peripherer Gefäß-Bypass',
      'Dialyse-Shunt-OP',
      'Thrombektomie',
      'Stent-Implantation',
    ],
  ),
  // ── Plastische Chirurgie ──
  SurgeryGroup(
    category: 'Plastische Chirurgie',
    icon: 0xe548,
    operations: [
      'Hauttransplantation',
      'Brustvergrößerung',
      'Brustverkleinerung',
      'Bauchdeckenstraffung',
      'Narbenkorrektur',
      'Rekonstruktive OP',
      'Fettabsaugung (Liposuktion)',
    ],
  ),
  // ── MKG (Mund-Kiefer-Gesicht) ──
  SurgeryGroup(
    category: 'Mund-Kiefer-Gesicht',
    icon: 0xe7fd, // face
    operations: [
      'Weisheitszahn-OP',
      'Kieferkorrektur (Dysgnathie)',
      'Implantat-OP',
      'Kieferbruch-OP',
      'Kieferzysten-OP',
      'Kiefergelenk-OP',
    ],
  ),
];

/// Flat list of all known surgery types across all categories.
///
/// Used for backward-compatible references where a simple `List<String>`
/// is expected (e.g. profile checks, aftercare builder).
List<String> get kSurgeryTypes =>
    kSurgeryGroups.expand((g) => g.operations).toList();
