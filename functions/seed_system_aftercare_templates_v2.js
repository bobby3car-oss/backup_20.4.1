#!/usr/bin/env node
/**
 * Seed script v2 — populates system_aftercare_templates with
 * 25 medically detailed aftercare templates covering all major
 * surgical disciplines.
 *
 * Usage:
 *   cd functions && node seed_system_aftercare_templates_v2.js
 *
 * NOTE: Deletes ALL existing system templates first, then re-seeds.
 */

const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const fs = require("fs");
const path = require("path");

// ── ADC bootstrap ─────────────────────────────────────────────────────
function ensureADC() {
  const adcPath = path.join(
    process.env.HOME || process.env.USERPROFILE,
    ".config", "gcloud", "application_default_credentials.json"
  );
  if (fs.existsSync(adcPath)) return;

  const fbConfig = path.join(
    process.env.HOME || process.env.USERPROFILE,
    ".config", "configstore", "firebase-tools.json"
  );
  if (!fs.existsSync(fbConfig)) {
    console.error("No Firebase CLI credentials. Run 'firebase login' first.");
    process.exit(1);
  }
  const config = JSON.parse(fs.readFileSync(fbConfig, "utf8"));
  const rt = config?.tokens?.refresh_token;
  if (!rt) { console.error("No refresh token."); process.exit(1); }

  const dir = path.dirname(adcPath);
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(adcPath, JSON.stringify({
    client_id: "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com",
    client_secret: "j9iVZfS8kkCEFUPaAeJV0sAi",
    refresh_token: rt,
    type: "authorized_user",
  }, null, 2));
  console.log("Created ADC from Firebase CLI credentials.");
}

ensureADC();
initializeApp({ projectId: "operationsbegleiter-860e7" });
const db = getFirestore();

const COL = "system_aftercare_templates";

// ── Helpers ───────────────────────────────────────────────────────────
let ic = 0, pc = 0;
const pid = () => `p${++pc}`;
const iid = () => `i${++ic}`;

const I = (category, title, description = "", extra = {}) => ({
  id: iid(), category, title, description,
  isTimeBound: false, showInTimeline: true,
  value: {}, notes: "", order: 0, ...extra,
});

const P = (title, s, e, items) => ({
  id: pid(), title, startDayOffset: s,
  ...(e != null ? { endDayOffset: e } : {}),
  order: 0, items,
});

const T = (title, description, surgeryType, bodyRegion, phases) => ({
  title, description, surgeryType, bodyRegion,
  createdBy: "system", templateType: "system", version: 1,
  createdAt: FieldValue.serverTimestamp(),
  updatedAt: FieldValue.serverTimestamp(),
  phases,
});

// ══════════════════════════════════════════════════════════════════════
// 25 Templates — grouped by body region
// ══════════════════════════════════════════════════════════════════════

const TEMPLATES = [

// ╔═══════════════════════════════════════════════════════════════════╗
// ║  KNIE                                                            ║
// ╚═══════════════════════════════════════════════════════════════════╝

// 1 ── Knie-TEP ────────────────────────────────────────────────────
T("Knie-TEP — Totalendoprothese",
  "Standardnachbehandlung nach primärer Knie-Totalendoprothese. Stufenweiser Belastungsaufbau über 12 Wochen.",
  "Knie-TEP", "Knie", [
  P("Akutphase (stationär)", 0, 5, [
    I("wound", "Wundkontrolle", "Tägliche Inspektion auf Rötung, Schwellung, Sekretion"),
    I("dressing", "Steriler Verband", "Verbandwechsel alle 2 Tage"),
    I("medication", "Thromboseprophylaxe", "NMH s.c. für 4–6 Wochen"),
    I("medication", "Schmerzmedikation", "Multimodales Schmerzkonzept nach Stufenschema"),
    I("weightBearing", "Teilbelastung", "Schmerzadaptierte Teilbelastung 20 kg mit Unterarmgehstützen"),
    I("physio", "KG ab Tag 1", "Mobilisation, isometrische Übungen, Gangschule"),
    I("cpm", "Motorschiene (CPM)", "Ab Tag 1, initial 0–60°, Steigerung bis Entlassung auf 0–90°"),
    I("aid", "Unterarmgehstützen", "Gangschule mit Physiotherapie"),
    I("rom", "Passive Flexion", "Ziel bei Entlassung: 0-0-90°"),
  ]),
  P("Frühphase", 6, 14, [
    I("wound", "Wundkontrolle", "Ambulante Kontrolle bei Hausarzt"),
    I("sutureRemoval", "Fadenzug", "Fadenentfernung ab Tag 10–14 post-OP"),
    I("weightBearing", "Teilbelastung steigern", "Steigerung auf 50 % Körpergewicht"),
    I("physio", "Ambulante Physiotherapie", "3× pro Woche, Gangschule, aktive/passive Mobilisation"),
    I("rom", "Aktive Flexion", "Ziel: 0-0-100°"),
    I("medication", "Thromboseprophylaxe", "NMH fortführen bis Ende Woche 6"),
    I("supplement", "Vitamin D + Calcium", "Vitamin D 1000 IE/Tag, Calcium 1000 mg/Tag"),
  ]),
  P("Aufbauphase", 15, 42, [
    I("weightBearing", "Vollbelastung anbahnen", "Schrittweise Steigerung zur Vollbelastung nach ärztlicher Freigabe"),
    I("physio", "Intensivierte Physiotherapie", "Muskelaufbau Quadrizeps, Beinachsentraining, Koordination"),
    I("rom", "Beweglichkeit optimieren", "Ziel: 0-0-120°, Streckdefizit < 5°"),
    I("aid", "Gehstützen abtrainieren", "Bei sicherer Vollbelastung schrittweise Entwöhnung"),
    I("custom", "Kontrolltermin Operateur", "6-Wochen-Kontrolle mit Röntgen"),
  ]),
  P("Belastungsaufbau", 43, 84, [
    I("physio", "Sport-Physiotherapie", "Krafttraining, Ausdauer auf Ergometer, Aquajogging"),
    I("weightBearing", "Vollbelastung", "Volle Alltagsbelastung, Treppensteigen ohne Hilfsmittel"),
    I("rom", "Endgradiges Training", "Optimierung der Beweglichkeit, Dehnübungen"),
    I("custom", "Kontrolltermin 12 Wochen", "12-Wochen-Kontrolle mit Funktionstest"),
    I("custom", "Alltagsaktivitäten", "Radfahren ab Woche 8, Schwimmen ab Woche 10"),
  ]),
]),

// 2 ── VKB-Plastik ─────────────────────────────────────────────────
T("Vordere Kreuzband-Plastik (VKB-Rekonstruktion)",
  "Nachbehandlung nach arthroskopischer VKB-Rekonstruktion mit Semitendinosus-/Gracilis- oder Patellarsehne.",
  "VKB-Plastik", "Knie", [
  P("Akutphase", 0, 7, [
    I("wound", "Wundkontrolle", "Arthroskopie-Portale täglich inspizieren, auf Erguss achten"),
    I("dressing", "Steriler Verband", "Wundstreifen bis Fadenzug"),
    I("medication", "Schmerzmedikation", "NSAR + ggf. Opioide nach Bedarf"),
    I("medication", "Thromboseprophylaxe", "NMH für 2 Wochen oder bis Vollbelastung"),
    I("weightBearing", "Teilbelastung", "20 kg Teilbelastung an Unterarmgehstützen"),
    I("aid", "VKB-Orthese", "Limitiert auf 0-0-90° Flexion, durchgehend tragen"),
    I("physio", "Isometrische Übungen", "Quadrizeps-Anspannung, Beinrückseite, Wadenpumpe"),
    I("rom", "Passive Extension", "Volle Streckung sofort erlaubt, aktive Beugung 0–90°"),
    I("custom", "RICE-Prinzip", "Hochlagerung, Kühlung 20 min alle 2 Std."),
  ]),
  P("Frühphase", 8, 21, [
    I("sutureRemoval", "Fadenzug", "Fadenentfernung Tag 10–14"),
    I("weightBearing", "Teilbelastung steigern", "Steigerung auf 50 % Körpergewicht"),
    I("physio", "Ambulante KG", "3× pro Woche, geschlossene Kette, Beinpresse, Fahrrad ohne Widerstand"),
    I("rom", "Flexion steigern", "Ziel: 0-0-120° bis Ende Woche 3"),
    I("aid", "Orthese Freigabe", "Stufenweise ROM-Freigabe nach ärztlicher Kontrolle"),
  ]),
  P("Aufbauphase", 22, 56, [
    I("weightBearing", "Vollbelastung", "Vollbelastung ab Woche 4, Stützen abtrainieren"),
    I("physio", "Muskelaufbau", "Leg-Press, Beinstrecker (geschlossene Kette), Koordination"),
    I("rom", "Volle ROM anstreben", "Ziel: seitengleiche Beweglichkeit"),
    I("aid", "Orthese abtrainieren", "Ab Woche 6 schrittweise Entwöhnung"),
    I("custom", "Kontrolltermin 6 Wochen", "Klinische Kontrolle, Stabilitätstest"),
  ]),
  P("Return-to-Sport-Phase", 57, 270, [
    I("physio", "Athletik-Training", "Lauftraining ab Monat 3, Sprungtraining ab Monat 5"),
    I("custom", "Kontrolltermin 3 Monate", "MRT-Kontrolle und klinische Testung"),
    I("custom", "Sporttests", "Functional testing ab Monat 6: Hop-Test, Krafttest"),
    I("custom", "Return-to-Sport", "Frühestens ab Monat 9 nach bestandenem Testprotokoll"),
  ]),
]),

// 3 ── Meniskusnaht ────────────────────────────────────────────────
T("Meniskusnaht (arthroskopisch)",
  "Nachbehandlung nach arthroskopischer Meniskusnaht. Teilbelastung für 6 Wochen, da Naht einheilen muss.",
  "Meniskusnaht", "Knie", [
  P("Akutphase", 0, 7, [
    I("wound", "Wundkontrolle", "Arthroskopie-Portale inspizieren"),
    I("medication", "Schmerzmedikation", "NSAR + Kühlung"),
    I("medication", "Thromboseprophylaxe", "NMH für 6 Wochen"),
    I("weightBearing", "Teilbelastung 20 kg", "Unterarmgehstützen, Sohlenkontakt"),
    I("aid", "Knie-Orthese", "Limitiert auf 0-0-60° Flexion"),
    I("physio", "Isometrische Übungen", "Quadrizeps-Anspannung, SLR"),
    I("rom", "Extension halten", "Volle Streckung sofort, Beugung max. 60°"),
  ]),
  P("Frühphase", 8, 28, [
    I("sutureRemoval", "Fadenzug", "Tag 10–14"),
    I("weightBearing", "Teilbelastung", "20 kg beibehalten bis Woche 4"),
    I("rom", "Flexion steigern", "Woche 3: 90° / Woche 4: 120°"),
    I("physio", "Passive Mobilisation", "Physiotherapie 2–3× pro Woche"),
    I("aid", "Orthesen-Anpassung", "ROM stufenweise freigeben"),
  ]),
  P("Aufbauphase", 29, 56, [
    I("weightBearing", "Vollbelastung", "Ab Woche 5 schrittweise Steigerung"),
    I("physio", "Muskelaufbau", "Geschlossene Kette, Fahrradergometer"),
    I("rom", "Volle ROM", "Ziel: seitengleiche Beweglichkeit"),
    I("aid", "Orthese ablegen", "Ab Woche 6"),
    I("custom", "Kontrolltermin 6 Wochen", "Klinische Kontrolle, ggf. MRT"),
  ]),
  P("Return-to-Sport", 57, 120, [
    I("physio", "Sport-Reha", "Lauftraining ab Woche 10, Sprünge ab Woche 14"),
    I("custom", "Sportfreigabe", "Kontaktsport ab Monat 4–6 nach Testung"),
  ]),
]),

// 4 ── Meniskus-Teilresektion ──────────────────────────────────────
T("Meniskus-Teilresektion (arthroskopisch)",
  "Schnelle Nachbehandlung nach arthroskopischer Meniskus-Teilresektion. Sofortige Vollbelastung erlaubt.",
  "Meniskus-Resektion", "Knie", [
  P("Akutphase", 0, 3, [
    I("wound", "Wundkontrolle", "Arthroskopie-Portale inspizieren"),
    I("medication", "Schmerzmedikation", "NSAR + Kühlung"),
    I("weightBearing", "Vollbelastung", "Sofortige schmerzadaptierte Vollbelastung erlaubt"),
    I("physio", "Isometrische Übungen", "Quadrizeps-Anspannung, Wadenpumpe"),
    I("custom", "Kühlung", "Kühlung 20 Min., alle 2–3 Std. für 3 Tage"),
  ]),
  P("Frühphase", 4, 14, [
    I("sutureRemoval", "Fadenzug", "Tag 7–10"),
    I("physio", "Physiotherapie", "2–3× pro Woche, Mobilisation, Stabilisation"),
    I("rom", "Volle Beweglichkeit", "Schnelle Rückkehr zur vollen ROM anstreben"),
    I("custom", "Aktivitätssteigerung", "Spaziergänge steigern, Treppensteigen üben"),
  ]),
  P("Aufbauphase", 15, 42, [
    I("physio", "Muskelaufbau", "Beinpresse, Ergometer, Koordinationstraining"),
    I("custom", "Kontrolltermin 4 Wochen", "Klinische Kontrolle beim Operateur"),
    I("custom", "Sportfreigabe", "Leichter Sport ab Woche 3, Kontaktsport ab Woche 6"),
  ]),
]),

// 5 ── Hintere Kreuzband-Plastik ───────────────────────────────────
T("Hintere Kreuzband-Plastik (HKB-Rekonstruktion)",
  "Nachbehandlung nach HKB-Rekonstruktion. Konservativere Rehabilitation als VKB wegen Schutz der posterioren Strukturen.",
  "HKB-Plastik", "Knie", [
  P("Akutphase (Schutzphase)", 0, 14, [
    I("wound", "Wundkontrolle", "Arthroskopie-Portale inspizieren"),
    I("dressing", "Steriler Verband", "Verbandwechsel alle 2 Tage"),
    I("medication", "Schmerzmedikation", "NSAR + ggf. Opioide"),
    I("medication", "Thromboseprophylaxe", "NMH für 6 Wochen"),
    I("weightBearing", "Teilbelastung 20 kg", "Unterarmgehstützen, kein aktives Kniebeugen"),
    I("aid", "HKB-Orthese", "In voller Extension fixiert für 2 Wochen, dann schrittweise Freigabe"),
    I("physio", "Quadrizeps-Aktivierung", "Isometrische Quadrizeps-Anspannung, Patella-Mobilisation"),
    I("rom", "Passive Extension", "Volle Streckung halten, KEINE freie Flexion > 60°"),
    I("custom", "Kein aktives Hamstring-Training", "Passive Beugung nur durch Physiotherapeut"),
  ]),
  P("Frühphase", 15, 42, [
    I("sutureRemoval", "Fadenzug", "Tag 10–14"),
    I("weightBearing", "Teilbelastung steigern", "Steigerung auf 50 % KG ab Woche 3"),
    I("physio", "Physiotherapie", "3× pro Woche, geschlossene Kette, Quadrizeps-Fokus"),
    I("rom", "Flexion steigern", "Woche 3: 60° → Woche 4: 90° → Woche 6: 120°"),
    I("aid", "Orthese weiterhin", "ROM stufenweise freigeben"),
  ]),
  P("Aufbauphase", 43, 84, [
    I("weightBearing", "Vollbelastung", "Ab Woche 6 Vollbelastung ohne Stützen"),
    I("physio", "Muskelaufbau", "Beinpresse, Step-Ups, Ergometer"),
    I("rom", "Volle ROM", "Seitengleiche Beweglichkeit anstreben"),
    I("custom", "Kontrolltermin 6 Wochen", "Klinische Kontrolle, posteriore Schublade testen"),
  ]),
  P("Return-to-Sport", 85, 270, [
    I("physio", "Athletik-Training", "Lauftraining ab Monat 4, agility ab Monat 6"),
    I("custom", "Kontrolltermin 3 Monate", "MRT + klinische Testung"),
    I("custom", "Return-to-Sport", "Frühestens Monat 9, kein isoliertes Hamstring-Training vor Monat 6"),
  ]),
]),

// 6 ── Patellafraktur (Osteosynthese) ──────────────────────────────
T("Patellafraktur — Zuggurtungsosteosynthese",
  "Nachbehandlung nach operativer Versorgung einer Patellafraktur. Schutz des Streckapparats bei schrittweiser Beugungsfreigabe.",
  "Patellafraktur-OS", "Knie", [
  P("Akutphase", 0, 14, [
    I("wound", "Wundkontrolle", "Tägliche Inspektion, Schwellung dokumentieren"),
    I("dressing", "Steriler Verband", "Verbandwechsel alle 2 Tage"),
    I("medication", "Thromboseprophylaxe", "NMH für 6 Wochen"),
    I("medication", "Schmerzmedikation", "NSAR + Kühlung"),
    I("weightBearing", "Teilbelastung 20 kg", "Unterarmgehstützen, Bein in Extensionsschiene"),
    I("aid", "Extensionsschiene", "Knie in Streckstellung fixiert, Tag und Nacht"),
    I("physio", "Quadrizeps isometrisch", "Anspannungsübungen, Patella-Mobilisation vorsichtig"),
    I("rom", "Keine Flexion", "Volle Streckung halten, keine Beugung"),
  ]),
  P("Frühphase", 15, 28, [
    I("sutureRemoval", "Fadenzug", "Tag 12–14"),
    I("rom", "Flexion beginnen", "Passive Beugung bis maximal 30° ab Woche 3, steigern auf 60° bis Woche 4"),
    I("physio", "Physiotherapie", "2–3× pro Woche, assistive Mobilisation"),
    I("weightBearing", "Teilbelastung steigern", "Steigerung auf 30 kg"),
  ]),
  P("Aufbauphase", 29, 56, [
    I("rom", "Flexion steigern", "Woche 5: 90° / Woche 8: volle ROM"),
    I("weightBearing", "Vollbelastung", "Ab Woche 6 schmerzadaptiert steigern"),
    I("physio", "Muskelaufbau", "Quadrizeps-Kräftigung, Beinpresse leicht"),
    I("aid", "Schiene ablegen", "Ab Woche 6 bei guter muskulärer Kontrolle"),
    I("custom", "Kontrolltermin 6 Wochen", "Röntgen, Stabilitätstest der Osteosynthese"),
  ]),
  P("Belastungsaufbau", 57, 84, [
    I("physio", "Intensives Training", "Krafttraining, Ergometer, Koordination"),
    I("custom", "Sportfreigabe", "Schwimmen ab Woche 10, Laufen ab Woche 12"),
    I("custom", "ME-Planung", "Materialentfernung nach 12–18 Monaten besprechen"),
  ]),
]),

// ╔═══════════════════════════════════════════════════════════════════╗
// ║  HÜFTE                                                            ║
// ╚═══════════════════════════════════════════════════════════════════╝

// 7 ── Hüft-TEP ───────────────────────────────────────────────────
T("Hüft-TEP — Totalendoprothese",
  "Standardnachbehandlung nach primärer Hüft-Totalendoprothese. Schnelle Mobilisation mit Luxationsprophylaxe.",
  "Hüft-TEP", "Hüfte", [
  P("Akutphase (stationär)", 0, 5, [
    I("wound", "Wundkontrolle", "Tägliche Inspektion, Redon-Drainagen nach 24–48 h entfernen"),
    I("dressing", "Steriler Verband", "Verbandwechsel bei Durchfeuchtung, sonst alle 2 Tage"),
    I("medication", "Thromboseprophylaxe", "NMH s.c. für 35 Tage postoperativ"),
    I("medication", "Schmerzmedikation", "Multimodales Schmerzkonzept"),
    I("weightBearing", "Schmerzadaptierte Vollbelastung", "Sofortige Vollbelastung erlaubt (zementiert) oder Teilbelastung 20 kg (zementfrei)"),
    I("physio", "Frühmobilisation", "Aufstehen am OP-Tag oder Tag 1, Gangschule mit Stützen"),
    I("aid", "Unterarmgehstützen", "Für 6 Wochen"),
    I("custom", "Luxationsprophylaxe", "Flexion < 90°, keine Adduktion über Mittellinie, keine Innenrotation"),
  ]),
  P("Frühphase", 6, 14, [
    I("wound", "Wundkontrolle ambulant", "Kontrolle auf Wundheilungsstörung"),
    I("sutureRemoval", "Klammern/Fadenzug", "Klammerentfernung Tag 10–14"),
    I("physio", "Ambulante Physiotherapie", "3× pro Woche, Gangschule, Muskelaktivierung, Hüftmobilisation"),
    I("rom", "Passive ROM", "Flexion bis 90°, Extension 0°"),
    I("medication", "Thromboseprophylaxe", "NMH fortführen bis Tag 35"),
  ]),
  P("Aufbauphase", 15, 42, [
    I("weightBearing", "Vollbelastung", "Vollbelastung mit Stützen, ab Woche 6 ohne Stützen"),
    I("physio", "Muskelaufbau", "Abduktoren, Extensoren, Stabilisationstraining"),
    I("rom", "Aktive Mobilisation", "Flexion > 90° nach ärztlicher Freigabe"),
    I("aid", "Gehstützen abbauen", "Ab Woche 6 schrittweise reduzieren"),
    I("custom", "Kontrolltermin 6 Wochen", "Röntgenkontrolle und Funktionstest"),
  ]),
  P("Sportphase", 43, 84, [
    I("physio", "Sport-Reha", "Ergometertraining, Aquajogging, Walking"),
    I("custom", "Alltagssport", "Radfahren, Schwimmen, Nordic Walking ab Woche 8"),
    I("custom", "Kontrolltermin 12 Wochen", "Abschlusskontrolle mit Funktionsbeurteilung"),
  ]),
]),

// 8 ── Hüft-Arthroskopie (CAM-/Pincer-Impingement) ────────────────
T("Hüft-Arthroskopie — FAI/Impingement",
  "Nachbehandlung nach arthroskopischer Behandlung eines femoroazetabulären Impingements (CAM/Pincer).",
  "Hüft-Arthroskopie", "Hüfte", [
  P("Akutphase", 0, 7, [
    I("wound", "Wundkontrolle", "Arthroskopie-Portale tgl. inspizieren"),
    I("medication", "Schmerzmedikation", "NSAR für 2 Wochen, kein Indomethacin (Heterotope-Ossifikation-Prophylaxe prüfen)"),
    I("medication", "Thromboseprophylaxe", "NMH für 2 Wochen"),
    I("weightBearing", "Teilbelastung", "20 kg Teilbelastung an UAG für 2–4 Wochen (labrum-abhängig)"),
    I("physio", "Passive Mobilisation", "CPM oder passive ROM durch Therapeut, keine aktive Flexion > 90°"),
    I("rom", "Passive ROM", "Flexion passiv bis 90°, Rotation 0°-Stellung"),
    I("custom", "Kein Sitzen > 90° Flexion", "Keilkissen verwenden, kein tiefes Sitzen für 4 Wochen"),
  ]),
  P("Frühphase", 8, 28, [
    I("sutureRemoval", "Fadenzug", "Tag 10–14"),
    I("physio", "Pooltherapie", "Aquajogging ab Woche 2 (bei geschlossener Wunde)"),
    I("weightBearing", "Teilbelastung steigern", "Übergang zur Vollbelastung ab Woche 3–4"),
    I("rom", "Aktive ROM", "Vorsichtige aktive Flexion, Rotation beginnen"),
    I("physio", "Hüft-Stabilisation", "Gluteus-medius-Aktivierung, isometrische Übungen"),
  ]),
  P("Aufbauphase", 29, 56, [
    I("weightBearing", "Vollbelastung", "Stützen abtrainieren"),
    I("physio", "Muskelaufbau", "Abduktoren, Rotatoren, Core-Stabilisation"),
    I("rom", "Volle ROM", "Schrittweise Rückkehr zur vollen Beweglichkeit"),
    I("custom", "Kontrolltermin 6 Wochen", "Klinische Kontrolle, Impingement-Tests"),
  ]),
  P("Return-to-Sport", 57, 120, [
    I("physio", "Sport-Reha", "Lauftraining ab Woche 10, sportspezifisches Training ab Woche 12"),
    I("custom", "Sportfreigabe", "Kontaktsport frühestens ab Monat 4"),
    I("custom", "Kontrolltermin 3 Monate", "Funktionstest, klinische Kontrolle"),
  ]),
]),

// 9 ── Schenkelhalsfraktur (DHS/Verschraubung) ─────────────────────
T("Schenkelhalsfraktur — Verschraubung/DHS",
  "Nachbehandlung nach kopferhaltender Versorgung einer Schenkelhalsfraktur (Verschraubung oder dynamische Hüftschraube).",
  "SHF-Verschraubung", "Hüfte", [
  P("Akutphase (stationär)", 0, 7, [
    I("wound", "Wundkontrolle", "Tägliche Inspektion"),
    I("dressing", "Steriler Verband", "Verbandwechsel alle 2 Tage"),
    I("medication", "Thromboseprophylaxe", "NMH für 6 Wochen"),
    I("medication", "Schmerzmedikation", "Multimodales Konzept, NSAR + Opioide nach Bedarf"),
    I("weightBearing", "Teilbelastung 15–20 kg", "Unterarmgehstützen, strenge Teilbelastung"),
    I("physio", "Frühmobilisation", "Aufstehen ab Tag 1, Gangschule, Transfertraining"),
    I("aid", "Unterarmgehstützen", "Durchgehend für mindestens 6 Wochen"),
    I("custom", "Sturzprophylaxe", "Stolperfallen beseitigen, Gehhilfen nachts griffbereit"),
  ]),
  P("Frühphase", 8, 28, [
    I("sutureRemoval", "Fadenzug", "Tag 12–14"),
    I("physio", "Ambulante Physiotherapie", "3× pro Woche, Gangschule, Balance-Training"),
    I("weightBearing", "Teilbelastung beibehalten", "15–20 kg bis zur 6-Wochen-Kontrolle"),
    I("supplement", "Vitamin D + Calcium", "Osteoporose-Screening, ggf. spez. Therapie"),
  ]),
  P("Aufbauphase", 29, 56, [
    I("custom", "Röntgenkontrolle 6 Wochen", "Frakturkonsolidierung beurteilen, Hüftkopfnekrose ausschließen"),
    I("weightBearing", "Belastung steigern", "Bei guter Konsolidierung schrittweise auf Vollbelastung"),
    I("physio", "Intensivierte KG", "Muskelaufbau, Gangbildoptimierung"),
    I("aid", "Gehstützen reduzieren", "Auf 1 Stütze, dann frei"),
  ]),
  P("Langzeit-Follow-up", 57, 180, [
    I("custom", "Kontrolltermin 3 Monate", "Röntgen, Hüftkopfnekrose-Screening"),
    I("custom", "Kontrolltermin 12 Monate", "MRT bei Beschwerden, Abschluss-Röntgen"),
    I("physio", "Aktivitätsaufbau", "Normales Gangbild anstreben, Alltagssport"),
  ]),
]),

// ╔═══════════════════════════════════════════════════════════════════╗
// ║  SCHULTER                                                         ║
// ╚═══════════════════════════════════════════════════════════════════╝

// 10 ── Rotatorenmanschetten-Rekonstruktion ─────────────────────────
T("Rotatorenmanschetten-Rekonstruktion",
  "Nachbehandlung nach arthroskopischer Rekonstruktion der Rotatorenmanschette (kleine bis mittlere Ruptur).",
  "RM-Rekonstruktion", "Schulter", [
  P("Akutphase (Ruhigstellung)", 0, 14, [
    I("wound", "Wundkontrolle", "Arthroskopie-Portale inspizieren"),
    I("dressing", "Steriler Verband", "Verbandwechsel alle 2 Tage"),
    I("medication", "Schmerzmedikation", "NSAR + Kühlung"),
    I("aid", "Schulterabduktionskissen", "15° Abduktionsschiene für 6 Wochen, Tag und Nacht"),
    I("physio", "Pendelübungen", "Vorsichtige Pendelübungen nach Codman ab Tag 3"),
    I("rom", "Passive ROM", "Passive Elevation bis 60°, keine aktive Abduktion"),
    I("custom", "Vorsichtsmaßnahmen", "Kein Heben > 500 g, keine aktive Außenrotation"),
  ]),
  P("Frühphase", 15, 42, [
    I("sutureRemoval", "Fadenzug", "Fäden ab Tag 10–14 entfernen"),
    I("physio", "Assistive Mobilisation", "Physiotherapie 3× pro Woche, assistive Elevation"),
    I("rom", "Passive ROM erweitern", "Passive Elevation bis 120°, Außenrotation bis 20°"),
    I("aid", "Schiene abtrainieren", "Ab Woche 6 Abschinung beenden"),
    I("custom", "Kontrolltermin 6 Wochen", "Klinische Kontrolle, ggf. Ultraschall"),
  ]),
  P("Aktive Mobilisation", 43, 84, [
    I("physio", "Aktive ROM", "Aktive Bewegung beginnen, isometrische Kräftigung"),
    I("rom", "Aktive Elevation", "Ziel: aktive Elevation > 140°"),
    I("custom", "Kein Widerstandstraining", "Noch kein Krafttraining gegen Widerstand"),
    I("custom", "Kontrolltermin 3 Monate", "Klinische Kontrolle, Kraft-/Bewegungstest"),
  ]),
  P("Kraftaufbau", 85, 180, [
    I("physio", "Krafttraining", "Theraband-Übungen, Außen-/Innenrotation gegen Widerstand"),
    I("custom", "Überkopfsport", "Frühestens ab Monat 6 nach funktioneller Testung"),
    I("custom", "Kontrolltermin 6 Monate", "Abschlusskontrolle, Freigabe für Sport"),
  ]),
]),

// 11 ── Schulter-Arthroskopie subakromiale Dekompression ────────────
T("Subakromiale Dekompression (Schulter-Arthroskopie)",
  "Nachbehandlung nach arthroskopischer subakromialer Dekompression bei Impingement-Syndrom.",
  "SAD", "Schulter", [
  P("Akutphase", 0, 7, [
    I("wound", "Wundkontrolle", "Arthroskopie-Portale inspizieren"),
    I("medication", "Schmerzmedikation", "NSAR + Kühlung"),
    I("aid", "Armschlinge", "Für 2–3 Tage bei Bedarf, nicht dauerhaft"),
    I("physio", "Pendelübungen", "Pendelübungen ab Tag 1, aktive Elevation assistiv"),
    I("rom", "Aktive ROM", "Sofortige aktive Bewegung erlaubt, schmerzlimitiert"),
  ]),
  P("Frühphase", 8, 28, [
    I("sutureRemoval", "Fadenzug", "Tag 10–14"),
    I("physio", "Aktive Physiotherapie", "3× pro Woche, aktive Elevation, Außenrotation"),
    I("rom", "Volle ROM anstreben", "Ziel: volle schmerzfreie Elevation bis Woche 4"),
    I("custom", "Kontrolltermin 4 Wochen", "Klinische Kontrolle"),
  ]),
  P("Aufbauphase", 29, 56, [
    I("physio", "Krafttraining", "Rotatorenmanschettentraining mit Theraband"),
    I("custom", "Aktivitätssteigerung", "Überkopf-Aktivitäten schrittweise wieder aufnehmen"),
  ]),
  P("Sportphase", 57, 84, [
    I("physio", "Sport-Reha", "Sportspezifisches Training (Wurf, Schwimmen, etc.)"),
    I("custom", "Sportfreigabe", "Frühestens 6 Wochen, Vollsport ab 8–10 Wochen"),
  ]),
]),

// 12 ── Bankart-Repair (Schulterinstabilität) ──────────────────────
T("Bankart-Repair — Schulterinstabilität",
  "Nachbehandlung nach arthroskopischer Bankart-Reparatur bei anteriorer Schulterinstabilität.",
  "Bankart-Repair", "Schulter", [
  P("Akutphase (Schutzphase)", 0, 21, [
    I("wound", "Wundkontrolle", "Arthroskopie-Portale inspizieren"),
    I("dressing", "Steriler Verband", "Verbandwechsel alle 2 Tage"),
    I("medication", "Schmerzmedikation", "NSAR + ggf. Opioide"),
    I("aid", "Schulter-Immobilisator", "Innenrotationsschlinge für 3–4 Wochen durchgehend"),
    I("physio", "Pendelübungen", "Ab Tag 3, vorsichtige Pendelübungen"),
    I("rom", "Passive Flexion", "Passive Elevation bis 60°, KEINE Außenrotation"),
    I("custom", "Strenge Limitierung", "Keine Außenrotation, keine Abduktion > 60° für 6 Wochen"),
  ]),
  P("Frühphase", 22, 42, [
    I("sutureRemoval", "Fadenzug", "Tag 10–14"),
    I("physio", "Assistive Mobilisation", "Passive/assistive Elevation bis 120°, Außenrotation 0°"),
    I("aid", "Schlinge ablegen", "Ab Woche 4 tagsüber, nachts bis Woche 6"),
    I("rom", "ROM erweitern", "Flexion bis 120°, vorsichtige Außenrotation bis 0°"),
  ]),
  P("Aktive Mobilisation", 43, 84, [
    I("physio", "Aktive ROM", "Aktive Bewegung in alle Richtungen, isometrische Kräftigung"),
    I("rom", "Volle ROM", "Ziel: volle Elevation, Außenrotation bis 45°"),
    I("custom", "Keine Überkopfsportarten", "Noch kein Wurf/Schwimmen/Tennis"),
    I("custom", "Kontrolltermin 3 Monate", "Klinische Stabilitätstestung"),
  ]),
  P("Return-to-Sport", 85, 180, [
    I("physio", "Krafttraining", "Rotatorenmanschetten-Kräftigung, Stabilisationstraining"),
    I("custom", "Sportfreigabe", "Kontaktsport frühestens ab Monat 6"),
    I("custom", "Kontrolltermin 6 Monate", "Abschlussbeurteilung, Krafttest"),
  ]),
]),

// 13 ── Proximale Humerusfraktur ───────────────────────────────────
T("Proximale Humerusfraktur — Plattenosteosynthese",
  "Nachbehandlung nach operativer Versorgung einer proximalen Humerusfraktur (PHILOS-Platte o.ä.).",
  "Humerusfraktur-OS", "Schulter", [
  P("Akutphase", 0, 14, [
    I("wound", "Wundkontrolle", "Tägliche Inspektion, Redon nach 48 h entfernen"),
    I("dressing", "Steriler Verband", "Verbandwechsel alle 2 Tage"),
    I("medication", "Schmerzmedikation", "NSAR + Analgetika"),
    I("aid", "Gilchrist-Verband / Schlinge", "Für 2–3 Wochen, nachts fixiert"),
    I("physio", "Pendelübungen", "Vorsichtige Pendelübungen ab Tag 3"),
    I("rom", "Passive Elevation", "Bis 60° passiv, keine aktive Abduktion"),
  ]),
  P("Frühphase", 15, 42, [
    I("sutureRemoval", "Fadenzug", "Tag 12–14"),
    I("physio", "Assistive Mobilisation", "Passive/assistive Elevation bis 90°, nur unter Physio"),
    I("rom", "ROM stufenweise", "Woche 3: 60° → Woche 4: 90° → Woche 6: 120°"),
    I("aid", "Schlinge ablegen", "Ab Woche 3 tagsüber"),
    I("custom", "Röntgenkontrolle 4 Wochen", "Konsolidierung prüfen"),
  ]),
  P("Aufbauphase", 43, 84, [
    I("physio", "Aktive Mobilisation", "Aktive Elevation beginnen, leichte Kräftigung"),
    I("rom", "Volle ROM anstreben", "Aktive Elevation > 140° bis Woche 12"),
    I("custom", "Kontrolltermin 3 Monate", "Röntgen, Funktionstest"),
    I("custom", "Heben limitieren", "Maximal 5 kg bis Woche 12"),
  ]),
  P("Abschlussphase", 85, 180, [
    I("physio", "Krafttraining", "Rotatorenmanschette, Deltamuskel, isometrisch → dynamisch"),
    I("custom", "ME-Planung", "Materialentfernung nach 12–18 Monaten bei Beschwerden"),
    I("custom", "Kontrolltermin 6 Monate", "Abschlussröntgen, Funktionsbeurteilung"),
  ]),
]),

// ╔═══════════════════════════════════════════════════════════════════╗
// ║  FUSS / SPRUNGGELENK                                              ║
// ╚═══════════════════════════════════════════════════════════════════╝

// 14 ── Sprunggelenkfraktur (Weber B/C) ────────────────────────────
T("Sprunggelenkfraktur (Weber B/C)",
  "Nachbehandlung nach operativer Versorgung einer Sprunggelenkfraktur. 6-Wochen-Entlastungsprotokoll.",
  "OSG-Fraktur", "Sprunggelenk", [
  P("Akutphase (Ruhigstellung)", 0, 14, [
    I("wound", "Wundkontrolle", "Tägliche Inspektion, auf Schwellung und Durchblutung achten"),
    I("dressing", "Steriler Verband", "Verbandwechsel bei Bedarf"),
    I("medication", "Thromboseprophylaxe", "NMH für 6 Wochen oder bis Vollbelastung"),
    I("medication", "Schmerzmedikation", "NSAR + Analgetika nach Stufenschema"),
    I("weightBearing", "Entlastung", "Keine Belastung (0 kg), Unterarmgehstützen"),
    I("aid", "VACOped-Stiefel / Gips", "Ruhigstellung in Neutralposition"),
    I("physio", "Zehenübungen", "Aktive Zehengymnastik, Wadenpumpe"),
  ]),
  P("Frühphase", 15, 28, [
    I("sutureRemoval", "Fadenzug", "Fadenentfernung Tag 12–14"),
    I("wound", "Wundverlauf", "Narbe kontrollieren, Massieren nach Verschluss"),
    I("weightBearing", "15 kg Teilbelastung", "Sohlenkontakt mit 15 kg, Abrollbewegung"),
    I("physio", "Mobilisation Sprunggelenk", "Dorsalextension/Plantarflexion im schmerzfreien Bereich"),
    I("custom", "Röntgenkontrolle 4 Wochen", "Konsolidierungskontrolle"),
  ]),
  P("Aufbauphase", 29, 56, [
    I("weightBearing", "Belastung steigern", "Stufenweise Steigerung auf Vollbelastung"),
    I("physio", "Intensive Physiotherapie", "Propriozeption, Muskelaufbau Peroneusgruppe, Wadenheben"),
    I("aid", "Stiefel abtrainieren", "Ab Woche 6 Übergang zu festem Schuhwerk"),
    I("rom", "Endgradige Mobilisation", "Dorsalextension optimieren"),
    I("custom", "Kontrolltermin 6 Wochen", "Röntgen + klinische Kontrolle"),
  ]),
  P("Vollbelastung & Sport", 57, 84, [
    I("physio", "Sport-Reha", "Lauftraining, Koordination, Sprungtraining"),
    I("custom", "Sportfreigabe", "Sportfähigkeit nach frühestens 10–12 Wochen"),
    I("custom", "ME-Planung", "Materialentfernung nach 12–18 Monaten besprechen"),
  ]),
]),

// 15 ── Hallux valgus ──────────────────────────────────────────────
T("Hallux valgus — Chevron-/Scarf-Osteotomie",
  "Nachbehandlung nach Hallux-valgus-Korrektur. Vorfuß-Entlastungsschuh für 6 Wochen.",
  "Hallux-valgus-OP", "Fuß", [
  P("Akutphase", 0, 14, [
    I("wound", "Wundkontrolle", "Verband nicht durchnässen, Zehen sichtbar halten"),
    I("dressing", "Redressionsverband", "Großzehe in Korrekturstellung fixiert"),
    I("medication", "Schmerzmedikation", "NSAR + Hochlagerung"),
    I("medication", "Thromboseprophylaxe", "NMH bis Vollbelastung oder 10 Tage"),
    I("weightBearing", "Belastung im Verbandsschuh", "Vollbelastung über Ferse im Vorfuß-Entlastungsschuh"),
    I("aid", "Vorfuß-Entlastungsschuh", "Durchgehend tragen für 6 Wochen"),
    I("custom", "Hochlagerung", "So oft wie möglich Fuß hochlegen"),
  ]),
  P("Frühphase", 15, 28, [
    I("sutureRemoval", "Fadenzug", "Tag 12–14"),
    I("wound", "Narbenpflege", "Narbenmassage ab Woche 3"),
    I("physio", "Zehengymnastik", "Aktive/passive Mobilisation der Großzehe"),
    I("custom", "Röntgenkontrolle 4 Wochen", "Stellung und Konsolidierung prüfen"),
  ]),
  P("Aufbauphase", 29, 56, [
    I("weightBearing", "Vollbelastung im normalen Schuh", "Weiter, gut sitzender Schuh mit Einlage"),
    I("physio", "Abrolltraining", "Abrollübungen, Propriozeption, Fußgymnastik"),
    I("custom", "Kontrolltermin 6 Wochen", "Röntgen + klinische Kontrolle"),
    I("aid", "Einlagen", "Spreizfuß-Einlagen nach Maß"),
  ]),
  P("Sportphase", 57, 84, [
    I("physio", "Sport-Reha", "Lauftraining ab Woche 10"),
    I("custom", "Schuhwahl", "Keine High Heels für 6 Monate, spitze Schuhe vermeiden"),
    I("custom", "Sportfreigabe", "Vollständiger Sport frühestens ab Monat 3"),
  ]),
]),

// 16 ── Achillessehnen-Ruptur (Naht) ──────────────────────────────
T("Achillessehnenruptur — Naht/Rekonstruktion",
  "Nachbehandlung nach offener oder minimalinvasiver Achillessehnennaht. Spitzfuß-Ruhigstellung mit schrittweiser Stellungskorrektur.",
  "Achillessehnennaht", "Sprunggelenk", [
  P("Akutphase (Ruhigstellung)", 0, 14, [
    I("wound", "Wundkontrolle", "Naht inspizieren, auf Wundheilungsstörung achten"),
    I("dressing", "Steriler Verband", "Verbandwechsel alle 2–3 Tage"),
    I("medication", "Thromboseprophylaxe", "NMH für gesamte Immobilisierungsphase"),
    I("medication", "Schmerzmedikation", "NSAR + Analgetika"),
    I("weightBearing", "Entlastung", "Keine Belastung, Unterarmgehstützen"),
    I("aid", "Spezialschuh/Walker", "In 30° Equinus-Stellung (Spitzfuß), durchgehend tragen"),
    I("custom", "Kein barfuß Gehen", "Schuh/Walker IMMER tragen, auch nachts"),
  ]),
  P("Frühphase", 15, 28, [
    I("sutureRemoval", "Fadenzug", "Tag 12–14"),
    I("aid", "Keilreduktion", "Alle 2 Wochen Keil reduzieren (30° → 20° → 10° → 0°)"),
    I("weightBearing", "Teilbelastung", "Ab Woche 3 Teilbelastung 20 kg im Walker"),
    I("physio", "Vorsichtige Mobilisation", "Passive Dorsalextension bis Neutralposition"),
  ]),
  P("Aufbauphase", 29, 56, [
    I("weightBearing", "Vollbelastung im Walker", "Steigerung auf Vollbelastung bis Woche 6"),
    I("physio", "Ambulante Physiotherapie", "3× pro Woche, Plantarflexion aktiv, Dorsalextension passiv"),
    I("aid", "Walker ablegen", "Ab Woche 8 Übergang zu normalem Schuh mit Fersenerhöhung"),
    I("custom", "Kontrolltermin 6 Wochen", "Klinische Kontrolle, Ultraschall"),
    I("rom", "ROM-Ziel", "Dorsalextension mindestens 0° (Neutral)"),
  ]),
  P("Belastungsaufbau", 57, 120, [
    I("physio", "Exzentrisches Training", "Alfredson-Protokoll: exzentrische Wadenheben"),
    I("physio", "Propriozeption", "Einbeinstand, Wackelbrett, Trampolin"),
    I("custom", "Lauftraining", "Joggen frühestens ab Woche 14–16"),
    I("custom", "Sportfreigabe", "Vollsport frühestens ab Monat 6"),
    I("custom", "Kontrolltermin 3 Monate", "Funktionstest, Wadenkraft messen"),
  ]),
]),

// 17 ── Mittelfußfraktur (Metatarsale V / Jones) ──────────────────
T("Metatarsale-V-Fraktur / Jones-Fraktur",
  "Nachbehandlung nach operativer Versorgung einer Metatarsale-V-Basisfraktur (Jones-Fraktur) mit Zugschraube.",
  "Jones-Fraktur-OS", "Fuß", [
  P("Akutphase", 0, 14, [
    I("wound", "Wundkontrolle", "Minimalinvasiver Zugang inspizieren"),
    I("medication", "Schmerzmedikation", "NSAR + Hochlagerung"),
    I("medication", "Thromboseprophylaxe", "NMH für 2 Wochen"),
    I("weightBearing", "Entlastung", "Keine Belastung, Unterarmgehstützen"),
    I("aid", "Walker / Vorfuß-Entlastungsschuh", "Ruhigstellung für 6 Wochen"),
    I("custom", "Hochlagerung", "Fuß regelmäßig hochlagern, Kühlung"),
  ]),
  P("Frühphase", 15, 42, [
    I("sutureRemoval", "Fadenzug", "Tag 10–14"),
    I("weightBearing", "Teilbelastung", "Ab Woche 4 Sohlenkontakt, dann 20 kg"),
    I("physio", "Zehengymnastik", "Aktive Zemobilisation, Wadenpumpe"),
    I("custom", "Röntgenkontrolle 4 Wochen", "Konsolidierung prüfen"),
  ]),
  P("Aufbauphase", 43, 56, [
    I("weightBearing", "Vollbelastung anbahnen", "Steigerung auf Vollbelastung je nach Konsolidierung"),
    I("physio", "Abrolltraining", "Abrollübungen, Propriozeption"),
    I("aid", "Walker ablegen", "Übergang zu normalem Schuh"),
    I("custom", "Kontrolltermin 6 Wochen", "Röntgen + klinische Kontrolle"),
  ]),
  P("Return-to-Sport", 57, 120, [
    I("physio", "Sport-Reha", "Lauftraining ab Woche 10, Sprünge ab Woche 14"),
    I("custom", "Sportfreigabe", "Kontaktsport ab Woche 12–16"),
    I("supplement", "Vitamin D", "Vitamin D-Spiegel kontrollieren, supplementieren"),
  ]),
]),

// ╔═══════════════════════════════════════════════════════════════════╗
// ║  WIRBELSÄULE                                                      ║
// ╚═══════════════════════════════════════════════════════════════════╝

// 18 ── Mikrodiskektomie LWS ───────────────────────────────────────
T("Bandscheibenvorfall LWS — Mikrodiskektomie",
  "Nachbehandlung nach lumbaler Mikrodiskektomie. Fokus auf schnelle Mobilisation mit Wirbelsäulen-Schutzregeln.",
  "Mikrodiskektomie", "Wirbelsäule", [
  P("Akutphase (stationär)", 0, 3, [
    I("wound", "Wundkontrolle", "Minimaler Schnitt, Inspektion auf Sekretion"),
    I("medication", "Schmerzmedikation", "NSAR + PPI-Schutz, ggf. Muskelrelaxantien"),
    I("physio", "Frühmobilisation", "Aufstehen am OP-Tag, Gehen auf Station"),
    I("weightBearing", "Vollbelastung erlaubt", "Normales Gehen, kein Heben > 5 kg"),
    I("custom", "Wirbelsäulenregeln", "Kein Bücken, kein Heben, kein Verdrehen für 6 Wochen"),
  ]),
  P("Frühphase", 4, 14, [
    I("sutureRemoval", "Fadenzug", "Fadenentfernung ab Tag 10–12"),
    I("physio", "Walking-Programm", "Tägliche Spaziergänge, Dauer steigern (15 → 30 Min.)"),
    I("medication", "Schmerz-Reduktion", "Schrittweises Ausschleichen der Analgetika"),
    I("custom", "Sitzzeit begrenzen", "Maximal 20–30 Minuten am Stück sitzen"),
  ]),
  P("Stabilisierung", 15, 42, [
    I("physio", "Rückenschule", "Ambulante Physiotherapie, Rumpfstabilisation, Core-Training"),
    I("custom", "Sitzzeit erweitern", "Schrittweise Steigerung auf 45–60 Min."),
    I("custom", "Hebegrenze", "Maximal 5–10 kg, ergonomisches Heben"),
    I("custom", "Kontrolltermin 6 Wochen", "MRT-Kontrolle bei persistierenden Beschwerden"),
  ]),
  P("Belastungsaufbau", 43, 84, [
    I("physio", "Krafttraining", "Rückenextensoren, Bauchmuskeltraining, Ergometertraining"),
    I("custom", "Hebegrenze aufheben", "Ab Woche 8 schrittweise steigern"),
    I("custom", "Berufsfähigkeit", "Bürotätigkeit ab Woche 4–6, körperliche Arbeit ab Woche 8–12"),
    I("custom", "Sportfreigabe", "Schwimmen (Rücken) ab Woche 6, Joggen ab Woche 10"),
  ]),
]),

// 19 ── Lumbale Spondylodese ───────────────────────────────────────
T("Lumbale Spondylodese (Versteifung PLIF/TLIF)",
  "Nachbehandlung nach lumbaler Spondylodese (PLIF/TLIF) bei degenerativer Instabilität oder Spondylolisthesis.",
  "Spondylodese", "Wirbelsäule", [
  P("Akutphase (stationär)", 0, 5, [
    I("wound", "Wundkontrolle", "Tägliche Inspektion des OP-Zugangs"),
    I("dressing", "Steriler Verband", "Verbandwechsel alle 2 Tage"),
    I("medication", "Schmerzmedikation", "Multimodal, PCA-Pumpe initial, dann oral"),
    I("medication", "Thromboseprophylaxe", "NMH für 6 Wochen oder bis Mobilität"),
    I("physio", "Frühmobilisation", "Aufstehen Tag 1–2, Gangschule"),
    I("aid", "Lumbale Orthese (optional)", "Bei mehrsegmentaler Fusion für 6–12 Wochen"),
    I("custom", "Wirbelsäulen-Schutzregeln", "Kein Bücken, kein Heben > 3 kg, kein Verdrehen"),
  ]),
  P("Frühphase", 6, 28, [
    I("sutureRemoval", "Fadenzug", "Tag 12–14"),
    I("physio", "Walking-Programm", "Tägliche Spaziergänge steigern (10 → 30 Min.)"),
    I("custom", "Sitzzeit begrenzen", "Maximal 15–20 Min., mit Lendenkissen"),
    I("weightBearing", "Gehen ohne Stützen", "Wenn sicheres Gangbild"),
    I("medication", "Schmerzreduktion", "Opioide ausschleichen, auf NSAR umstellen"),
  ]),
  P("Stabilisierung", 29, 84, [
    I("physio", "Rumpfstabilisation", "Isometrische Core-Übungen, kein Rückenstrecker-Training"),
    I("custom", "Hebegrenze", "Maximal 5 kg bis Woche 12"),
    I("custom", "Sitzzeit steigern", "Auf 30–45 Min. steigern"),
    I("custom", "Kontrolltermin 6 Wochen", "Röntgen im Stehen, Fusionsstatus"),
    I("aid", "Orthese abtrainieren", "Ab Woche 8–12 schrittweise weglassen"),
  ]),
  P("Belastungsaufbau", 85, 180, [
    I("physio", "Krafttraining", "Rückenmuskulatur, Core, Ergometer"),
    I("custom", "Hebegrenze aufheben", "Ab Monat 4 schrittweise steigern"),
    I("custom", "Kontrolltermin 3 Monate", "Röntgen/CT, Fusionsbeurteilung"),
    I("custom", "Berufsfähigkeit", "Bürotätigkeit ab Woche 8, körperl. Arbeit ab Monat 4–6"),
    I("custom", "Kontrolltermin 12 Monate", "CT zur definitiv. Fusionsbeurteilung"),
  ]),
]),

// 20 ── HWS-Diskektomie mit Cage (ACDF) ───────────────────────────
T("Zervikale Diskektomie mit Cage (ACDF)",
  "Nachbehandlung nach anteriorer zervikaler Diskektomie und Fusion (ACDF).",
  "ACDF", "Wirbelsäule", [
  P("Akutphase (stationär)", 0, 3, [
    I("wound", "Wundkontrolle", "Vorderer Halszugang inspizieren, Hämatom ausschließen"),
    I("medication", "Schmerzmedikation", "Paracetamol + NSAR, ggf. kurz Opioide"),
    I("physio", "Frühmobilisation", "Aufstehen am OP-Tag, kein Anspannen der Halsmuskulatur"),
    I("custom", "Schlucken beobachten", "Dysphagie in den ersten Tagen normal, Logopädie bei Bedarf"),
    I("aid", "Halskrawatte (optional)", "Weiche Halskrawatte für 2 Wochen bei Bedarf"),
  ]),
  P("Frühphase", 4, 28, [
    I("sutureRemoval", "Fadenzug", "Tag 10–14 oder Wundstreifen-Entfernung"),
    I("custom", "Hebegrenze", "Kein Heben > 3 kg für 6 Wochen"),
    I("custom", "Autofahren", "Erst nach Halskrawatte-Abnahme, freie Kopfdrehung"),
    I("physio", "Sanfte HWS-Mobilisation", "Isometrische Übungen, Scapula-Setting"),
    I("custom", "Sitzarbeit", "Ergonomischer Arbeitsplatz, Bildschirm auf Augenhöhe"),
  ]),
  P("Aufbauphase", 29, 84, [
    I("physio", "Physiotherapie", "HWS-Stabilisation, Haltungstraining, Schulter-Nacken-Entspannung"),
    I("custom", "Kontrolltermin 6 Wochen", "Röntgen HWS seitlich, Cage-Position"),
    I("custom", "Hebegrenze steigern", "Ab Woche 6 schrittweise steigern auf 10 kg"),
    I("custom", "Sportfreigabe", "Schwimmen (Rücken/Kraul) ab Woche 8, Kontaktsport ab Monat 3"),
  ]),
  P("Langzeit", 85, 180, [
    I("custom", "Kontrolltermin 3 Monate", "Röntgen, Fusionsbeurteilung"),
    I("custom", "Kontrolltermin 12 Monate", "CT bei Bedarf, Abschlussbeurteilung"),
    I("physio", "Nackentraining", "Langfristiges Kräftigungsprogramm"),
  ]),
]),

// ╔═══════════════════════════════════════════════════════════════════╗
// ║  HAND / HANDGELENK                                                ║
// ╚═══════════════════════════════════════════════════════════════════╝

// 21 ── Distale Radiusfraktur (Plattenosteosynthese) ───────────────
T("Distale Radiusfraktur — Plattenosteosynthese",
  "Nachbehandlung nach volarer Plattenosteosynthese einer distalen Radiusfraktur.",
  "Radiusfraktur-OS", "Hand / Handgelenk", [
  P("Akutphase", 0, 14, [
    I("wound", "Wundkontrolle", "Tägliche Inspektion, Schwellung und Durchblutung der Finger"),
    I("dressing", "Steriler Verband", "Verbandwechsel alle 2 Tage"),
    I("medication", "Schmerzmedikation", "NSAR + Hochlagerung"),
    I("physio", "Finger-Mobilisation", "Sofortige aktive Finger-Übungen (Faustschluss, Spreizen)"),
    I("aid", "Handgelenksschiene", "Volare Schiene, nachts und bei Belastung für 4–6 Wochen"),
    I("custom", "Hochlagerung", "Hand auf Herzhöhe, insbesondere nachts"),
  ]),
  P("Frühphase", 15, 28, [
    I("sutureRemoval", "Fadenzug", "Tag 12–14"),
    I("physio", "Handgelenk-Mobilisation", "Vorsichtige aktive Flexion/Extension, Pro-/Supination"),
    I("rom", "Aktive ROM", "Flexion/Extension schmerzlimitiert beginnen"),
    I("custom", "Röntgenkontrolle 4 Wochen", "Stellungskontrolle"),
  ]),
  P("Aufbauphase", 29, 56, [
    I("physio", "Ergotherapie", "Feinmotorik, Greifübungen, Therapieknete"),
    I("aid", "Schiene ablegen", "Ab Woche 6 schrittweise"),
    I("rom", "Volle ROM anstreben", "Flexion/Extension > 60°, Pro-/Supination > 80°"),
    I("custom", "Kontrolltermin 6 Wochen", "Röntgen + Funktionstest"),
    I("custom", "Belastung steigern", "Ab Woche 6 leichte Belastung (< 5 kg)"),
  ]),
  P("Vollbelastung", 57, 84, [
    I("physio", "Kraft-/Ausdauertraining", "Handkrafttraining, Stützübungen"),
    I("custom", "Volle Belastung", "Ab Woche 10–12 volle Alltagsbelastung"),
    I("custom", "ME-Planung", "Bei Sehnenirritation ME nach 12 Monaten"),
  ]),
]),

// 22 ── Karpaltunnelsyndrom (CTS-OP) ──────────────────────────────
T("Karpaltunnel-OP (offene Spaltung)",
  "Nachbehandlung nach offener Spaltung des Retinaculum flexorum bei Karpaltunnelsyndrom.",
  "CTS-OP", "Hand / Handgelenk", [
  P("Akutphase", 0, 7, [
    I("wound", "Wundkontrolle", "Tägliche Inspektion, Handinnenfläche trocken halten"),
    I("dressing", "Steriler Verband", "Leichter Verband, Pflaster ab Tag 3"),
    I("medication", "Schmerzmedikation", "Paracetamol/NSAR nach Bedarf"),
    I("physio", "Finger-Mobilisation", "Sofortige aktive Fingerbewegung, Sehnengleitübungen"),
    I("custom", "Hochlagerung", "Hand hochlagern für 2–3 Tage"),
  ]),
  P("Frühphase", 8, 21, [
    I("sutureRemoval", "Fadenzug", "Tag 10–14"),
    I("physio", "Narbenmassage", "Ab Fadenzug: tgl. Narbenmassage mit Fettsalbe"),
    I("custom", "Greifübungen", "Leichte Alltagstätigkeiten wieder aufnehmen"),
    I("custom", "Kein schweres Greifen", "Keine Belastung > 2 kg für 4 Wochen"),
  ]),
  P("Aufbauphase", 22, 42, [
    I("physio", "Ergotherapie bei Bedarf", "Bei Narbenbeschwerden oder Kraftdefizit"),
    I("custom", "Belastung steigern", "Schrittweise Alltagsbelastung steigern"),
    I("custom", "Kontrolltermin 4 Wochen", "Klinische Kontrolle, Nervenfunktionstests"),
  ]),
  P("Abschluss", 43, 84, [
    I("custom", "Volle Belastung", "Ab Woche 6 volle Belastung erlaubt"),
    I("custom", "Narbe nachbehandeln", "Narbenmassage fortführen bei Beschwerden"),
    I("custom", "Berufsfähigkeit", "Bürotätigkeit ab Woche 2, manuelle Arbeit ab Woche 4–6"),
  ]),
]),

// ╔═══════════════════════════════════════════════════════════════════╗
// ║  ELLENBOGEN                                                       ║
// ╚═══════════════════════════════════════════════════════════════════╝

// 23 ── Ellenbogenfraktur (Radiusköpfchen-OS) ──────────────────────
T("Radiusköpfchenfraktur — Osteosynthese",
  "Nachbehandlung nach Schrauben-/Plattenosteosynthese einer Radiusköpfchenfraktur (Mason II–III).",
  "Radiusköpfchen-OS", "Ellenbogen", [
  P("Akutphase", 0, 7, [
    I("wound", "Wundkontrolle", "Tägliche Inspektion"),
    I("dressing", "Steriler Verband", "Verbandwechsel alle 2 Tage"),
    I("medication", "Schmerzmedikation", "NSAR + ggf. Opioide kurz"),
    I("aid", "Oberarmgipsschiene", "Dorsale Gipsschiene in 90° Flexion für 5–7 Tage"),
    I("physio", "Finger-/Handgelenk-Übungen", "Sofortige Mobilisation der Finger"),
  ]),
  P("Frühphase", 8, 28, [
    I("sutureRemoval", "Fadenzug", "Tag 10–14"),
    I("physio", "Aktive Mobilisation", "Flexion/Extension und Pro-/Supination aktiv, KEINE passive Extension"),
    I("rom", "Aktive ROM", "Aktive Beugung/Streckung schmerzlimitiert"),
    I("custom", "Keine passive Streckung", "Kein passives Forcing, Risiko heterotope Ossifikation"),
    I("custom", "Kontrolltermin 4 Wochen", "Röntgenkontrolle"),
  ]),
  P("Aufbauphase", 29, 56, [
    I("physio", "Intensivierte KG", "Aktive ROM intensivieren, leichte Kräftigung"),
    I("rom", "ROM optimieren", "Streckdefizit < 20° anstreben, volle Pro-/Supination"),
    I("custom", "Kontrolltermin 6 Wochen", "Röntgen, Funktionsbeurteilung"),
    I("custom", "Belastung steigern", "Leichtes Heben (< 5 kg) erlaubt"),
  ]),
  P("Vollbelastung", 57, 84, [
    I("physio", "Krafttraining", "Bizeps, Trizeps, Unterarmmuskulatur"),
    I("custom", "Volle Belastung", "Ab Woche 10–12"),
    I("custom", "Sportfreigabe", "Wurfsport frühestens ab Monat 3"),
  ]),
]),

// ╔═══════════════════════════════════════════════════════════════════╗
// ║  ABDOMEN / ALLGEMEINCHIRURGIE                                     ║
// ╚═══════════════════════════════════════════════════════════════════╝

// 24 ── Laparoskopische Cholezystektomie ───────────────────────────
T("Laparoskopische Cholezystektomie",
  "Nachbehandlung nach laparoskopischer Gallenblasenentfernung. Schnelle Rehabilitation, geringe Einschränkungen.",
  "Lap. Cholezystektomie", "Abdomen", [
  P("Akutphase", 0, 3, [
    I("wound", "Wundkontrolle", "Trokar-Zugänge inspizieren, auf Rötung/Sekretion achten"),
    I("dressing", "Pflaster", "Wundstreifen oder Pflaster, trocken halten"),
    I("medication", "Schmerzmedikation", "Paracetamol + NSAR, ggf. Metamizol"),
    I("custom", "Ernährung", "Leichte Kost für 2–3 Tage, dann Normalkost, fettarm erste Woche"),
    I("physio", "Frühmobilisation", "Aufstehen am OP-Tag, kurze Spaziergänge"),
  ]),
  P("Frühphase", 4, 14, [
    I("sutureRemoval", "Pflaster-/Fadenzug", "Wundstreifen ab Tag 7–10 entfernen"),
    I("custom", "Hebegrenze", "Kein Heben > 5 kg für 2 Wochen"),
    I("custom", "Aktivitäten", "Leichte Alltagstätigkeiten, Spaziergänge steigern"),
    I("custom", "Ernährung anpassen", "Bei Durchfall fettarme Ernährung fortführen"),
  ]),
  P("Aufbauphase", 15, 28, [
    I("custom", "Normales Leben", "Vollständige Alltagsbelastung möglich"),
    I("custom", "Sport", "Leichter Sport ab Woche 2, Kraftsport ab Woche 3–4"),
    I("custom", "Berufsfähigkeit", "Bürotätigkeit ab Tag 3–5, körperliche Arbeit ab Woche 2–3"),
    I("custom", "Kontrolltermin 2 Wochen", "Postoperative Kontrolle beim Chirurgen"),
  ]),
]),

// 25 ── Leistenhernie (TEP/TAPP laparoskopisch) ───────────────────
T("Leistenhernie — laparoskopische Netzimplantation (TEP/TAPP)",
  "Nachbehandlung nach laparoskopischer Leistenhernien-Reparation mit Netzimplantation.",
  "Leistenhernie-TEP", "Abdomen", [
  P("Akutphase", 0, 3, [
    I("wound", "Wundkontrolle", "Trokar-Zugänge inspizieren"),
    I("dressing", "Pflaster", "Wundstreifen/Pflaster, trocken halten"),
    I("medication", "Schmerzmedikation", "Paracetamol + NSAR"),
    I("physio", "Frühmobilisation", "Aufstehen am OP-Tag, kurze Spaziergänge"),
    I("custom", "Hustenpuffer", "Beim Husten/Niesen Leistenregion mit Kissen abstützen"),
  ]),
  P("Frühphase", 4, 14, [
    I("sutureRemoval", "Pflaster-Entfernung", "Wundstreifen ab Tag 7–10 entfernen"),
    I("custom", "Hebegrenze", "Kein Heben > 5 kg für 3 Wochen"),
    I("custom", "Aktivitäten", "Leichte Alltagstätigkeiten, Spaziergänge"),
    I("custom", "Kein Bauchpressen", "Kein schweres Pressen, Heben, Tragen"),
  ]),
  P("Aufbauphase", 15, 42, [
    I("custom", "Hebegrenze steigern", "Ab Woche 3 schrittweise auf 10 kg, ab Woche 6 normal"),
    I("custom", "Sport", "Leichter Sport ab Woche 3, Kontaktsport ab Woche 6"),
    I("custom", "Berufsfähigkeit", "Bürotätigkeit ab Woche 1, körperliche Arbeit ab Woche 3–4"),
    I("custom", "Kontrolltermin 4 Wochen", "Postoperative Kontrolle"),
  ]),
]),

];

// ══════════════════════════════════════════════════════════════════════
// Main
// ══════════════════════════════════════════════════════════════════════

async function main() {
  // 1. Delete all existing system templates
  console.log("Deleting existing system templates...");
  const existing = await db.collection(COL).get();
  if (!existing.empty) {
    const delBatch = db.batch();
    existing.docs.forEach(doc => delBatch.delete(doc.ref));
    await delBatch.commit();
    console.log(`  Deleted ${existing.size} existing templates.`);
  } else {
    console.log("  No existing templates.");
  }

  // 2. Seed new templates
  console.log(`\nSeeding ${TEMPLATES.length} system aftercare templates...\n`);

  // Firestore batch max = 500, we won't exceed that
  const batch = db.batch();
  for (const tpl of TEMPLATES) {
    const ref = db.collection(COL).doc();
    batch.set(ref, tpl);
    console.log(`  → ${tpl.title}  (${tpl.bodyRegion})`);
  }

  await batch.commit();
  console.log(`\n✓ Done! ${TEMPLATES.length} templates seeded.`);
  process.exit(0);
}

main().catch(err => {
  console.error("Error:", err);
  process.exit(1);
});
