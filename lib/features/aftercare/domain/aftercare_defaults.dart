import '../domain/aftercare_item.dart';
import '../domain/aftercare_item_category.dart';
import '../domain/aftercare_phase.dart';

/// Surgery-type-specific default phases for the guided builder.
///
/// Each entry maps a surgery type string (matching `opType` in Firestore)
/// to a list of suggested phases with pre-configured items.
class AftercareDefaults {
  AftercareDefaults._();

  /// Known surgery types used across the app.
  ///
  /// This list is kept in sync with `kSurgeryGroups` in questionnaire_data.dart.
  /// Only the most common types are listed here for the aftercare builder
  /// dropdown. The [phasesForSurgeryType] method handles all types via
  /// pattern matching.
  static const List<String> surgeryTypes = [
    'Knie-TEP',
    'Knie-TEP-Wechsel',
    'Kreuzband-OP (VKB)',
    'Meniskus-OP',
    'Hüft-TEP',
    'Hüft-TEP-Wechsel',
    'Schulter-TEP',
    'Rotatorenmanschetten-OP',
    'Bandscheiben-OP (Diskektomie)',
    'Spondylodese (Versteifung)',
    'Karpaltunnel-OP',
    'Hallux valgus-OP',
    'Achillessehnen-OP',
    'Bypass-OP (CABG)',
    'Herzklappenersatz',
    'Appendektomie (Blinddarm)',
    'Cholezystektomie (Gallenblase)',
    'Leistenhernie-OP',
    'Prostata-OP (TUR-P)',
    'Hysterektomie',
    'Kaiserschnitt (Sectio)',
    'Tonsillektomie (Mandeln)',
    'Katarakt-OP (Grauer Star)',
    'Krampfadern-OP (Varizen)',
    'Weisheitszahn-OP',
    'Sonstiges',
  ];

  /// Known body regions.
  static const List<String> bodyRegions = [
    'Knie',
    'Hüfte',
    'Schulter',
    'Wirbelsäule',
    'Hand / Handgelenk',
    'Fuß / Sprunggelenk',
    'Thorax',
    'Abdomen',
    'Sonstiges',
  ];

  /// Categories that are considered safety-critical standard modules.
  /// Deactivating these triggers a confirmation dialog.
  static const Set<AftercareItemCategory> safetyCriticalCategories = {
    AftercareItemCategory.wound,
    AftercareItemCategory.dressing,
    AftercareItemCategory.sutureRemoval,
    AftercareItemCategory.weightBearing,
    AftercareItemCategory.medication,
  };

  /// Default phases for orthopaedic joint surgeries (Knie-TEP, Hüft-TEP, etc.)
  static List<AftercarePhase> orthoJointPhases() => [
        AftercarePhase(
          id: 'phase_1',
          title: 'Frühphase (Tag 0–3)',
          startDayOffset: 0,
          endDayOffset: 3,
          order: 0,
          items: [
            _item('wound_1', AftercareItemCategory.wound, 'Wundkontrolle', startDay: 0, endDay: 3),
            _item('dressing_1', AftercareItemCategory.dressing, 'Verbandswechsel', startDay: 1, endDay: 3),
            _item('wb_1', AftercareItemCategory.weightBearing, 'Teilbelastung 15 kg', startDay: 0, endDay: 3),
            _item('physio_1', AftercareItemCategory.physio, 'Mobilisation mit Unterarmgehstützen', startDay: 1),
            _item('med_1', AftercareItemCategory.medication, 'Thromboseprophylaxe', startDay: 0, endDay: 42),
            _item('med_2', AftercareItemCategory.medication, 'Schmerzmedikation nach Bedarf', startDay: 0, endDay: 14),
          ],
        ),
        AftercarePhase(
          id: 'phase_2',
          title: 'Woche 1–2',
          startDayOffset: 4,
          endDayOffset: 14,
          order: 1,
          items: [
            _item('wound_2', AftercareItemCategory.wound, 'Wundkontrolle', startDay: 7),
            _item('suture_1', AftercareItemCategory.sutureRemoval, 'Fadenentfernung / Klammerentfernung', startDay: 12, endDay: 14),
            _item('wb_2', AftercareItemCategory.weightBearing, 'Teilbelastung 30 kg', startDay: 4, endDay: 14),
            _item('rom_1', AftercareItemCategory.rom, 'Beugung bis 90°', startDay: 4, endDay: 14),
            _item('physio_2', AftercareItemCategory.physio, 'Physiotherapie 3×/Woche', startDay: 4, endDay: 14),
            _item('cpm_1', AftercareItemCategory.cpm, 'CPM-Schiene 3×30 Min/Tag', startDay: 4, endDay: 14),
          ],
        ),
        AftercarePhase(
          id: 'phase_3',
          title: 'Woche 3–6',
          startDayOffset: 15,
          endDayOffset: 42,
          order: 2,
          items: [
            _item('wb_3', AftercareItemCategory.weightBearing, 'Aufbelastung bis Vollbelastung', startDay: 15, endDay: 42),
            _item('rom_2', AftercareItemCategory.rom, 'Freie Beugung', startDay: 15),
            _item('physio_3', AftercareItemCategory.physio, 'Physiotherapie 2–3×/Woche', startDay: 15, endDay: 42),
            _item('aid_1', AftercareItemCategory.aid, 'Unterarmgehstützen', startDay: 0, endDay: 42),
            _item('supp_1', AftercareItemCategory.supplement, 'Vitamin D + Calcium', startDay: 0, endDay: 90),
          ],
        ),
        AftercarePhase(
          id: 'phase_4',
          title: 'Ab Woche 7',
          startDayOffset: 43,
          order: 3,
          items: [
            _item('wb_4', AftercareItemCategory.weightBearing, 'Vollbelastung', startDay: 43),
            _item('physio_4', AftercareItemCategory.physio, 'Physiotherapie / Reha', startDay: 43, endDay: 90),
            _item('custom_1', AftercareItemCategory.custom, 'Abschlusskontrolle', startDay: 90),
          ],
        ),
      ];

  /// Default phases for spine surgery.
  static List<AftercarePhase> spinePhases() => [
        AftercarePhase(
          id: 'phase_1',
          title: 'Frühphase (Tag 0–3)',
          startDayOffset: 0,
          endDayOffset: 3,
          order: 0,
          items: [
            _item('wound_1', AftercareItemCategory.wound, 'Wundkontrolle', startDay: 0, endDay: 3),
            _item('dressing_1', AftercareItemCategory.dressing, 'Verbandswechsel', startDay: 1, endDay: 3),
            _item('med_1', AftercareItemCategory.medication, 'Schmerzmedikation', startDay: 0, endDay: 14),
            _item('med_2', AftercareItemCategory.medication, 'Thromboseprophylaxe', startDay: 0, endDay: 21),
            _item('physio_1', AftercareItemCategory.physio, 'Mobilisation', startDay: 1),
          ],
        ),
        AftercarePhase(
          id: 'phase_2',
          title: 'Woche 1–6',
          startDayOffset: 4,
          endDayOffset: 42,
          order: 1,
          items: [
            _item('suture_1', AftercareItemCategory.sutureRemoval, 'Fadenentfernung', startDay: 10, endDay: 14),
            _item('aid_1', AftercareItemCategory.aid, 'Korsett / Mieder tragen', startDay: 0, endDay: 42),
            _item('physio_2', AftercareItemCategory.physio, 'Isometrische Übungen', startDay: 7, endDay: 42),
            _item('custom_1', AftercareItemCategory.custom, 'Keine Rotation / Bücken', startDay: 0, endDay: 42),
          ],
        ),
        AftercarePhase(
          id: 'phase_3',
          title: 'Ab Woche 7',
          startDayOffset: 43,
          order: 2,
          items: [
            _item('physio_3', AftercareItemCategory.physio, 'Physiotherapie / Reha', startDay: 43, endDay: 90),
            _item('custom_2', AftercareItemCategory.custom, 'Schrittweise Belastungssteigerung', startDay: 43),
            _item('custom_3', AftercareItemCategory.custom, 'Abschlusskontrolle', startDay: 90),
          ],
        ),
      ];

  /// Generic default phases for any surgery type.
  static List<AftercarePhase> genericPhases() => [
        AftercarePhase(
          id: 'phase_1',
          title: 'Frühphase (Tag 0–7)',
          startDayOffset: 0,
          endDayOffset: 7,
          order: 0,
          items: [
            _item('wound_1', AftercareItemCategory.wound, 'Wundkontrolle', startDay: 0, endDay: 7),
            _item('dressing_1', AftercareItemCategory.dressing, 'Verbandswechsel', startDay: 1, endDay: 7),
            _item('med_1', AftercareItemCategory.medication, 'Schmerzmedikation nach Bedarf', startDay: 0, endDay: 14),
          ],
        ),
        AftercarePhase(
          id: 'phase_2',
          title: 'Woche 2–6',
          startDayOffset: 8,
          endDayOffset: 42,
          order: 1,
          items: [
            _item('suture_1', AftercareItemCategory.sutureRemoval, 'Fadenentfernung', startDay: 10, endDay: 14),
            _item('physio_1', AftercareItemCategory.physio, 'Physiotherapie', startDay: 14, endDay: 42),
          ],
        ),
        AftercarePhase(
          id: 'phase_3',
          title: 'Ab Woche 7',
          startDayOffset: 43,
          order: 2,
          items: [
            _item('custom_1', AftercareItemCategory.custom, 'Abschlusskontrolle', startDay: 90),
          ],
        ),
      ];

  /// Returns default phases for a given surgery type string.
  static List<AftercarePhase> phasesForSurgeryType(String? surgeryType) {
    return switch (surgeryType) {
      // ── Orthopädie (Gelenke) ──
      'Knie-TEP' || 'Knie-TEP-Wechsel' || 'Kreuzband-OP (VKB)' ||
      'Hintere Kreuzband-OP (HKB)' || 'Meniskus-OP' || 'Kniearthroskopie' ||
      'Umstellungsosteotomie (HTO)' || 'Patellastabilisierung' ||
      'Knorpeltransplantation' || 'Baker-Zysten-OP' ||
      'Hüft-TEP' || 'Hüft-TEP-Wechsel' || 'Hüftarthroskopie' ||
      'Schenkelhalsfraktur-OP' || 'Hüftkopfnekrose-OP' ||
      'Periazetabuläre Osteotomie' ||
      'Schulter-TEP' || 'Inverse Schulter-TEP' || 'Rotatorenmanschetten-OP' ||
      'Schulterarthroskopie' || 'Schulterstabilisierung (Bankart)' ||
      'AC-Gelenk-OP' || 'Impingement-OP' || 'Schulter-Dekompression' ||
      // Legacy
      'Kreuzband-OP' || 'Schulter-OP' =>
        orthoJointPhases(),

      // ── Wirbelsäule ──
      'Bandscheiben-OP (Diskektomie)' || 'Bandscheibenprothese' ||
      'Spinalkanalstenose-OP' || 'Spondylodese (Versteifung)' ||
      'Kyphoplastie / Vertebroplastie' || 'Laminektomie' ||
      'Skoliose-OP' || 'Facettengelenk-OP' || 'Wirbelsäulen-OP' =>
        spinePhases(),

      // ── Hand / Fuß / Extremitäten ──
      'Karpaltunnel-OP' || 'Dupuytren-OP' || 'Ganglion-Entfernung' ||
      'Sehnenscheiden-OP' || 'Handgelenksfraktur-OP' ||
      'Daumensattelgelenk-OP (Rhizarthrose)' || 'Finger-Replantation' ||
      'Handgelenksarthroskopie' ||
      'Hallux valgus-OP' || 'Achillessehnen-OP' || 'Sprunggelenksfraktur-OP' ||
      'Fersensporn-OP' || 'Hammerzehen-OP' || 'Sprunggelenksarthroskopie' ||
      'Mittelfußfraktur-OP' || 'Arthrodese (Versteifung)' =>
        orthoExtremityPhases(),

      // ── Herz & Thorax ──
      'Bypass-OP (CABG)' || 'Herzklappenersatz' ||
      'Herzklappen-Rekonstruktion' || 'Schrittmacher-Implantation' ||
      'Defibrillator-Implantation (ICD)' || 'Thorakoskopie (VATS)' ||
      'Lungen-OP (Lobektomie)' || 'Aortenaneurysma-OP' ||
      'Mediastinoskopie' || 'Herz-OP' =>
        cardioThoracicPhases(),

      // ── Bauch / Viszeralchirurgie ──
      'Appendektomie (Blinddarm)' || 'Cholezystektomie (Gallenblase)' ||
      'Leistenhernie-OP' || 'Nabelhernie-OP' || 'Narbenhernie-OP' ||
      'Darm-OP (Resektion)' || 'Magen-Bypass / Schlauchmagen' ||
      'Schilddrüsen-OP' || 'Milz-OP (Splenektomie)' ||
      'Leber-OP (Resektion)' || 'Pankreas-OP' || 'Bauch-OP' =>
        abdominalPhases(),

      // ── Urologie ──
      'Prostata-OP (TUR-P)' || 'Radikale Prostatektomie' ||
      'Nieren-OP (Nephrektomie)' || 'Blasen-OP' ||
      'Nierenstein-OP (URS / PCNL)' || 'Vasektomie' || 'Zirkumzision' ||
      'Hoden-OP (Orchidopexie)' || 'Nebennierenentfernung' =>
        urologyPhases(),

      // ── Gynäkologie ──
      'Hysterektomie' || 'Kaiserschnitt (Sectio)' || 'Myom-Entfernung' ||
      'Eierstock-OP' || 'Brust-OP (Mastektomie)' || 'Brusterhaltende OP' ||
      'Gebärmutterspiegelung' || 'Endometriose-OP' ||
      'Eileiterschwangerschaft-OP' || 'Beckenboden-OP' =>
        gynecologyPhases(),

      // ── HNO ──
      'Tonsillektomie (Mandeln)' || 'Nasennebenhöhlen-OP (FESS)' ||
      'Septumplastik (Nasenscheidewand)' || 'Ohren-OP (Tympanoplastik)' ||
      'Adenotomie (Polypen)' || 'Parotidektomie (Speicheldrüse)' ||
      'Cochlea-Implantat' || 'Kehlkopf-OP (Laryngoskopie)' ||
      'Nasenmuschel-OP' =>
        entPhases(),

      // ── Augenheilkunde ──
      'Katarakt-OP (Grauer Star)' || 'Glaukom-OP (Grüner Star)' ||
      'Vitrektomie (Glaskörper)' || 'Netzhaut-OP' || 'Schiel-OP' ||
      'Lidkorrektur (Blepharoplastik)' || 'Hornhauttransplantation' ||
      'Lasik / PRK' =>
        ophthalmologyPhases(),

      // ── Neurochirurgie ──
      'Hirntumor-OP' || 'Aneurysma-Clipping' || 'Shunt-OP (Hydrozephalus)' ||
      'Trigeminusneuralgie-OP' || 'Epilepsie-OP' ||
      'Tiefe Hirnstimulation (DBS)' =>
        neuroPhases(),

      // ── Gefäßchirurgie ──
      'Krampfadern-OP (Varizen)' || 'Carotis-OP (Halsschlagader)' ||
      'Peripherer Gefäß-Bypass' || 'Dialyse-Shunt-OP' ||
      'Thrombektomie' || 'Stent-Implantation' =>
        vascularPhases(),

      // ── Plastische Chirurgie ──
      'Hauttransplantation' || 'Brustvergrößerung' || 'Brustverkleinerung' ||
      'Bauchdeckenstraffung' || 'Narbenkorrektur' || 'Rekonstruktive OP' ||
      'Fettabsaugung (Liposuktion)' =>
        plasticPhases(),

      // ── MKG ──
      'Weisheitszahn-OP' || 'Kieferkorrektur (Dysgnathie)' || 'Implantat-OP' ||
      'Kieferbruch-OP' || 'Kieferzysten-OP' || 'Kiefergelenk-OP' =>
        maxillofacialPhases(),

      _ => genericPhases(),
    };
  }

  /// Default phases for hand/foot/extremity surgeries.
  static List<AftercarePhase> orthoExtremityPhases() => [
        AftercarePhase(
          id: 'phase_1',
          title: 'Frühphase (Tag 0–7)',
          startDayOffset: 0,
          endDayOffset: 7,
          order: 0,
          items: [
            _item('wound_1', AftercareItemCategory.wound, 'Wundkontrolle', startDay: 0, endDay: 7),
            _item('dressing_1', AftercareItemCategory.dressing, 'Verbandswechsel', startDay: 1, endDay: 7),
            _item('med_1', AftercareItemCategory.medication, 'Schmerzmedikation', startDay: 0, endDay: 14),
            _item('aid_1', AftercareItemCategory.aid, 'Schiene / Gips tragen', startDay: 0, endDay: 42),
            _item('physio_1', AftercareItemCategory.physio, 'Fingerübungen / Zehenübungen', startDay: 1),
          ],
        ),
        AftercarePhase(
          id: 'phase_2',
          title: 'Woche 2–6',
          startDayOffset: 8,
          endDayOffset: 42,
          order: 1,
          items: [
            _item('suture_1', AftercareItemCategory.sutureRemoval, 'Fadenentfernung', startDay: 10, endDay: 14),
            _item('physio_2', AftercareItemCategory.physio, 'Physiotherapie / Ergotherapie', startDay: 14, endDay: 42),
            _item('rom_1', AftercareItemCategory.rom, 'Beweglichkeit steigern', startDay: 14, endDay: 42),
          ],
        ),
        AftercarePhase(
          id: 'phase_3',
          title: 'Ab Woche 7',
          startDayOffset: 43,
          order: 2,
          items: [
            _item('physio_3', AftercareItemCategory.physio, 'Belastung steigern', startDay: 43, endDay: 90),
            _item('custom_1', AftercareItemCategory.custom, 'Abschlusskontrolle', startDay: 60),
          ],
        ),
      ];

  /// Default phases for cardio-thoracic surgeries.
  static List<AftercarePhase> cardioThoracicPhases() => [
        AftercarePhase(
          id: 'phase_1',
          title: 'Frühphase (Tag 0–7)',
          startDayOffset: 0,
          endDayOffset: 7,
          order: 0,
          items: [
            _item('wound_1', AftercareItemCategory.wound, 'Wundkontrolle (Sternum/Thorax)', startDay: 0, endDay: 7),
            _item('dressing_1', AftercareItemCategory.dressing, 'Verbandswechsel', startDay: 1, endDay: 7),
            _item('med_1', AftercareItemCategory.medication, 'Schmerzmedikation', startDay: 0, endDay: 14),
            _item('med_2', AftercareItemCategory.medication, 'Blutdruckmedikation', startDay: 0),
            _item('physio_1', AftercareItemCategory.physio, 'Atemübungen & leichte Mobilisation', startDay: 1),
            _item('custom_1', AftercareItemCategory.custom, 'Brustbein-Schonung: kein Heben >5 kg', startDay: 0, endDay: 84),
          ],
        ),
        AftercarePhase(
          id: 'phase_2',
          title: 'Woche 2–6',
          startDayOffset: 8,
          endDayOffset: 42,
          order: 1,
          items: [
            _item('suture_1', AftercareItemCategory.sutureRemoval, 'Fadenentfernung', startDay: 10, endDay: 14),
            _item('physio_2', AftercareItemCategory.physio, 'Herzreha-Übungen steigern', startDay: 14, endDay: 42),
            _item('custom_2', AftercareItemCategory.custom, 'Blutdruck-Selbstmessung', startDay: 8, endDay: 90),
          ],
        ),
        AftercarePhase(
          id: 'phase_3',
          title: 'Ab Woche 7 (Reha)',
          startDayOffset: 43,
          order: 2,
          items: [
            _item('physio_3', AftercareItemCategory.physio, 'Herz-Kreislauf-Reha', startDay: 43, endDay: 90),
            _item('custom_3', AftercareItemCategory.custom, 'Abschlusskontrolle Kardiologe', startDay: 90),
          ],
        ),
      ];

  /// Default phases for abdominal / visceral surgeries.
  static List<AftercarePhase> abdominalPhases() => [
        AftercarePhase(
          id: 'phase_1',
          title: 'Frühphase (Tag 0–7)',
          startDayOffset: 0,
          endDayOffset: 7,
          order: 0,
          items: [
            _item('wound_1', AftercareItemCategory.wound, 'Wundkontrolle', startDay: 0, endDay: 7),
            _item('dressing_1', AftercareItemCategory.dressing, 'Verbandswechsel', startDay: 1, endDay: 7),
            _item('med_1', AftercareItemCategory.medication, 'Schmerzmedikation', startDay: 0, endDay: 14),
            _item('custom_1', AftercareItemCategory.custom, 'Kostaufbau: Tee → Schonkost → Normalkost', startDay: 0, endDay: 7),
            _item('custom_2', AftercareItemCategory.custom, 'Bauchmuskel-Schonung', startDay: 0, endDay: 42),
          ],
        ),
        AftercarePhase(
          id: 'phase_2',
          title: 'Woche 2–4',
          startDayOffset: 8,
          endDayOffset: 28,
          order: 1,
          items: [
            _item('suture_1', AftercareItemCategory.sutureRemoval, 'Fadenentfernung', startDay: 10, endDay: 14),
            _item('physio_1', AftercareItemCategory.physio, 'Leichte Mobilisation', startDay: 8, endDay: 28),
            _item('custom_3', AftercareItemCategory.custom, 'Normalisiering der Verdauung', startDay: 8, endDay: 28),
          ],
        ),
        AftercarePhase(
          id: 'phase_3',
          title: 'Ab Woche 5',
          startDayOffset: 29,
          order: 2,
          items: [
            _item('custom_4', AftercareItemCategory.custom, 'Belastung langsam steigern', startDay: 29),
            _item('custom_5', AftercareItemCategory.custom, 'Abschlusskontrolle', startDay: 42),
          ],
        ),
      ];

  /// Default phases for urological surgeries.
  static List<AftercarePhase> urologyPhases() => [
        AftercarePhase(
          id: 'phase_1',
          title: 'Frühphase (Tag 0–7)',
          startDayOffset: 0,
          endDayOffset: 7,
          order: 0,
          items: [
            _item('wound_1', AftercareItemCategory.wound, 'Wundkontrolle', startDay: 0, endDay: 7),
            _item('med_1', AftercareItemCategory.medication, 'Schmerzmedikation', startDay: 0, endDay: 14),
            _item('custom_1', AftercareItemCategory.custom, 'Katheter-Management', startDay: 0, endDay: 7),
            _item('custom_2', AftercareItemCategory.custom, 'Trinkmenge ≥ 2 l / Tag', startDay: 0, endDay: 14),
          ],
        ),
        AftercarePhase(
          id: 'phase_2',
          title: 'Woche 2–4',
          startDayOffset: 8,
          endDayOffset: 28,
          order: 1,
          items: [
            _item('suture_1', AftercareItemCategory.sutureRemoval, 'Fadenentfernung / Katheterentfernung', startDay: 7, endDay: 14),
            _item('physio_1', AftercareItemCategory.physio, 'Beckenbodenübungen', startDay: 14, endDay: 90),
            _item('custom_3', AftercareItemCategory.custom, 'Urinfarbe beobachten', startDay: 0, endDay: 14),
          ],
        ),
        AftercarePhase(
          id: 'phase_3',
          title: 'Ab Woche 5',
          startDayOffset: 29,
          order: 2,
          items: [
            _item('custom_4', AftercareItemCategory.custom, 'Sportfreigabe', startDay: 42),
            _item('custom_5', AftercareItemCategory.custom, 'Abschlusskontrolle', startDay: 42),
          ],
        ),
      ];

  /// Default phases for gynecological surgeries.
  static List<AftercarePhase> gynecologyPhases() => [
        AftercarePhase(
          id: 'phase_1',
          title: 'Frühphase (Tag 0–7)',
          startDayOffset: 0,
          endDayOffset: 7,
          order: 0,
          items: [
            _item('wound_1', AftercareItemCategory.wound, 'Wundkontrolle', startDay: 0, endDay: 7),
            _item('dressing_1', AftercareItemCategory.dressing, 'Verbandswechsel', startDay: 1, endDay: 7),
            _item('med_1', AftercareItemCategory.medication, 'Schmerzmedikation', startDay: 0, endDay: 14),
            _item('med_2', AftercareItemCategory.medication, 'Thromboseprophylaxe', startDay: 0, endDay: 14),
            _item('custom_1', AftercareItemCategory.custom, 'Blutung beobachten', startDay: 0, endDay: 14),
          ],
        ),
        AftercarePhase(
          id: 'phase_2',
          title: 'Woche 2–6',
          startDayOffset: 8,
          endDayOffset: 42,
          order: 1,
          items: [
            _item('suture_1', AftercareItemCategory.sutureRemoval, 'Fadenentfernung', startDay: 10, endDay: 14),
            _item('physio_1', AftercareItemCategory.physio, 'Beckenbodentraining', startDay: 14, endDay: 90),
            _item('custom_2', AftercareItemCategory.custom, 'Kein Heben > 5 kg', startDay: 0, endDay: 42),
          ],
        ),
        AftercarePhase(
          id: 'phase_3',
          title: 'Ab Woche 7',
          startDayOffset: 43,
          order: 2,
          items: [
            _item('physio_2', AftercareItemCategory.physio, 'Rückbildung / Reha', startDay: 43, endDay: 90),
            _item('custom_3', AftercareItemCategory.custom, 'Abschlusskontrolle Frauenarzt', startDay: 42),
          ],
        ),
      ];

  /// Default phases for ENT surgeries.
  static List<AftercarePhase> entPhases() => [
        AftercarePhase(
          id: 'phase_1',
          title: 'Frühphase (Tag 0–7)',
          startDayOffset: 0,
          endDayOffset: 7,
          order: 0,
          items: [
            _item('wound_1', AftercareItemCategory.wound, 'Wundkontrolle (Mund/Nase/Ohr)', startDay: 0, endDay: 7),
            _item('med_1', AftercareItemCategory.medication, 'Schmerzmedikation', startDay: 0, endDay: 7),
            _item('custom_1', AftercareItemCategory.custom, 'Weiche Kost / Schonkost', startDay: 0, endDay: 7),
            _item('custom_2', AftercareItemCategory.custom, 'Nasenschonung / Stimmschonung', startDay: 0, endDay: 7),
          ],
        ),
        AftercarePhase(
          id: 'phase_2',
          title: 'Woche 2–3',
          startDayOffset: 8,
          endDayOffset: 21,
          order: 1,
          items: [
            _item('custom_3', AftercareItemCategory.custom, 'Nasenspülung / Mundspülung', startDay: 7, endDay: 21),
            _item('custom_4', AftercareItemCategory.custom, 'Normalkost aufbauen', startDay: 8, endDay: 14),
          ],
        ),
        AftercarePhase(
          id: 'phase_3',
          title: 'Ab Woche 4',
          startDayOffset: 22,
          order: 2,
          items: [
            _item('custom_5', AftercareItemCategory.custom, 'Abschlusskontrolle HNO', startDay: 28),
          ],
        ),
      ];

  /// Default phases for ophthalmological surgeries.
  static List<AftercarePhase> ophthalmologyPhases() => [
        AftercarePhase(
          id: 'phase_1',
          title: 'Frühphase (Tag 0–7)',
          startDayOffset: 0,
          endDayOffset: 7,
          order: 0,
          items: [
            _item('med_1', AftercareItemCategory.medication, 'Augentropfen nach Plan', startDay: 0, endDay: 28),
            _item('custom_1', AftercareItemCategory.custom, 'Augenklappe / Schutzbrille tragen', startDay: 0, endDay: 7),
            _item('custom_2', AftercareItemCategory.custom, 'Nicht reiben / drücken', startDay: 0, endDay: 14),
            _item('custom_3', AftercareItemCategory.custom, 'Kein Bücken / schweres Heben', startDay: 0, endDay: 7),
          ],
        ),
        AftercarePhase(
          id: 'phase_2',
          title: 'Woche 2–4',
          startDayOffset: 8,
          endDayOffset: 28,
          order: 1,
          items: [
            _item('custom_4', AftercareItemCategory.custom, 'Sehschärfe beobachten', startDay: 7, endDay: 28),
            _item('custom_5', AftercareItemCategory.custom, 'Kontrolltermin Augenarzt', startDay: 7),
          ],
        ),
        AftercarePhase(
          id: 'phase_3',
          title: 'Ab Woche 5',
          startDayOffset: 29,
          order: 2,
          items: [
            _item('custom_6', AftercareItemCategory.custom, 'Abschlusskontrolle', startDay: 42),
          ],
        ),
      ];

  /// Default phases for neurosurgical procedures.
  static List<AftercarePhase> neuroPhases() => [
        AftercarePhase(
          id: 'phase_1',
          title: 'Frühphase (Tag 0–7)',
          startDayOffset: 0,
          endDayOffset: 7,
          order: 0,
          items: [
            _item('wound_1', AftercareItemCategory.wound, 'Wundkontrolle (Kopf/Rücken)', startDay: 0, endDay: 7),
            _item('dressing_1', AftercareItemCategory.dressing, 'Verbandswechsel', startDay: 1, endDay: 7),
            _item('med_1', AftercareItemCategory.medication, 'Schmerzmedikation', startDay: 0, endDay: 14),
            _item('med_2', AftercareItemCategory.medication, 'Antikonvulsiva (falls verordnet)', startDay: 0),
            _item('custom_1', AftercareItemCategory.custom, 'Orientierung / Bewusstsein prüfen', startDay: 0, endDay: 7),
          ],
        ),
        AftercarePhase(
          id: 'phase_2',
          title: 'Woche 2–6',
          startDayOffset: 8,
          endDayOffset: 42,
          order: 1,
          items: [
            _item('suture_1', AftercareItemCategory.sutureRemoval, 'Fadenentfernung / Klammern', startDay: 10, endDay: 14),
            _item('custom_2', AftercareItemCategory.custom, 'Kopfschmerzen dokumentieren', startDay: 0, endDay: 42),
            _item('physio_1', AftercareItemCategory.physio, 'Neuroreha starten', startDay: 14, endDay: 90),
            _item('custom_3', AftercareItemCategory.custom, 'Bildschirmzeit begrenzen', startDay: 0, endDay: 28),
          ],
        ),
        AftercarePhase(
          id: 'phase_3',
          title: 'Ab Woche 7',
          startDayOffset: 43,
          order: 2,
          items: [
            _item('physio_2', AftercareItemCategory.physio, 'Neuroreha fortsetzen', startDay: 43, endDay: 90),
            _item('custom_4', AftercareItemCategory.custom, 'Kontrolltermin Neurochirurgie', startDay: 90),
          ],
        ),
      ];

  /// Default phases for vascular surgeries.
  static List<AftercarePhase> vascularPhases() => [
        AftercarePhase(
          id: 'phase_1',
          title: 'Frühphase (Tag 0–7)',
          startDayOffset: 0,
          endDayOffset: 7,
          order: 0,
          items: [
            _item('wound_1', AftercareItemCategory.wound, 'Wundkontrolle', startDay: 0, endDay: 7),
            _item('dressing_1', AftercareItemCategory.dressing, 'Verbandswechsel', startDay: 1, endDay: 7),
            _item('med_1', AftercareItemCategory.medication, 'Schmerzmedikation', startDay: 0, endDay: 7),
            _item('med_2', AftercareItemCategory.medication, 'Thromboseprophylaxe', startDay: 0, endDay: 21),
            _item('aid_1', AftercareItemCategory.aid, 'Kompressionsstrümpfe tragen', startDay: 0, endDay: 42),
          ],
        ),
        AftercarePhase(
          id: 'phase_2',
          title: 'Woche 2–6',
          startDayOffset: 8,
          endDayOffset: 42,
          order: 1,
          items: [
            _item('suture_1', AftercareItemCategory.sutureRemoval, 'Fadenentfernung', startDay: 10, endDay: 14),
            _item('physio_1', AftercareItemCategory.physio, 'Gehtraining', startDay: 7, endDay: 42),
            _item('custom_1', AftercareItemCategory.custom, 'Durchblutung kontrollieren', startDay: 0, endDay: 28),
          ],
        ),
        AftercarePhase(
          id: 'phase_3',
          title: 'Ab Woche 7',
          startDayOffset: 43,
          order: 2,
          items: [
            _item('custom_2', AftercareItemCategory.custom, 'Abschlusskontrolle', startDay: 42),
          ],
        ),
      ];

  /// Default phases for plastic / reconstructive surgeries.
  static List<AftercarePhase> plasticPhases() => [
        AftercarePhase(
          id: 'phase_1',
          title: 'Frühphase (Tag 0–7)',
          startDayOffset: 0,
          endDayOffset: 7,
          order: 0,
          items: [
            _item('wound_1', AftercareItemCategory.wound, 'Wundkontrolle', startDay: 0, endDay: 14),
            _item('dressing_1', AftercareItemCategory.dressing, 'Verbandswechsel', startDay: 1, endDay: 7),
            _item('med_1', AftercareItemCategory.medication, 'Schmerzmedikation', startDay: 0, endDay: 14),
            _item('aid_1', AftercareItemCategory.aid, 'Kompressions-Kleidung tragen', startDay: 0, endDay: 42),
          ],
        ),
        AftercarePhase(
          id: 'phase_2',
          title: 'Woche 2–6',
          startDayOffset: 8,
          endDayOffset: 42,
          order: 1,
          items: [
            _item('suture_1', AftercareItemCategory.sutureRemoval, 'Fadenentfernung', startDay: 10, endDay: 14),
            _item('custom_1', AftercareItemCategory.custom, 'Sonnenschutz auf OP-Gebiet', startDay: 0, endDay: 180),
            _item('custom_2', AftercareItemCategory.custom, 'Narbenpflege', startDay: 14, endDay: 90),
          ],
        ),
        AftercarePhase(
          id: 'phase_3',
          title: 'Ab Woche 7',
          startDayOffset: 43,
          order: 2,
          items: [
            _item('custom_3', AftercareItemCategory.custom, 'Abschlusskontrolle', startDay: 90),
          ],
        ),
      ];

  /// Default phases for maxillofacial (MKG) surgeries.
  static List<AftercarePhase> maxillofacialPhases() => [
        AftercarePhase(
          id: 'phase_1',
          title: 'Frühphase (Tag 0–7)',
          startDayOffset: 0,
          endDayOffset: 7,
          order: 0,
          items: [
            _item('wound_1', AftercareItemCategory.wound, 'Wundkontrolle (Mund/Kiefer)', startDay: 0, endDay: 7),
            _item('med_1', AftercareItemCategory.medication, 'Schmerzmedikation', startDay: 0, endDay: 7),
            _item('med_2', AftercareItemCategory.medication, 'Antibiotikum (falls verordnet)', startDay: 0, endDay: 7),
            _item('custom_1', AftercareItemCategory.custom, 'Weiche/flüssige Kost', startDay: 0, endDay: 7),
            _item('custom_2', AftercareItemCategory.custom, 'Kühlen (Gesicht)', startDay: 0, endDay: 3),
            _item('custom_3', AftercareItemCategory.custom, 'Vorsichtige Mundhygiene', startDay: 0, endDay: 14),
          ],
        ),
        AftercarePhase(
          id: 'phase_2',
          title: 'Woche 2–4',
          startDayOffset: 8,
          endDayOffset: 28,
          order: 1,
          items: [
            _item('suture_1', AftercareItemCategory.sutureRemoval, 'Fadenentfernung', startDay: 7, endDay: 14),
            _item('custom_4', AftercareItemCategory.custom, 'Kost schrittweise normalisieren', startDay: 8, endDay: 28),
          ],
        ),
        AftercarePhase(
          id: 'phase_3',
          title: 'Ab Woche 5',
          startDayOffset: 29,
          order: 2,
          items: [
            _item('custom_5', AftercareItemCategory.custom, 'Kontrolltermin MKG / Zahnarzt', startDay: 28),
          ],
        ),
      ];

  static AftercareItem _item(
    String id,
    AftercareItemCategory category,
    String title, {
    int? startDay,
    int? endDay,
  }) {
    return AftercareItem(
      id: id,
      category: category,
      title: title,
      startDayOffset: startDay,
      endDayOffset: endDay,
      order: 0,
    );
  }
}
