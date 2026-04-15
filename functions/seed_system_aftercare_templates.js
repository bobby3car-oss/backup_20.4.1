#!/usr/bin/env node
/**
 * Seed script — populates system_aftercare_templates with
 * medically reasonable default templates for common surgeries.
 *
 * Usage:
 *   node functions/seed_system_aftercare_templates.js
 *
 * Prerequisites:
 *   - Firebase Admin SDK initialised via GOOGLE_APPLICATION_CREDENTIALS
 *     or gcloud auth application-default login
 */

const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const fs = require("fs");
const path = require("path");

// Ensure Application Default Credentials exist using Firebase CLI's token
function ensureADC() {
  const adcPath = path.join(
    process.env.HOME || process.env.USERPROFILE,
    ".config", "gcloud", "application_default_credentials.json"
  );
  if (fs.existsSync(adcPath)) return; // already exists

  const fbConfig = path.join(
    process.env.HOME || process.env.USERPROFILE,
    ".config", "configstore", "firebase-tools.json"
  );
  if (!fs.existsSync(fbConfig)) {
    console.error("No Firebase CLI credentials found. Run 'firebase login' first.");
    process.exit(1);
  }
  const config = JSON.parse(fs.readFileSync(fbConfig, "utf8"));
  const refreshToken = config?.tokens?.refresh_token;
  if (!refreshToken) {
    console.error("No refresh token in Firebase config. Run 'firebase login' first.");
    process.exit(1);
  }

  const adc = {
    client_id: "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com",
    client_secret: "j9iVZfS8kkCEFUPaAeJV0sAi",
    refresh_token: refreshToken,
    type: "authorized_user",
  };

  const dir = path.dirname(adcPath);
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(adcPath, JSON.stringify(adc, null, 2));
  console.log("Created ADC from Firebase CLI credentials.");
}

ensureADC();

const PROJECT_ID = "operationsbegleiter-860e7";
initializeApp({ projectId: PROJECT_ID });
const db = getFirestore();

const COLLECTION = "system_aftercare_templates";
const ADMIN_UID = "system"; // pseudo-UID for system-created templates

// ══════════════════════════════════════════════════════════════════════
// Helper
// ══════════════════════════════════════════════════════════════════════

let itemCounter = 0;
let phaseCounter = 0;

function pid() {
  return `phase_${++phaseCounter}`;
}
function iid() {
  return `item_${++itemCounter}`;
}

function item(category, title, description = "", extra = {}) {
  return {
    id: iid(),
    category,
    title,
    description,
    isTimeBound: false,
    showInTimeline: true,
    value: {},
    notes: "",
    order: 0,
    ...extra,
  };
}

function phase(title, startDay, endDay, items) {
  return {
    id: pid(),
    title,
    startDayOffset: startDay,
    ...(endDay != null ? { endDayOffset: endDay } : {}),
    order: 0,
    items,
  };
}

function template(title, description, surgeryType, bodyRegion, phases) {
  const now = FieldValue.serverTimestamp();
  return {
    title,
    description,
    surgeryType,
    bodyRegion,
    createdBy: ADMIN_UID,
    templateType: "system",
    version: 1,
    createdAt: now,
    updatedAt: now,
    phases,
  };
}

// ══════════════════════════════════════════════════════════════════════
// Templates
// ══════════════════════════════════════════════════════════════════════

const TEMPLATES = [
  // ── 1. Knie-TEP (Totalendoprothese) ─────────────────────────────
  template(
    "Knie-TEP — Totalendoprothese",
    "Standardnachbehandlung nach primärer Knie-Totalendoprothese. Stufenweiser Belastungsaufbau über 12 Wochen.",
    "Knie-TEP",
    "Knie",
    [
      phase("Akutphase (stationär)", 0, 5, [
        item("wound", "Wundkontrolle", "Tägliche Inspektion auf Rötung, Schwellung, Sekretion"),
        item("dressing", "Steriler Verband", "Verbandwechsel alle 2 Tage"),
        item("medication", "Thromboseprophylaxe", "NMH s.c. für 4–6 Wochen"),
        item("medication", "Schmerzmedikation", "Multimodales Schmerzkonzept nach Stufenschema"),
        item("weightBearing", "Teilbelastung", "Schmerzadaptierte Teilbelastung 20 kg mit Unterarmgehstützen"),
        item("physio", "KG ab Tag 1", "Mobilisation, isometrische Übungen, Gangschule"),
        item("cpm", "Motorschiene (CPM)", "Ab Tag 1, initial 0–60°, Steigerung bis Entlassung auf 0–90°"),
        item("aid", "Unterarmgehstützen", "Gangschule mit Physiotherapie"),
        item("rom", "Passive Flexion", "Ziel bei Entlassung: 0-0-90°"),
      ]),
      phase("Frühphase", 6, 14, [
        item("wound", "Wundkontrolle", "Ambulante Kontrolle bei Hausarzt, Rötung/Schwellung beachten"),
        item("sutureRemoval", "Fadenzug", "Fadenentfernung ab Tag 10–14 post-OP"),
        item("weightBearing", "Teilbelastung steigern", "Steigerung auf 50 % Körpergewicht"),
        item("physio", "Ambulante Physiotherapie", "3× pro Woche, Gangschule, aktive/passive Mobilisation"),
        item("rom", "Aktive Flexion", "Ziel: 0-0-100°"),
        item("medication", "Thromboseprophylaxe", "NMH fortführen bis Ende Woche 6"),
        item("supplement", "Vitamin D + Calcium", "Vitamin D 1000 IE/Tag, Calcium 1000 mg/Tag"),
      ]),
      phase("Aufbauphase", 15, 42, [
        item("weightBearing", "Vollbelastung anbahnen", "Schrittweise Steigerung zur Vollbelastung nach ärztlicher Freigabe"),
        item("physio", "Intensivierte Physiotherapie", "Muskelaufbau Quadrizeps, Beinachsentraining, Koordination"),
        item("rom", "Beweglichkeit optimieren", "Ziel: 0-0-120°, Streckdefizit < 5°"),
        item("aid", "Gehstützen abtrainieren", "Bei sicherer Vollbelastung schrittweise Entwöhnung"),
        item("custom", "Kontrolltermin Operateur", "6-Wochen-Kontrolle mit Röntgen"),
      ]),
      phase("Belastungsaufbau", 43, 84, [
        item("physio", "Sport-Physiotherapie", "Krafttraining, Ausdauer auf Ergometer, Aquajogging"),
        item("weightBearing", "Vollbelastung", "Volle Alltagsbelastung, Treppensteigen ohne Hilfsmittel"),
        item("rom", "Endgradiges Training", "Optimierung der Beweglichkeit, Dehnübungen"),
        item("custom", "Kontrolltermin 12 Wochen", "12-Wochen-Kontrolle mit Funktionstest"),
        item("custom", "Alltagsaktivitäten", "Radfahren (aufrecht) ab Woche 8, Schwimmen (Kraul) ab Woche 10"),
      ]),
    ]
  ),

  // ── 2. Hüft-TEP (Totalendoprothese) ────────────────────────────
  template(
    "Hüft-TEP — Totalendoprothese",
    "Standardnachbehandlung nach primärer Hüft-Totalendoprothese. Ziel: schnelle Mobilisation mit schmerzadaptierter Vollbelastung.",
    "Hüft-TEP",
    "Hüfte",
    [
      phase("Akutphase (stationär)", 0, 5, [
        item("wound", "Wundkontrolle", "Tägliche Inspektion, Redon-Drainagen nach 24–48 h entfernen"),
        item("dressing", "Steriler Verband", "Verbandwechsel bei Durchfeuchtung, sonst alle 2 Tage"),
        item("medication", "Thromboseprophylaxe", "NMH s.c. für 35 Tage postoperativ"),
        item("medication", "Schmerzmedikation", "Multimodales Schmerzkonzept"),
        item("weightBearing", "Schmerzadaptierte Vollbelastung", "Sofortige Vollbelastung erlaubt (zementiert) oder Teilbelastung 20 kg (zementfrei) nach Rücksprache"),
        item("physio", "Frühmobilisation", "Aufstehen am OP-Tag oder Tag 1, Gangschule mit Stützen"),
        item("aid", "Unterarmgehstützen", "Für 6 Wochen"),
        item("custom", "Luxationsprophylaxe", "Flexion < 90°, keine Adduktion über Mittellinie, keine Innenrotation. Weiches Kissen zwischen die Beine beim Schlafen"),
      ]),
      phase("Frühphase", 6, 14, [
        item("wound", "Wundkontrolle ambulant", "Kontrolle auf Wundheilungsstörung"),
        item("sutureRemoval", "Klammern/Fadenzug", "Klammerentfernung Tag 10–14"),
        item("physio", "Ambulante Physiotherapie", "3× pro Woche, Gangschule, Muskelaktivierung, Hüftmobilisation"),
        item("rom", "Passive ROM", "Flexion bis 90°, Extension 0°"),
        item("medication", "Thromboseprophylaxe", "NMH fortführen bis Tag 35"),
      ]),
      phase("Aufbauphase", 15, 42, [
        item("weightBearing", "Vollbelastung", "Vollbelastung mit Stützen, ab Woche 6 ohne Stützen"),
        item("physio", "Muskelaufbau", "Abduktoren, Extensoren, Stabilisationstraining"),
        item("rom", "Aktive Mobilisation", "Flexion > 90° nach ärztlicher Freigabe"),
        item("aid", "Gehstützen abbauen", "Ab Woche 6 schrittweise reduzieren"),
        item("custom", "Kontrolltermin 6 Wochen", "Röntgenkontrolle und Funktionstest"),
      ]),
      phase("Sportphase", 43, 84, [
        item("physio", "Sport-Reha", "Ergometertraining, Aquajogging, Walking"),
        item("custom", "Alltagssport", "Radfahren, Schwimmen, Nordic Walking ab Woche 8"),
        item("custom", "Kontrolltermin 12 Wochen", "Abschlusskontrolle mit Funktionsbeurteilung"),
      ]),
    ]
  ),

  // ── 3. Vordere Kreuzband-Plastik (VKB) ─────────────────────────
  template(
    "Vordere Kreuzband-Plastik (VKB-Rekonstruktion)",
    "Nachbehandlung nach arthroskopischer VKB-Rekonstruktion mit Semitendinosus-/Gracilis-Sehne oder Patellarsehne.",
    "VKB-Plastik",
    "Knie",
    [
      phase("Akutphase", 0, 7, [
        item("wound", "Wundkontrolle", "Arthroskopie-Portale täglich inspizieren, auf Erguss achten"),
        item("dressing", "Steriler Verband", "Wundstreifen bis Fadenzug"),
        item("medication", "Schmerzmedikation", "NSAR + ggf. Opioide nach Bedarf"),
        item("medication", "Thromboseprophylaxe", "NMH für 2 Wochen oder bis Vollbelastung"),
        item("weightBearing", "Teilbelastung", "20 kg Teilbelastung an Unterarmgehstützen"),
        item("aid", "VKB-Orthese", "Limitiert auf 0-0-90° Flexion, durchgehend tragen"),
        item("physio", "Isometrische Übungen", "Quadrizeps-Anspannung, Beinrückseite, Wadenpumpe"),
        item("rom", "Passive Extension", "Volle Streckung sofort erlaubt, aktive Beugung 0–90°"),
        item("custom", "RICE-Prinzip", "Hochlagerung, Kühlung 20 min alle 2 Std."),
      ]),
      phase("Frühphase", 8, 21, [
        item("sutureRemoval", "Fadenzug", "Fadenentfernung Tag 10–14"),
        item("weightBearing", "Teilbelastung steigern", "Steigerung auf 50 % Körpergewicht"),
        item("physio", "Ambulante KG", "3× pro Woche, geschlossene Kette, Beinpresse, Fahrrad ohne Widerstand"),
        item("rom", "Flexion steigern", "Ziel: 0-0-120° bis Ende Woche 3"),
        item("aid", "Orthese Freigabe", "Stufenweise ROM-Freigabe nach ärztlicher Kontrolle"),
      ]),
      phase("Aufbauphase", 22, 56, [
        item("weightBearing", "Vollbelastung", "Vollbelastung ab Woche 4, Stützen abtrainieren"),
        item("physio", "Muskelaufbau", "Leg-Press, Beinstrecker (geschlossene Kette), Koordination"),
        item("rom", "Volle ROM anstreben", "Ziel: seitengleiche Beweglichkeit"),
        item("aid", "Orthese abtrainieren", "Ab Woche 6 schrittweise Entwöhnung"),
        item("custom", "Kontrolltermin 6 Wochen", "Klinische Kontrolle, Stabilitätstest"),
      ]),
      phase("Return-to-Sport-Phase", 57, 180, [
        item("physio", "Athletik-Training", "Lauftraining ab Monat 3, Sprungtraining ab Monat 5"),
        item("custom", "Kontrolltermin 3 Monate", "MRT-Kontrolle und klinische Testung"),
        item("custom", "Sporttests", "Functional testing ab Monat 6: Hop-Test, Krafttest"),
        item("custom", "Return-to-Sport", "Frühestens ab Monat 9 nach bestandenem Testprotokoll"),
      ]),
    ]
  ),

  // ── 4. Schulter-Arthroskopie (Rotatorenmanschette) ──────────────
  template(
    "Rotatorenmanschetten-Rekonstruktion",
    "Nachbehandlung nach arthroskopischer Rekonstruktion der Rotatorenmanschette (kleine bis mittlere Ruptur).",
    "RM-Rekonstruktion",
    "Schulter",
    [
      phase("Akutphase (Ruhigstellung)", 0, 14, [
        item("wound", "Wundkontrolle", "Arthroskopie-Portale inspizieren"),
        item("dressing", "Steriler Verband", "Verbandwechsel alle 2 Tage"),
        item("medication", "Schmerzmedikation", "NSAR + Kühlung"),
        item("aid", "Schulterabduktionskissen", "15° Abduktionsschiene für 6 Wochen, Tag und Nacht"),
        item("physio", "Pendelübungen", "Vorsichtige Pendelübungen nach Codman ab Tag 3"),
        item("rom", "Passive ROM", "Passive Elevation bis 60°, keine aktive Abduktion"),
        item("custom", "Vorsichtsmaßnahmen", "Kein Heben > 500 g, keine aktive Außenrotation"),
      ]),
      phase("Frühphase", 15, 42, [
        item("sutureRemoval", "Fadenzug", "Fäden ab Tag 10–14 entfernen"),
        item("physio", "Assistive Mobilisation", "Physiotherapie 3× pro Woche, assistive Elevation, Außenrotation 0°"),
        item("rom", "Passive ROM erweitern", "Passive Elevation bis 120°, Außenrotation bis 20°"),
        item("aid", "Schiene abtrainieren", "Ab Woche 6 Abschinung beenden"),
        item("custom", "Kontrolltermin 6 Wochen", "Klinische Kontrolle, ggf. Ultraschall"),
      ]),
      phase("Aktive Mobilisation", 43, 84, [
        item("physio", "Aktive ROM", "Aktive Bewegung beginnen, isometrische Kräftigung"),
        item("rom", "Aktive Elevation", "Ziel: aktive Elevation > 140°"),
        item("custom", "Kein Widerstandstraining", "Noch kein Krafttraining gegen Widerstand"),
        item("custom", "Kontrolltermin 3 Monate", "Klinische Kontrolle, Kraft- und Bewegungstest"),
      ]),
      phase("Kraftaufbau", 85, 180, [
        item("physio", "Krafttraining", "Theraband-Übungen, Außen-/Innenrotation gegen Widerstand"),
        item("custom", "Überkopfsport", "Frühestens ab Monat 6 nach funktioneller Testung"),
        item("custom", "Kontrolltermin 6 Monate", "Abschlusskontrolle, Freigabe für Sport"),
      ]),
    ]
  ),

  // ── 5. Sprunggelenkfraktur (OSG) ────────────────────────────────
  template(
    "Sprunggelenkfraktur (Weber B/C)",
    "Nachbehandlung nach operativer Versorgung einer Sprunggelenkfraktur (Plattenosteosynthese). 6-Wochen-Entlastungsprotokoll.",
    "OSG-Fraktur",
    "Sprunggelenk",
    [
      phase("Akutphase (Ruhigstellung)", 0, 14, [
        item("wound", "Wundkontrolle", "Tägliche Inspektion, auf Schwellung und Durchblutung achten"),
        item("dressing", "Steriler Verband", "Verbandwechsel bei Bedarf"),
        item("medication", "Thromboseprophylaxe", "NMH für 6 Wochen oder bis Vollbelastung"),
        item("medication", "Schmerzmedikation", "NSAR + Analgetika nach Stufenschema"),
        item("weightBearing", "Entlastung", "Keine Belastung (0 kg), Unterarmgehstützen"),
        item("aid", "VACOped-Stiefel / Gips", "Ruhigstellung in Neutralposition"),
        item("physio", "Zehenübungen", "Aktive Zehengymnastik, Wadenpumpe"),
      ]),
      phase("Frühphase", 15, 28, [
        item("sutureRemoval", "Fadenzug", "Fadenentfernung Tag 12–14"),
        item("wound", "Wundverlauf", "Narbe kontrollieren, Massieren nach Verschluss"),
        item("weightBearing", "15 kg Teilbelastung", "Sohlenkontakt mit 15 kg, Abrollbewegung"),
        item("physio", "Mobilisation Sprunggelenk", "Dorsalextension/Plantarflexion im schmerzfreien Bereich"),
        item("custom", "Röntgenkontrolle 4 Wochen", "Konsolidierungskontrolle"),
      ]),
      phase("Aufbauphase", 29, 56, [
        item("weightBearing", "Belastung steigern", "Stufenweise Steigerung auf Vollbelastung"),
        item("physio", "Intensive Physiotherapie", "Propriozeption, Muskelaufbau Peroneusgruppe, Wadenheben"),
        item("aid", "Stiefel abtrainieren", "Ab Woche 6 Übergang zu festem Schuhwerk"),
        item("rom", "Endgradige Mobilisation", "Dorsalextension optimieren"),
        item("custom", "Kontrolltermin 6 Wochen", "Röntgen + klinische Kontrolle"),
      ]),
      phase("Vollbelastung & Sport", 57, 84, [
        item("physio", "Sport-Reha", "Lauftraining, Koordination, Sprungtraining"),
        item("custom", "Sportfreigabe", "Sportfähigkeit nach frühestens 10–12 Wochen"),
        item("custom", "ME-Planung", "Materialentfernung nach 12–18 Monaten besprechen"),
      ]),
    ]
  ),

  // ── 6. Wirbelsäulen-OP (Bandscheibenvorfall LWS) ───────────────
  template(
    "Bandscheibenvorfall LWS — Mikrodiskektomie",
    "Nachbehandlung nach lumbaler Mikrodiskektomie. Fokus auf schnelle Mobilisation mit Wirbelsäulen-Schutzregeln.",
    "Mikrodiskektomie",
    "Lendenwirbelsäule",
    [
      phase("Akutphase (stationär)", 0, 3, [
        item("wound", "Wundkontrolle", "Minimaler Schnitt, Inspektion auf Sekretion"),
        item("medication", "Schmerzmedikation", "NSAR + PPI-Schutz, ggf. Muskelrelaxantien"),
        item("physio", "Frühmobilisation", "Aufstehen am OP-Tag, Gehen auf Station"),
        item("weightBearing", "Vollbelastung erlaubt", "Normales Gehen, kein Heben > 5 kg"),
        item("custom", "Wirbelsäulenregeln", "Kein Bücken, kein Heben, kein Verdrehen für 6 Wochen"),
      ]),
      phase("Frühphase", 4, 14, [
        item("sutureRemoval", "Fadenzug", "Fadenentfernung ab Tag 10–12"),
        item("physio", "Walking-Programm", "Tägliche Spaziergänge, Dauer steigern (15 → 30 Min.)"),
        item("medication", "Schmerz-Reduktion", "Schrittweises Ausschleichen der Analgetika"),
        item("custom", "Sitzzeit begrenzen", "Maximal 20–30 Minuten am Stück sitzen"),
      ]),
      phase("Stabilisierung", 15, 42, [
        item("physio", "Rückenschule", "Ambulante Physiotherapie, Rumpfstabilisation, Core-Training"),
        item("custom", "Sitzzeit erweitern", "Schrittweise Steigerung auf 45–60 Min."),
        item("custom", "Hebegrenze", "Maximal 5–10 kg, ergonomisches Heben"),
        item("custom", "Kontrolltermin 6 Wochen", "MRT-Kontrolle bei persistierenden Beschwerden"),
      ]),
      phase("Belastungsaufbau", 43, 84, [
        item("physio", "Krafttraining", "Rückenextensoren, Bauchmuskeltraining, Ergometertraining"),
        item("custom", "Hebegrenze aufheben", "Ab Woche 8 schrittweise steigern"),
        item("custom", "Berufsfähigkeit", "Bürotätigkeit ab Woche 4–6, körperliche Arbeit ab Woche 8–12"),
        item("custom", "Sportfreigabe", "Schwimmen (Rücken) ab Woche 6, Joggen ab Woche 10"),
      ]),
    ]
  ),

  // ── 7. Arthroskopische Meniskusnaht ─────────────────────────────
  template(
    "Meniskusnaht (arthroskopisch)",
    "Nachbehandlung nach arthroskopischer Meniskusnaht. Teilbelastung für 6 Wochen, da Naht einheilen muss.",
    "Meniskusnaht",
    "Knie",
    [
      phase("Akutphase", 0, 7, [
        item("wound", "Wundkontrolle", "Arthroskopie-Portale inspizieren"),
        item("medication", "Schmerzmedikation", "NSAR + Kühlung"),
        item("medication", "Thromboseprophylaxe", "NMH für 6 Wochen"),
        item("weightBearing", "Teilbelastung 20 kg", "Unterarmgehstützen, Sohlenkontakt"),
        item("aid", "Knie-Orthese", "Limitiert auf 0-0-60° Flexion"),
        item("physio", "Isometrische Übungen", "Quadrizeps-Anspannung, SLR"),
        item("rom", "Extension halten", "Volle Streckung sofort, Beugung max. 60°"),
      ]),
      phase("Frühphase", 8, 28, [
        item("sutureRemoval", "Fadenzug", "Tag 10–14"),
        item("weightBearing", "Teilbelastung", "20 kg beibehalten bis Woche 4"),
        item("rom", "Flexion steigern", "Woche 3: 90° / Woche 4: 120°"),
        item("physio", "Passive Mobilisation", "Physiotherapie 2–3× pro Woche"),
        item("aid", "Orthesen-Anpassung", "ROM stufenweise freigeben"),
      ]),
      phase("Aufbauphase", 29, 56, [
        item("weightBearing", "Vollbelastung", "Ab Woche 5 schrittweise Steigerung"),
        item("physio", "Muskelaufbau", "Geschlossene Kette, Fahrradergometer"),
        item("rom", "Volle ROM", "Ziel: seitengleiche Beweglichkeit"),
        item("aid", "Orthese ablegen", "Ab Woche 6"),
        item("custom", "Kontrolltermin 6 Wochen", "Klinische Kontrolle, ggf. MRT"),
      ]),
      phase("Return-to-Sport", 57, 120, [
        item("physio", "Sport-Reha", "Lauftraining ab Woche 10, Sprünge ab Woche 14"),
        item("custom", "Sportfreigabe", "Kontaktsport ab Monat 4–6 nach Testung"),
      ]),
    ]
  ),

  // ── 8. Hallux valgus (Chevron-Osteotomie) ──────────────────────
  template(
    "Hallux valgus — Chevron-/Scarf-Osteotomie",
    "Nachbehandlung nach Hallux-valgus-Korrektur. Vorfuß-Entlastungsschuh für 6 Wochen.",
    "Hallux-valgus-OP",
    "Fuß / Vorfuß",
    [
      phase("Akutphase", 0, 14, [
        item("wound", "Wundkontrolle", "Verband nicht durchnässen, Zehen sichtbar halten"),
        item("dressing", "Redressionsverband", "Großzehe in Korrekturstellung fixiert"),
        item("medication", "Schmerzmedikation", "NSAR + Hochlagerung"),
        item("medication", "Thromboseprophylaxe", "NMH bis Vollbelastung oder 10 Tage"),
        item("weightBearing", "Belastung im Verbandsschuh", "Vollbelastung über Ferse im Vorfuß-Entlastungsschuh"),
        item("aid", "Vorfuß-Entlastungsschuh", "Durchgehend tragen für 6 Wochen"),
        item("custom", "Hochlagerung", "So oft wie möglich Fuß hochlegen, insbesondere nachts"),
      ]),
      phase("Frühphase", 15, 28, [
        item("sutureRemoval", "Fadenzug", "Tag 12–14"),
        item("wound", "Narbenpflege", "Narbenmassage ab Woche 3"),
        item("physio", "Zehengymnastik", "Aktive/passive Mobilisation der Großzehe"),
        item("custom", "Röntgenkontrolle 4 Wochen", "Stellung und Konsolidierung prüfen"),
      ]),
      phase("Aufbauphase", 29, 56, [
        item("weightBearing", "Vollbelastung im normalen Schuh", "Weiter, gut sitzender Schuh mit Einlage"),
        item("physio", "Abrolltraining", "Abrollübungen, Propriozeption, Fußgymnastik"),
        item("custom", "Kontrolltermin 6 Wochen", "Röntgen + klinische Kontrolle"),
        item("aid", "Einlagen", "Spreizfuß-Einlagen nach Maß"),
      ]),
      phase("Sportphase", 57, 84, [
        item("physio", "Sport-Reha", "Lauftraining ab Woche 10"),
        item("custom", "Schuhwahl", "Keine High Heels für 6 Monate, spitze Schuhe vermeiden"),
        item("custom", "Sportfreigabe", "Vollständiger Sport frühestens ab Monat 3"),
      ]),
    ]
  ),
];

// ══════════════════════════════════════════════════════════════════════
// Main
// ══════════════════════════════════════════════════════════════════════

async function main() {
  console.log(`Seeding ${TEMPLATES.length} system aftercare templates...`);

  const batch = db.batch();
  for (const tpl of TEMPLATES) {
    const ref = db.collection(COLLECTION).doc();
    batch.set(ref, tpl);
    console.log(`  → ${tpl.title}`);
  }

  await batch.commit();
  console.log("Done! Templates seeded successfully.");
  process.exit(0);
}

main().catch((err) => {
  console.error("Error:", err);
  process.exit(1);
});
