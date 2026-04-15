import 'timeline_engine.dart';

// ── Surgery category ────────────────────────────────────────────────

/// Groups the individual surgery types ([kSurgeryTypes]) into clinically
/// meaningful categories that determine which care-plan templates are
/// generated.
enum SurgeryCategory {
  /// Knie-TEP, Hüft-TEP, Kreuzband-OP, Meniskus-OP, Schulter-OP, etc.
  orthoJoint,

  /// Wirbelsäulen-OP, Bandscheiben-OP, Spondylodese, etc.
  spine,

  /// Hand-, Handgelenk-, Fuß- und Sprunggelenk-OPs
  orthoExtremity,

  /// Bypass-OP, Herzklappe, Schrittmacher, Lungen-OP, etc.
  cardioThoracic,

  /// Appendektomie, Cholezystektomie, Hernie, Darm-OP, etc.
  abdominal,

  /// Prostata-OP, Nieren-OP, Blasen-OP, etc.
  urology,

  /// Hysterektomie, Sectio, Myom-OP, Brust-OP, etc.
  gynecology,

  /// Tonsillektomie, FESS, Septumplastik, etc.
  ent,

  /// Katarakt-OP, Glaukom-OP, Vitrektomie, etc.
  ophthalmology,

  /// Hirntumor-OP, Aneurysma-Clipping, Shunt-OP, etc.
  neuro,

  /// Krampfadern-OP, Carotis-OP, Bypass peripherer Gefäße, etc.
  vascular,

  /// Plastische & rekonstruktive Chirurgie
  plastic,

  /// Weisheitszahn-OP, Kieferkorrektur, Implantat-OP, etc.
  maxillofacial,

  /// Sonstiges / unbekannter Typ – only universal templates
  general;

  /// Maps a user-facing surgery-type string (as stored in Firestore
  /// `opType`) to a [SurgeryCategory].
  static SurgeryCategory fromOpType(String? opType) {
    if (opType == null || opType.isEmpty) return general;
    switch (opType) {
      // ── Orthopädie — Gelenke (Knie, Hüfte, Schulter) ──
      case 'Knie-TEP':
      case 'Knie-TEP-Wechsel':
      case 'Kreuzband-OP (VKB)':
      case 'Hintere Kreuzband-OP (HKB)':
      case 'Meniskus-OP':
      case 'Kniearthroskopie':
      case 'Umstellungsosteotomie (HTO)':
      case 'Patellastabilisierung':
      case 'Knorpeltransplantation':
      case 'Baker-Zysten-OP':
      case 'Hüft-TEP':
      case 'Hüft-TEP-Wechsel':
      case 'Hüftarthroskopie':
      case 'Schenkelhalsfraktur-OP':
      case 'Hüftkopfnekrose-OP':
      case 'Periazetabuläre Osteotomie':
      case 'Schulter-TEP':
      case 'Inverse Schulter-TEP':
      case 'Rotatorenmanschetten-OP':
      case 'Schulterarthroskopie':
      case 'Schulterstabilisierung (Bankart)':
      case 'AC-Gelenk-OP':
      case 'Impingement-OP':
      case 'Schulter-Dekompression':
      // Legacy values
      case 'Kreuzband-OP':
      case 'Schulter-OP':
        return orthoJoint;

      // ── Wirbelsäule ──
      case 'Bandscheiben-OP (Diskektomie)':
      case 'Bandscheibenprothese':
      case 'Spinalkanalstenose-OP':
      case 'Spondylodese (Versteifung)':
      case 'Kyphoplastie / Vertebroplastie':
      case 'Laminektomie':
      case 'Skoliose-OP':
      case 'Facettengelenk-OP':
      case 'Wirbelsäulen-OP':
        return spine;

      // ── Hand / Handgelenk / Fuß / Sprunggelenk ──
      case 'Karpaltunnel-OP':
      case 'Dupuytren-OP':
      case 'Ganglion-Entfernung':
      case 'Sehnenscheiden-OP':
      case 'Handgelenksfraktur-OP':
      case 'Daumensattelgelenk-OP (Rhizarthrose)':
      case 'Finger-Replantation':
      case 'Handgelenksarthroskopie':
      case 'Hallux valgus-OP':
      case 'Achillessehnen-OP':
      case 'Sprunggelenksfraktur-OP':
      case 'Fersensporn-OP':
      case 'Hammerzehen-OP':
      case 'Sprunggelenksarthroskopie':
      case 'Mittelfußfraktur-OP':
      case 'Arthrodese (Versteifung)':
        return orthoExtremity;

      // ── Herz- & Thoraxchirurgie ──
      case 'Bypass-OP (CABG)':
      case 'Herzklappenersatz':
      case 'Herzklappen-Rekonstruktion':
      case 'Schrittmacher-Implantation':
      case 'Defibrillator-Implantation (ICD)':
      case 'Thorakoskopie (VATS)':
      case 'Lungen-OP (Lobektomie)':
      case 'Aortenaneurysma-OP':
      case 'Mediastinoskopie':
      case 'Herz-OP':
        return cardioThoracic;

      // ── Viszeralchirurgie / Bauch ──
      case 'Appendektomie (Blinddarm)':
      case 'Cholezystektomie (Gallenblase)':
      case 'Leistenhernie-OP':
      case 'Nabelhernie-OP':
      case 'Narbenhernie-OP':
      case 'Darm-OP (Resektion)':
      case 'Magen-Bypass / Schlauchmagen':
      case 'Schilddrüsen-OP':
      case 'Milz-OP (Splenektomie)':
      case 'Leber-OP (Resektion)':
      case 'Pankreas-OP':
      case 'Bauch-OP':
        return abdominal;

      // ── Urologie ──
      case 'Prostata-OP (TUR-P)':
      case 'Radikale Prostatektomie':
      case 'Nieren-OP (Nephrektomie)':
      case 'Blasen-OP':
      case 'Nierenstein-OP (URS / PCNL)':
      case 'Vasektomie':
      case 'Zirkumzision':
      case 'Hoden-OP (Orchidopexie)':
      case 'Nebennierenentfernung':
        return urology;

      // ── Gynäkologie ──
      case 'Hysterektomie':
      case 'Kaiserschnitt (Sectio)':
      case 'Myom-Entfernung':
      case 'Eierstock-OP':
      case 'Brust-OP (Mastektomie)':
      case 'Brusterhaltende OP':
      case 'Gebärmutterspiegelung':
      case 'Endometriose-OP':
      case 'Eileiterschwangerschaft-OP':
      case 'Beckenboden-OP':
        return gynecology;

      // ── HNO ──
      case 'Tonsillektomie (Mandeln)':
      case 'Nasennebenhöhlen-OP (FESS)':
      case 'Septumplastik (Nasenscheidewand)':
      case 'Ohren-OP (Tympanoplastik)':
      case 'Adenotomie (Polypen)':
      case 'Parotidektomie (Speicheldrüse)':
      case 'Cochlea-Implantat':
      case 'Kehlkopf-OP (Laryngoskopie)':
      case 'Nasenmuschel-OP':
        return ent;

      // ── Augenheilkunde ──
      case 'Katarakt-OP (Grauer Star)':
      case 'Glaukom-OP (Grüner Star)':
      case 'Vitrektomie (Glaskörper)':
      case 'Netzhaut-OP':
      case 'Schiel-OP':
      case 'Lidkorrektur (Blepharoplastik)':
      case 'Hornhauttransplantation':
      case 'Lasik / PRK':
        return ophthalmology;

      // ── Neurochirurgie ──
      case 'Hirntumor-OP':
      case 'Aneurysma-Clipping':
      case 'Shunt-OP (Hydrozephalus)':
      case 'Trigeminusneuralgie-OP':
      case 'Epilepsie-OP':
      case 'Tiefe Hirnstimulation (DBS)':
        return neuro;

      // ── Gefäßchirurgie ──
      case 'Krampfadern-OP (Varizen)':
      case 'Carotis-OP (Halsschlagader)':
      case 'Peripherer Gefäß-Bypass':
      case 'Dialyse-Shunt-OP':
      case 'Thrombektomie':
      case 'Stent-Implantation':
        return vascular;

      // ── Plastische Chirurgie ──
      case 'Hauttransplantation':
      case 'Brustvergrößerung':
      case 'Brustverkleinerung':
      case 'Bauchdeckenstraffung':
      case 'Narbenkorrektur':
      case 'Rekonstruktive OP':
      case 'Fettabsaugung (Liposuktion)':
        return plastic;

      // ── MKG ──
      case 'Weisheitszahn-OP':
      case 'Kieferkorrektur (Dysgnathie)':
      case 'Implantat-OP':
      case 'Kieferbruch-OP':
      case 'Kieferzysten-OP':
      case 'Kiefergelenk-OP':
        return maxillofacial;

      default:
        return general;
    }
  }
}

// ── Task template ───────────────────────────────────────────────────

class TaskTemplate {
  const TaskTemplate({
    required this.templateId,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.priority,
    required this.deeplinkRoute,
    required this.phase,
    required this.relativeDay,
    required this.timeOfDay,
    this.dueHoursAfterScheduled,
    this.repeatEveryDays,
    this.repeatCount,
    this.metadataDefaults = const <String, dynamic>{},
    this.applicableTo = const <SurgeryCategory>{},
    this.stationaerOnly = false,
    this.ambulantOnly = false,
  });

  final String templateId;
  final TaskType type;
  final String title;
  final String subtitle;
  final TaskPriority priority;
  final String deeplinkRoute;
  final String phase;
  final int relativeDay;
  final String timeOfDay;
  final int? dueHoursAfterScheduled;
  final int? repeatEveryDays;
  final int? repeatCount;
  final Map<String, dynamic> metadataDefaults;

  /// Which surgery categories this template applies to.
  /// An **empty** set means the template is universal (all categories).
  final Set<SurgeryCategory> applicableTo;

  /// If `true`, the template is only generated for patients with
  /// `opModus == 'stationär'`.
  final bool stationaerOnly;

  /// If `true`, the template is only generated for patients with
  /// `opModus == 'ambulant'`.
  final bool ambulantOnly;
}

// ── Care-plan templates ─────────────────────────────────────────────
//
// Templates with an **empty** [applicableTo] set are universal and
// generated for every surgery category. Templates with specific
// categories are only generated when the patient's surgery matches.

const List<TaskTemplate> carePlanTemplates = <TaskTemplate>[
  // ═══════════════════════════════════════════════════════════════════
  // ── Vorbereitung (preop) ── universal ─────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  TaskTemplate(
    templateId: 'preop_documents',
    type: TaskType.checklist,
    title: 'Unterlagen prüfen',
    subtitle: 'Versichertenkarte und Befunde bereitlegen',
    priority: TaskPriority.high,
    deeplinkRoute: '/documents',
    phase: 'preop',
    relativeDay: -2,
    timeOfDay: '09:00',
    dueHoursAfterScheduled: 12,
  ),
  TaskTemplate(
    templateId: 'preop_companion',
    type: TaskType.message,
    title: 'Begleitperson informieren',
    subtitle: 'Anfahrt und Treffpunkt abstimmen',
    priority: TaskPriority.normal,
    deeplinkRoute: '',
    phase: 'preop',
    relativeDay: -1,
    timeOfDay: '18:00',
    dueHoursAfterScheduled: 4,
  ),
  TaskTemplate(
    templateId: 'preop_bag',
    type: TaskType.checklist,
    title: 'Klinik-Tasche packen',
    subtitle: 'Dokumente, Kleidung und Ladegerät einpacken',
    priority: TaskPriority.high,
    deeplinkRoute: '/packing',
    phase: 'preop',
    relativeDay: -1,
    timeOfDay: '20:00',
    dueHoursAfterScheduled: 10,
    stationaerOnly: true,
  ),

  // ═══════════════════════════════════════════════════════════════════
  // ── OP-Tag (opday) ────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  TaskTemplate(
    templateId: 'opday_admission',
    type: TaskType.appointment,
    title: 'Aufnahme',
    subtitle: 'Bitte pünktlich in der Klinik melden',
    priority: TaskPriority.critical,
    deeplinkRoute: '/appointment',
    phase: 'opday',
    relativeDay: 0,
    timeOfDay: '07:00',
    dueHoursAfterScheduled: 2,
    stationaerOnly: true,
    metadataDefaults: <String, dynamic>{'milestone': 'Aufnahme'},
  ),
  TaskTemplate(
    templateId: 'opday_fasting',
    type: TaskType.checklist,
    title: 'Nüchternheit prüfen',
    subtitle: 'Nichts essen oder trinken laut Anweisung',
    priority: TaskPriority.critical,
    deeplinkRoute: '',
    phase: 'opday',
    relativeDay: 0,
    timeOfDay: '06:00',
    dueHoursAfterScheduled: 2,
  ),
  TaskTemplate(
    templateId: 'opday_info',
    type: TaskType.message,
    title: 'OP-Infos bestätigen',
    subtitle: 'Offene Rückfragen mit Team klären',
    priority: TaskPriority.high,
    deeplinkRoute: '/op-info',
    phase: 'opday',
    relativeDay: 0,
    timeOfDay: '08:30',
    dueHoursAfterScheduled: 3,
  ),
  TaskTemplate(
    templateId: 'opday_mobilization',
    type: TaskType.custom,
    title: 'Erste Mobilisation',
    subtitle: 'Mit Unterstützung kurz aufsetzen/aufstehen',
    priority: TaskPriority.normal,
    deeplinkRoute: '/rehab',
    phase: 'opday',
    relativeDay: 0,
    timeOfDay: '18:00',
    dueHoursAfterScheduled: 6,
    stationaerOnly: true,
  ),

  // ═══════════════════════════════════════════════════════════════════
  // ── Woche 1 · universal ──────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  TaskTemplate(
    templateId: 'week1_wound_photo',
    type: TaskType.wound,
    title: 'Wundfoto aufnehmen',
    subtitle: 'Foto für Verlauf dokumentieren',
    priority: TaskPriority.normal,
    deeplinkRoute: '/wound-editor',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '19:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 8,
  ),
  TaskTemplate(
    templateId: 'week1_pain_score',
    type: TaskType.custom,
    title: 'Schmerzstärke erfassen',
    subtitle: 'Schmerzlevel in der App eintragen',
    priority: TaskPriority.normal,
    deeplinkRoute: '/pain',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '12:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 8,
  ),
  TaskTemplate(
    templateId: 'week1_vitals',
    type: TaskType.custom,
    title: 'Vitalwerte prüfen',
    subtitle: 'Puls/Temperatur kurz notieren',
    priority: TaskPriority.normal,
    deeplinkRoute: '/vitals',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '09:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 8,
  ),
  TaskTemplate(
    templateId: 'week1_dressing',
    type: TaskType.wound,
    title: 'Verbandkontrolle',
    subtitle: 'Verbandzustand prüfen und dokumentieren',
    priority: TaskPriority.high,
    deeplinkRoute: '/wound-editor',
    phase: 'week1',
    relativeDay: 2,
    timeOfDay: '10:00',
    dueHoursAfterScheduled: 8,
  ),
  TaskTemplate(
    templateId: 'meds_morning',
    type: TaskType.meds,
    title: 'Medikation einnehmen',
    subtitle: 'Morgendosis laut Plan',
    priority: TaskPriority.high,
    deeplinkRoute: '/meds',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '08:00',
    dueHoursAfterScheduled: 2,
    repeatEveryDays: 1,
    repeatCount: 14,
  ),
  TaskTemplate(
    templateId: 'meds_midday',
    type: TaskType.meds,
    title: 'Medikation einnehmen',
    subtitle: 'Mittagsdosis laut Plan',
    priority: TaskPriority.high,
    deeplinkRoute: '/meds',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '13:00',
    dueHoursAfterScheduled: 2,
    repeatEveryDays: 1,
    repeatCount: 14,
  ),
  TaskTemplate(
    templateId: 'meds_evening',
    type: TaskType.meds,
    title: 'Medikation einnehmen',
    subtitle: 'Abenddosis laut Plan',
    priority: TaskPriority.high,
    deeplinkRoute: '/meds',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '20:00',
    dueHoursAfterScheduled: 2,
    repeatEveryDays: 1,
    repeatCount: 14,
  ),
  TaskTemplate(
    templateId: 'week1_hydration',
    type: TaskType.checklist,
    title: 'Trinkmenge prüfen',
    subtitle: 'Mindestens 1,5 Liter Flüssigkeit am Tag',
    priority: TaskPriority.normal,
    deeplinkRoute: '/nutrition',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '15:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 14,
  ),
  TaskTemplate(
    templateId: 'week1_redflags',
    type: TaskType.checklist,
    title: 'Warnsignale prüfen',
    subtitle: 'Fieber, Rötung, Schwellung, starke Schmerzen?',
    priority: TaskPriority.high,
    deeplinkRoute: '/alerts',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '21:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 14,
  ),

  // ═══════════════════════════════════════════════════════════════════
  // ── Woche 1 · Orthopädie (Gelenke) ──────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  TaskTemplate(
    templateId: 'week1_compression',
    type: TaskType.checklist,
    title: 'Kompressionsstrümpfe prüfen',
    subtitle: 'Sitz und Zustand der Strümpfe kontrollieren',
    priority: TaskPriority.normal,
    deeplinkRoute: '',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '07:30',
    dueHoursAfterScheduled: 4,
    repeatEveryDays: 1,
    repeatCount: 14,
    applicableTo: <SurgeryCategory>{
      SurgeryCategory.orthoJoint,
      SurgeryCategory.spine,
    },
  ),
  TaskTemplate(
    templateId: 'week1_leg_exercises',
    type: TaskType.custom,
    title: 'Beinübungen durchführen',
    subtitle: 'Füße kreisen, Beine anspannen – Thromboseprophylaxe',
    priority: TaskPriority.normal,
    deeplinkRoute: '/rehab',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '10:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 14,
    applicableTo: <SurgeryCategory>{SurgeryCategory.orthoJoint},
  ),
  TaskTemplate(
    templateId: 'week1_mobilization',
    type: TaskType.custom,
    title: 'Kurz aufstehen & bewegen',
    subtitle: 'Langsam mobilisieren – auch kleine Schritte zählen',
    priority: TaskPriority.normal,
    deeplinkRoute: '/rehab',
    phase: 'week1',
    relativeDay: 1,
    timeOfDay: '11:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{
      SurgeryCategory.orthoJoint,
      SurgeryCategory.spine,
    },
  ),
  TaskTemplate(
    templateId: 'week1_joint_rom',
    type: TaskType.custom,
    title: 'Gelenk-Beweglichkeit prüfen',
    subtitle: 'Beugung und Streckung vorsichtig testen',
    priority: TaskPriority.normal,
    deeplinkRoute: '/rehab',
    phase: 'week1',
    relativeDay: 2,
    timeOfDay: '10:30',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 6,
    applicableTo: <SurgeryCategory>{SurgeryCategory.orthoJoint},
  ),

  // ── Woche 1 · Herz-Thorax ───────────────────────────────────────
  TaskTemplate(
    templateId: 'week1_breathing_cardio',
    type: TaskType.custom,
    title: 'Atemübungen',
    subtitle: 'Tiefe Atemzüge zur Lungenpflege – besonders wichtig nach Herz-OP',
    priority: TaskPriority.high,
    deeplinkRoute: '/rehab',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '10:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 14,
    applicableTo: <SurgeryCategory>{SurgeryCategory.cardioThoracic},
  ),
  TaskTemplate(
    templateId: 'week1_sternum_protection',
    type: TaskType.checklist,
    title: 'Brustbein-Schonung',
    subtitle: 'Kein Heben über 5 kg, Arme eng am Körper halten',
    priority: TaskPriority.high,
    deeplinkRoute: '',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '08:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 14,
    applicableTo: <SurgeryCategory>{SurgeryCategory.cardioThoracic},
  ),
  TaskTemplate(
    templateId: 'week1_blood_pressure',
    type: TaskType.custom,
    title: 'Blutdruck messen',
    subtitle: 'Werte morgens und abends dokumentieren',
    priority: TaskPriority.normal,
    deeplinkRoute: '/vitals',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '07:30',
    dueHoursAfterScheduled: 4,
    repeatEveryDays: 1,
    repeatCount: 14,
    applicableTo: <SurgeryCategory>{SurgeryCategory.cardioThoracic},
  ),
  TaskTemplate(
    templateId: 'week1_cardiac_rehab',
    type: TaskType.custom,
    title: 'Herzreha-Übungen',
    subtitle: 'Leichtes Gehen, Kreislauf langsam aufbauen',
    priority: TaskPriority.normal,
    deeplinkRoute: '/rehab',
    phase: 'week1',
    relativeDay: 3,
    timeOfDay: '11:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 5,
    applicableTo: <SurgeryCategory>{SurgeryCategory.cardioThoracic},
  ),

  // ── Woche 1 · Bauch / Viszeralchirurgie ─────────────────────────
  TaskTemplate(
    templateId: 'week1_diet_buildup',
    type: TaskType.nutrition,
    title: 'Kostaufbau',
    subtitle: 'Leichte Kost, Schonkost → langsam steigern',
    priority: TaskPriority.normal,
    deeplinkRoute: '/nutrition',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '12:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.abdominal},
  ),
  TaskTemplate(
    templateId: 'week1_no_straining',
    type: TaskType.checklist,
    title: 'Bauchmuskel-Schonung',
    subtitle: 'Nicht pressen, beim Aufstehen seitlich abrollen',
    priority: TaskPriority.high,
    deeplinkRoute: '',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '08:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 14,
    applicableTo: <SurgeryCategory>{SurgeryCategory.abdominal},
  ),
  TaskTemplate(
    templateId: 'week1_abdominal_support',
    type: TaskType.checklist,
    title: 'Bauchgürtel/Stütze prüfen',
    subtitle: 'Sitz und Trageweise kontrollieren',
    priority: TaskPriority.normal,
    deeplinkRoute: '',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '07:30',
    dueHoursAfterScheduled: 4,
    repeatEveryDays: 1,
    repeatCount: 14,
    applicableTo: <SurgeryCategory>{SurgeryCategory.abdominal},
  ),
  TaskTemplate(
    templateId: 'week1_bowel_diary',
    type: TaskType.custom,
    title: 'Stuhlgang dokumentieren',
    subtitle: 'Verdauung beobachten – wichtig für Kostaufbau',
    priority: TaskPriority.normal,
    deeplinkRoute: '/nutrition',
    phase: 'week1',
    relativeDay: 1,
    timeOfDay: '18:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.abdominal},
  ),

  // ── Woche 1 · Wirbelsäule ───────────────────────────────────────
  TaskTemplate(
    templateId: 'week1_back_posture',
    type: TaskType.checklist,
    title: 'Rücken-Schonhaltung',
    subtitle: 'Keine Dreh- oder Beugebewegungen der Wirbelsäule',
    priority: TaskPriority.high,
    deeplinkRoute: '',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '08:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 14,
    applicableTo: <SurgeryCategory>{SurgeryCategory.spine},
  ),
  TaskTemplate(
    templateId: 'week1_orthosis',
    type: TaskType.checklist,
    title: 'Orthese/Korsett prüfen',
    subtitle: 'Sitz und Tragezeit kontrollieren',
    priority: TaskPriority.normal,
    deeplinkRoute: '',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '07:30',
    dueHoursAfterScheduled: 4,
    repeatEveryDays: 1,
    repeatCount: 14,
    applicableTo: <SurgeryCategory>{SurgeryCategory.spine},
  ),
  TaskTemplate(
    templateId: 'week1_breathing_spine',
    type: TaskType.custom,
    title: 'Atemübungen',
    subtitle: 'Tiefe Atemzüge – Rücken gerade, sanft atmen',
    priority: TaskPriority.normal,
    deeplinkRoute: '/rehab',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '14:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.spine},
  ),
  TaskTemplate(
    templateId: 'week1_spine_stabilization',
    type: TaskType.custom,
    title: 'Stabilisationsübungen',
    subtitle: 'Rumpf-Stabilisation nach Anleitung – langsam steigern',
    priority: TaskPriority.normal,
    deeplinkRoute: '/rehab',
    phase: 'week1',
    relativeDay: 3,
    timeOfDay: '11:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 5,
    applicableTo: <SurgeryCategory>{SurgeryCategory.spine},
  ),

  // ═══════════════════════════════════════════════════════════════════
  // ── Woche 2 · universal ──────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  TaskTemplate(
    templateId: 'week2_wound_observe',
    type: TaskType.wound,
    title: 'Wunde beobachten',
    subtitle: 'Heilungsverlauf kontrollieren und dokumentieren',
    priority: TaskPriority.normal,
    deeplinkRoute: '/wound-editor',
    phase: 'week2',
    relativeDay: 8,
    timeOfDay: '09:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 7,
  ),
  TaskTemplate(
    templateId: 'week2_pain',
    type: TaskType.custom,
    title: 'Schmerztagebuch',
    subtitle: 'Schmerzverlauf dokumentieren – wird es besser?',
    priority: TaskPriority.normal,
    deeplinkRoute: '/pain',
    phase: 'week2',
    relativeDay: 8,
    timeOfDay: '12:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 7,
  ),

  // ── Woche 2 · Orthopädie ────────────────────────────────────────
  TaskTemplate(
    templateId: 'week2_walk',
    type: TaskType.custom,
    title: 'Spaziergang machen',
    subtitle: 'Täglich etwas weiter gehen – Kreislauf stärken',
    priority: TaskPriority.normal,
    deeplinkRoute: '/rehab',
    phase: 'week2',
    relativeDay: 8,
    timeOfDay: '10:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{
      SurgeryCategory.orthoJoint,
      SurgeryCategory.spine,
    },
  ),
  TaskTemplate(
    templateId: 'week2_physio',
    type: TaskType.custom,
    title: 'Physiotherapie-Übungen',
    subtitle: 'Übungen laut Anleitung durchführen',
    priority: TaskPriority.normal,
    deeplinkRoute: '/rehab',
    phase: 'week2',
    relativeDay: 8,
    timeOfDay: '15:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{
      SurgeryCategory.orthoJoint,
      SurgeryCategory.spine,
    },
  ),
  TaskTemplate(
    templateId: 'week2_gait_training',
    type: TaskType.custom,
    title: 'Gangtraining',
    subtitle: 'Sicheres Gehen mit/ohne Hilfsmittel üben',
    priority: TaskPriority.normal,
    deeplinkRoute: '/rehab',
    phase: 'week2',
    relativeDay: 8,
    timeOfDay: '11:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.orthoJoint},
  ),

  // ── Woche 2 · Herz-Thorax ──────────────────────────────────────
  TaskTemplate(
    templateId: 'week2_cardiac_walk',
    type: TaskType.custom,
    title: 'Herzreha-Spaziergang',
    subtitle: 'Gehstrecke langsam steigern, Puls beobachten',
    priority: TaskPriority.normal,
    deeplinkRoute: '/rehab',
    phase: 'week2',
    relativeDay: 8,
    timeOfDay: '10:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.cardioThoracic},
  ),

  // ── Woche 2 · Bauch ─────────────────────────────────────────────
  TaskTemplate(
    templateId: 'week2_diet_normalize',
    type: TaskType.nutrition,
    title: 'Normalkost aufbauen',
    subtitle: 'Verdauung beobachten – langsam zur Normalkost',
    priority: TaskPriority.normal,
    deeplinkRoute: '/nutrition',
    phase: 'week2',
    relativeDay: 8,
    timeOfDay: '12:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.abdominal},
  ),

  // ═══════════════════════════════════════════════════════════════════
  // ── Nachkontrolle (followup) · universal ─────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  TaskTemplate(
    templateId: 'followup_day7',
    type: TaskType.appointment,
    title: 'Kontrolltermin',
    subtitle: 'Verlaufskontrolle in der Praxis',
    priority: TaskPriority.high,
    deeplinkRoute: '/appointment',
    phase: 'followup',
    relativeDay: 7,
    timeOfDay: '09:00',
    dueHoursAfterScheduled: 6,
    metadataDefaults: <String, dynamic>{'milestone': 'Kontrolltermin'},
  ),
  TaskTemplate(
    templateId: 'followup_day14',
    type: TaskType.appointment,
    title: 'Kontrolltermin',
    subtitle: 'Zweite Verlaufskontrolle',
    priority: TaskPriority.high,
    deeplinkRoute: '/appointment',
    phase: 'followup',
    relativeDay: 14,
    timeOfDay: '09:00',
    dueHoursAfterScheduled: 6,
    metadataDefaults: <String, dynamic>{'milestone': 'Kontrolltermin'},
  ),
  TaskTemplate(
    templateId: 'followup_scar_care',
    type: TaskType.custom,
    title: 'Narbenpflege',
    subtitle: 'Narbe sanft eincremen und beobachten',
    priority: TaskPriority.normal,
    deeplinkRoute: '/wound-editor',
    phase: 'followup',
    relativeDay: 14,
    timeOfDay: '09:30',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 14,
  ),
  TaskTemplate(
    templateId: 'followup_activity',
    type: TaskType.custom,
    title: 'Belastung steigern',
    subtitle: 'Aktivität langsam erhöhen – auf Körpersignale achten',
    priority: TaskPriority.normal,
    deeplinkRoute: '/rehab',
    phase: 'followup',
    relativeDay: 15,
    timeOfDay: '10:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 14,
  ),
  TaskTemplate(
    templateId: 'followup_wound_photo',
    type: TaskType.wound,
    title: 'Wundfoto aufnehmen',
    subtitle: 'Heilungsverlauf weiter dokumentieren',
    priority: TaskPriority.normal,
    deeplinkRoute: '/wound-editor',
    phase: 'followup',
    relativeDay: 15,
    timeOfDay: '09:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 3,
    repeatCount: 5,
  ),
  TaskTemplate(
    templateId: 'followup_weekly_check',
    type: TaskType.custom,
    title: 'Wöchentlicher Selbst-Check',
    subtitle: 'Heilungsfortschritt bewerten und dokumentieren',
    priority: TaskPriority.normal,
    deeplinkRoute: '/pain',
    phase: 'followup',
    relativeDay: 15,
    timeOfDay: '18:00',
    dueHoursAfterScheduled: 12,
    repeatEveryDays: 7,
    repeatCount: 3,
  ),
  TaskTemplate(
    templateId: 'followup_day21',
    type: TaskType.appointment,
    title: 'Kontrolltermin',
    subtitle: 'Dritte Verlaufskontrolle',
    priority: TaskPriority.high,
    deeplinkRoute: '/appointment',
    phase: 'followup',
    relativeDay: 21,
    timeOfDay: '09:00',
    dueHoursAfterScheduled: 6,
    metadataDefaults: <String, dynamic>{'milestone': 'Kontrolltermin'},
  ),
  TaskTemplate(
    templateId: 'followup_day28',
    type: TaskType.appointment,
    title: 'Abschlusskontrolle',
    subtitle: 'Abschließende Untersuchung und Freigabe',
    priority: TaskPriority.high,
    deeplinkRoute: '/appointment',
    phase: 'followup',
    relativeDay: 28,
    timeOfDay: '09:00',
    dueHoursAfterScheduled: 6,
    metadataDefaults: <String, dynamic>{'milestone': 'Abschlusskontrolle'},
  ),

  // ═══════════════════════════════════════════════════════════════════
  // ── Hand/Fuß (orthoExtremity) ────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  TaskTemplate(
    templateId: 'week1_splint_check',
    type: TaskType.checklist,
    title: 'Schiene / Gips prüfen',
    subtitle: 'Sitz, Schwellung und Durchblutung kontrollieren',
    priority: TaskPriority.high,
    deeplinkRoute: '',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '08:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 14,
    applicableTo: <SurgeryCategory>{SurgeryCategory.orthoExtremity},
  ),
  TaskTemplate(
    templateId: 'week1_elevation',
    type: TaskType.checklist,
    title: 'Hochlagern',
    subtitle: 'Hand/Fuß regelmäßig hochlagern – Schwellung reduzieren',
    priority: TaskPriority.normal,
    deeplinkRoute: '',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '09:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.orthoExtremity},
  ),
  TaskTemplate(
    templateId: 'week1_finger_toe_exercises',
    type: TaskType.custom,
    title: 'Finger/Zehen bewegen',
    subtitle: 'Durchblutung fördern – sanfte Bewegungsübungen',
    priority: TaskPriority.normal,
    deeplinkRoute: '/rehab',
    phase: 'week1',
    relativeDay: 1,
    timeOfDay: '10:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 13,
    applicableTo: <SurgeryCategory>{SurgeryCategory.orthoExtremity},
  ),
  TaskTemplate(
    templateId: 'week2_extremity_physio',
    type: TaskType.custom,
    title: 'Physiotherapie-Übungen',
    subtitle: 'Beweglichkeit und Kraft aufbauen',
    priority: TaskPriority.normal,
    deeplinkRoute: '/rehab',
    phase: 'week2',
    relativeDay: 8,
    timeOfDay: '10:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.orthoExtremity},
  ),

  // ═══════════════════════════════════════════════════════════════════
  // ── Urologie ─────────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  TaskTemplate(
    templateId: 'week1_catheter_check',
    type: TaskType.checklist,
    title: 'Katheter-Kontrolle',
    subtitle: 'Durchlässigkeit und Position prüfen',
    priority: TaskPriority.high,
    deeplinkRoute: '',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '08:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.urology},
  ),
  TaskTemplate(
    templateId: 'week1_urine_observe',
    type: TaskType.custom,
    title: 'Urinfarbe beobachten',
    subtitle: 'Blutbeimengung oder Trübung dokumentieren',
    priority: TaskPriority.normal,
    deeplinkRoute: '/vitals',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '09:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.urology},
  ),
  TaskTemplate(
    templateId: 'week1_fluid_intake_uro',
    type: TaskType.checklist,
    title: 'Trinkmenge erhöhen',
    subtitle: 'Mindestens 2 Liter täglich – Nieren spülen',
    priority: TaskPriority.normal,
    deeplinkRoute: '/nutrition',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '10:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 14,
    applicableTo: <SurgeryCategory>{SurgeryCategory.urology},
  ),
  TaskTemplate(
    templateId: 'week1_pelvic_floor',
    type: TaskType.custom,
    title: 'Beckenbodenübungen',
    subtitle: 'Sanfte Anspannung zur Kontinenzförderung',
    priority: TaskPriority.normal,
    deeplinkRoute: '/rehab',
    phase: 'week1',
    relativeDay: 3,
    timeOfDay: '11:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 11,
    applicableTo: <SurgeryCategory>{SurgeryCategory.urology},
  ),

  // ═══════════════════════════════════════════════════════════════════
  // ── Gynäkologie ──────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  TaskTemplate(
    templateId: 'week1_gyn_rest',
    type: TaskType.checklist,
    title: 'Körperliche Schonung',
    subtitle: 'Kein Heben über 5 kg, kein Sport',
    priority: TaskPriority.high,
    deeplinkRoute: '',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '08:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 14,
    applicableTo: <SurgeryCategory>{SurgeryCategory.gynecology},
  ),
  TaskTemplate(
    templateId: 'week1_gyn_bleeding',
    type: TaskType.custom,
    title: 'Blutung dokumentieren',
    subtitle: 'Stärke und Dauer der Nachblutung beobachten',
    priority: TaskPriority.normal,
    deeplinkRoute: '/vitals',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '09:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.gynecology},
  ),
  TaskTemplate(
    templateId: 'week1_gyn_pelvic_floor',
    type: TaskType.custom,
    title: 'Beckenboden-Training',
    subtitle: 'Sanfte Anspannung – besonders nach Geburt/Hysterektomie',
    priority: TaskPriority.normal,
    deeplinkRoute: '/rehab',
    phase: 'week1',
    relativeDay: 3,
    timeOfDay: '11:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 11,
    applicableTo: <SurgeryCategory>{SurgeryCategory.gynecology},
  ),
  TaskTemplate(
    templateId: 'week1_gyn_temperature',
    type: TaskType.custom,
    title: 'Temperatur messen',
    subtitle: 'Fieber als Warnsignal erkennen',
    priority: TaskPriority.normal,
    deeplinkRoute: '/vitals',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '07:30',
    dueHoursAfterScheduled: 4,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.gynecology},
  ),

  // ═══════════════════════════════════════════════════════════════════
  // ── HNO ──────────────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  TaskTemplate(
    templateId: 'week1_ent_soft_food',
    type: TaskType.nutrition,
    title: 'Weiche Kost',
    subtitle: 'Keine harten, heißen oder scharfen Speisen',
    priority: TaskPriority.high,
    deeplinkRoute: '/nutrition',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '12:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.ent},
  ),
  TaskTemplate(
    templateId: 'week1_ent_no_blowing',
    type: TaskType.checklist,
    title: 'Nase nicht schnäuzen',
    subtitle: 'Vorsichtig abtupfen – kein Druck auf Nase',
    priority: TaskPriority.high,
    deeplinkRoute: '',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '08:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.ent},
  ),
  TaskTemplate(
    templateId: 'week1_ent_rinse',
    type: TaskType.custom,
    title: 'Nasenspülung / Mundspülung',
    subtitle: 'Sanfte Spülung nach Anweisung',
    priority: TaskPriority.normal,
    deeplinkRoute: '',
    phase: 'week1',
    relativeDay: 2,
    timeOfDay: '09:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 12,
    applicableTo: <SurgeryCategory>{SurgeryCategory.ent},
  ),
  TaskTemplate(
    templateId: 'week1_ent_voice_rest',
    type: TaskType.checklist,
    title: 'Stimmschonung',
    subtitle: 'Leise sprechen, nicht flüstern – Stimme schonen',
    priority: TaskPriority.normal,
    deeplinkRoute: '',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '08:30',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.ent},
  ),

  // ═══════════════════════════════════════════════════════════════════
  // ── Augenheilkunde ───────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  TaskTemplate(
    templateId: 'week1_eye_drops',
    type: TaskType.meds,
    title: 'Augentropfen',
    subtitle: 'Tropfen nach Plan anwenden',
    priority: TaskPriority.high,
    deeplinkRoute: '/meds',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '08:00',
    dueHoursAfterScheduled: 2,
    repeatEveryDays: 1,
    repeatCount: 28,
    applicableTo: <SurgeryCategory>{SurgeryCategory.ophthalmology},
  ),
  TaskTemplate(
    templateId: 'week1_eye_no_rubbing',
    type: TaskType.checklist,
    title: 'Augen nicht reiben',
    subtitle: 'Schutzbrille / Augenklappe tragen',
    priority: TaskPriority.high,
    deeplinkRoute: '',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '07:30',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 14,
    applicableTo: <SurgeryCategory>{SurgeryCategory.ophthalmology},
  ),
  TaskTemplate(
    templateId: 'week1_eye_no_bending',
    type: TaskType.checklist,
    title: 'Nicht bücken / heben',
    subtitle: 'Kein Druck auf die Augen – kein schweres Heben',
    priority: TaskPriority.normal,
    deeplinkRoute: '',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '08:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.ophthalmology},
  ),
  TaskTemplate(
    templateId: 'week1_eye_vision_check',
    type: TaskType.custom,
    title: 'Sehvermögen prüfen',
    subtitle: 'Veränderungen der Sehschärfe dokumentieren',
    priority: TaskPriority.normal,
    deeplinkRoute: '/vitals',
    phase: 'week1',
    relativeDay: 1,
    timeOfDay: '09:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.ophthalmology},
  ),

  // ═══════════════════════════════════════════════════════════════════
  // ── Neurochirurgie ───────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  TaskTemplate(
    templateId: 'week1_neuro_orientation',
    type: TaskType.custom,
    title: 'Orientierung prüfen',
    subtitle: 'Wachheit, Orientierung und Sprache beobachten',
    priority: TaskPriority.high,
    deeplinkRoute: '/vitals',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '08:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.neuro},
  ),
  TaskTemplate(
    templateId: 'week1_neuro_headache',
    type: TaskType.custom,
    title: 'Kopfschmerzen dokumentieren',
    subtitle: 'Stärke, Art und Dauer der Kopfschmerzen erfassen',
    priority: TaskPriority.normal,
    deeplinkRoute: '/pain',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '12:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 14,
    applicableTo: <SurgeryCategory>{SurgeryCategory.neuro},
  ),
  TaskTemplate(
    templateId: 'week1_neuro_seizure_watch',
    type: TaskType.checklist,
    title: 'Krampfanfälle beobachten',
    subtitle: 'Auffälligkeiten sofort dokumentieren',
    priority: TaskPriority.high,
    deeplinkRoute: '/alerts',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '21:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 14,
    applicableTo: <SurgeryCategory>{SurgeryCategory.neuro},
  ),
  TaskTemplate(
    templateId: 'week1_neuro_rest',
    type: TaskType.checklist,
    title: 'Bildschirmpausen einhalten',
    subtitle: 'Augen und Gehirn schonen – regelmäßig pausieren',
    priority: TaskPriority.normal,
    deeplinkRoute: '',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '14:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 14,
    applicableTo: <SurgeryCategory>{SurgeryCategory.neuro},
  ),

  // ═══════════════════════════════════════════════════════════════════
  // ── Gefäßchirurgie ───────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  TaskTemplate(
    templateId: 'week1_vasc_compression',
    type: TaskType.checklist,
    title: 'Kompression prüfen',
    subtitle: 'Kompressionsstrümpfe/-verband korrekt angelegt?',
    priority: TaskPriority.high,
    deeplinkRoute: '',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '07:30',
    dueHoursAfterScheduled: 4,
    repeatEveryDays: 1,
    repeatCount: 14,
    applicableTo: <SurgeryCategory>{SurgeryCategory.vascular},
  ),
  TaskTemplate(
    templateId: 'week1_vasc_circulation',
    type: TaskType.custom,
    title: 'Durchblutung kontrollieren',
    subtitle: 'Hautfarbe, Temperatur und Pulse prüfen',
    priority: TaskPriority.high,
    deeplinkRoute: '/vitals',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '09:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.vascular},
  ),
  TaskTemplate(
    templateId: 'week1_vasc_walking',
    type: TaskType.custom,
    title: 'Gehtraining',
    subtitle: 'Regelmäßig kurze Strecken gehen – Kreislauf fördern',
    priority: TaskPriority.normal,
    deeplinkRoute: '/rehab',
    phase: 'week1',
    relativeDay: 1,
    timeOfDay: '10:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 13,
    applicableTo: <SurgeryCategory>{SurgeryCategory.vascular},
  ),

  // ═══════════════════════════════════════════════════════════════════
  // ── Plastische Chirurgie ─────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  TaskTemplate(
    templateId: 'week1_plastic_compression',
    type: TaskType.checklist,
    title: 'Kompressions-Kleidung prüfen',
    subtitle: 'Sitz und Tragezeit kontrollieren',
    priority: TaskPriority.high,
    deeplinkRoute: '',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '07:30',
    dueHoursAfterScheduled: 4,
    repeatEveryDays: 1,
    repeatCount: 14,
    applicableTo: <SurgeryCategory>{SurgeryCategory.plastic},
  ),
  TaskTemplate(
    templateId: 'week1_plastic_swelling',
    type: TaskType.custom,
    title: 'Schwellung dokumentieren',
    subtitle: 'Fotos machen – Verlauf vergleichen',
    priority: TaskPriority.normal,
    deeplinkRoute: '/wound-editor',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '09:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.plastic},
  ),
  TaskTemplate(
    templateId: 'week1_plastic_no_sun',
    type: TaskType.checklist,
    title: 'Sonnenschutz beachten',
    subtitle: 'Direkte Sonne auf OP-Gebiet vermeiden',
    priority: TaskPriority.normal,
    deeplinkRoute: '',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '08:00',
    dueHoursAfterScheduled: 8,
    repeatEveryDays: 1,
    repeatCount: 14,
    applicableTo: <SurgeryCategory>{SurgeryCategory.plastic},
  ),

  // ═══════════════════════════════════════════════════════════════════
  // ── MKG (Mund-Kiefer-Gesicht) ────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  TaskTemplate(
    templateId: 'week1_mkg_soft_food',
    type: TaskType.nutrition,
    title: 'Weiche / flüssige Kost',
    subtitle: 'Keine harten Lebensmittel – Kiefer schonen',
    priority: TaskPriority.high,
    deeplinkRoute: '/nutrition',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '12:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.maxillofacial},
  ),
  TaskTemplate(
    templateId: 'week1_mkg_oral_hygiene',
    type: TaskType.checklist,
    title: 'Mundhygiene',
    subtitle: 'Vorsichtig spülen, Bereich um Wunde schonen',
    priority: TaskPriority.high,
    deeplinkRoute: '',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '08:00',
    dueHoursAfterScheduled: 4,
    repeatEveryDays: 1,
    repeatCount: 14,
    applicableTo: <SurgeryCategory>{SurgeryCategory.maxillofacial},
  ),
  TaskTemplate(
    templateId: 'week1_mkg_cooling',
    type: TaskType.checklist,
    title: 'Kühlen',
    subtitle: 'Kühlpacks 15-20 Min alle 2 Stunden – Schwellung reduzieren',
    priority: TaskPriority.normal,
    deeplinkRoute: '',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '09:00',
    dueHoursAfterScheduled: 4,
    repeatEveryDays: 1,
    repeatCount: 3,
    applicableTo: <SurgeryCategory>{SurgeryCategory.maxillofacial},
  ),
  TaskTemplate(
    templateId: 'week1_mkg_swelling',
    type: TaskType.custom,
    title: 'Schwellung beobachten',
    subtitle: 'Gesichtsschwellung dokumentieren',
    priority: TaskPriority.normal,
    deeplinkRoute: '/wound-editor',
    phase: 'week1',
    relativeDay: 0,
    timeOfDay: '18:00',
    dueHoursAfterScheduled: 6,
    repeatEveryDays: 1,
    repeatCount: 7,
    applicableTo: <SurgeryCategory>{SurgeryCategory.maxillofacial},
  ),
];
