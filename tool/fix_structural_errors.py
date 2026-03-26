#!/usr/bin/env python3
"""Fix structural errors introduced by the broken l10n fix script.

This script fixes:
1. `static _x =` → `static const _x =` (where const was removed)
2. `_x =` (top-level) → `const _x =` (where const was removed)  
3. Removes stray `final l = AppLocalizations.of(context)!;` inside map/list/switch literals
4. Reverts `l.xxx` to hardcoded strings in static const / enum / extension contexts
"""

import re
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Map of l10n keys back to their original German strings.
# Only for keys used in static/const/enum/extension contexts where l is unavailable.
REVERT_MAP = {
    'l.aeltesteZuerst': "'Älteste zuerst'",
    'l.aufklaerung': "'Aufklärung'",
    'l.leichteAuffaelligkeit': "'Leichte Auffälligkeit'",
    'l.erhoehtesRisiko': "'Erhöhtes Risiko'",
    'l.einzelneWerteLeichtAusserhalbDesNormalbereichsBitteBe':
        "'Einzelne Werte leicht außerhalb des Normalbereichs. Bitte beobachten.'",
    'l.mehrereWerteAuffaelligKontaktierenSieIhrenArztZeitnah':
        "'Mehrere Werte auffällig. Kontaktieren Sie Ihren Arzt zeitnah.'",
    'l.kritischeWerteErkanntSofortigeAerztlicheHilfeEmpfohlen':
        "'Kritische Werte erkannt. Sofortige ärztliche Hilfe empfohlen.'",
    'l.loeschung': "'Löschung'",
    'l.aerzte': "'Ärzte'",
    'l.symptomePruefen': "'Symptome prüfen'",
    'l.notierenSieIhreAktuellenBeschwerdenUndDerenStaerke':
        "'Notieren Sie Ihre aktuellen Beschwerden und deren Stärke.'",
    'l.strukturierteEinschaetzungDeinerWundheilung':
        "'Strukturierte Einschätzung deiner Wundheilung'",
    'l.jedenMorgenDeinPersoenlicherUeberblick':
        "'Jeden Morgen dein persönlicher Überblick'",
    'l.gespraecheFuerArztOderAngehoerigeTeilen':
        "'Gespräche für Arzt oder Angehörige teilen'",
    'l.inviteFamilyMember': "'Angehörige einladen'",
    'l.entdeckeNeueFunktionenInDeinerAppJetztOeffnen':
        "'Entdecke neue Funktionen in deiner App. Jetzt öffnen!'",
    'l.fuegeDeineOpInformationenHinzu':
        "'Füge deine OP-Informationen hinzu.'",
    'l.aufklaerungsgespraech': "'Aufklärungsgespräch'",
    'l.n10Maerz2026': "'10. März 2026'",
    'l.gefaesschirurgie': "'Gefäßchirurgie'",
    'l.gynaekologie': "'Gynäkologie'",
    'l.roetung': "'Rötung'",
    'l.istDerVerbandBereitsKomplettDurchnaesst':
        "'Ist der Verband bereits komplett durchnässt?'",
    'l.fuehlenSieSichSchwindeligOderSchwach':
        "'Fühlen Sie sich schwindelig oder schwach?'",
    'l.keineBeruehrungDerWundeKeineManipulationKeineCremes':
        "'Keine Berührung der Wunde, keine Manipulation, keine Cremes'",
    'l.erstelleEinArztBriefingFuerMeinenNaechstenTermin':
        "'Erstelle ein Arzt-Briefing für meinen nächsten Termin'",
    'l.praeOp': "'Prä-OP'",
    'l.uebersprungen': "'Übersprungen'",
    'l.faellig': "'Fällig'",
    'l.rueckgaengig': "'Rückgängig'",
    'l.pinBestaetigen': "'PIN bestätigen'",
}


def fix_file(filepath, content):
    """Apply fixes to a single file. Returns (new_content, changes_count)."""
    lines = content.split('\n')
    changes = 0
    i = 0
    new_lines = []
    
    while i < len(lines):
        line = lines[i]
        
        # Pattern 1: Remove stray `final l = AppLocalizations.of(context)!;` 
        # inside map/list/switch/constructor literals
        # These are lines that are purely the l declaration inside a non-method context
        stripped = line.strip()
        if stripped == 'final l = AppLocalizations.of(context)!;':
            # Check if this is inside a map/list/switch literal by looking at surrounding context
            # Look backward for opening { or [ or switch (
            in_bad_context = False
            for back in range(max(0, len(new_lines) - 5), len(new_lines)):
                prev = new_lines[back].strip()
                # Inside a map literal
                if prev.endswith('{') and ('static' in new_lines[back] or 
                    '= <' in new_lines[back] or 
                    re.search(r'=\s*<[^>]+>\{', new_lines[back]) or
                    prev.startswith('{')):
                    in_bad_context = True
                    break
                # Inside a switch expression  
                if 'switch' in prev and (prev.endswith('{') or prev.endswith('{')):
                    in_bad_context = True
                    break
                # Inside a constructor call
                if prev.endswith('(') or (prev.endswith(',') and not prev.startswith('//')):
                    in_bad_context = True
                    break
                # Inside a const list/map
                if 'const' in prev and ('[' in prev or '{' in prev):
                    in_bad_context = True
                    break
                if prev.endswith('['):
                    in_bad_context = True
                    break
            
            if in_bad_context:
                # Skip this line entirely
                changes += 1
                i += 1
                continue
        
        # Pattern 2: Fix `static _x =` → `static const _x =`
        m = re.match(r'^(\s+)static (_\w+\s*=)', line)
        if m and 'static const' not in line and 'static final' not in line:
            indent = m.group(1)
            rest = m.group(2)
            new_lines.append(f'{indent}static const {rest}' + line[m.end():])
            changes += 1
            i += 1
            continue
        
        # Pattern 2b: Fix top-level `_x =` → `const _x =` (no indent)
        m = re.match(r'^(_\w+\s*=)', line)
        if m and not line.startswith('_') == False:
            if re.match(r'^_\w+\s*=\s*<', line):
                new_lines.append('const ' + line)
                changes += 1
                i += 1
                continue
        
        new_lines.append(line)
        i += 1
    
    # Now revert l.xxx references in non-method contexts
    result = '\n'.join(new_lines)
    for l_key, original in REVERT_MAP.items():
        if l_key in result:
            result = result.replace(l_key, original)
            changes += 1
    
    return result, changes


def main():
    total_changes = 0
    total_files = 0
    
    for dirpath, dirnames, filenames in os.walk(os.path.join(ROOT, 'lib')):
        for filename in filenames:
            if not filename.endswith('.dart'):
                continue
            filepath = os.path.join(dirpath, filename)
            with open(filepath) as f:
                content = f.read()
            
            new_content, changes = fix_file(filepath, content)
            if changes > 0:
                with open(filepath, 'w') as f:
                    f.write(new_content)
                rel = os.path.relpath(filepath, ROOT)
                print(f'Fixed {changes} issues in {rel}')
                total_files += 1
                total_changes += changes
    
    print(f'\nTotal: {total_changes} fixes in {total_files} files')


if __name__ == '__main__':
    main()
