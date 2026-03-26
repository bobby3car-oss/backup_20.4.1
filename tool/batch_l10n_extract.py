#!/usr/bin/env python3
"""
Phase 1: Extract all hardcoded German strings, generate ARB keys and translations.
Outputs a JSON mapping file for Phase 2 to consume.
"""
import os
import re
import json
import unicodedata

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
L10N_DIR = os.path.join(ROOT, 'lib', 'l10n')
OUTPUT = os.path.join(ROOT, 'tool', 'l10n_batch_mapping.json')

# Load existing ARB keys
with open(os.path.join(L10N_DIR, 'app_de.arb')) as f:
    arb = json.load(f)
existing_keys = {k for k in arb if not k.startswith('@') and k != '@@locale'}
existing_values = {}
for k, v in arb.items():
    if not k.startswith('@') and isinstance(v, str):
        existing_values[v] = k


def to_camel_case(german_text: str) -> str:
    """Generate a camelCase key from German text."""
    # Remove quotes and special chars
    s = german_text.strip()
    # Truncate very long strings
    if len(s) > 60:
        s = s[:60]
    # Replace German chars
    replacements = {
        'ä': 'ae', 'ö': 'oe', 'ü': 'ue', 'ß': 'ss',
        'Ä': 'Ae', 'Ö': 'Oe', 'Ü': 'Ue',
    }
    for old, new in replacements.items():
        s = s.replace(old, new)
    # Remove non-alphanumeric
    s = re.sub(r'[^a-zA-Z0-9\s]', ' ', s)
    # Split into words and camelCase
    words = s.split()
    if not words:
        return 'unknown'
    result = words[0].lower()
    for w in words[1:]:
        if w:
            result += w[0].upper() + w[1:].lower()
    # Ensure valid Dart identifier
    if result and result[0].isdigit():
        result = 'n' + result
    return result[:80]  # max key length


def find_hardcoded_strings():
    """Find all hardcoded German strings in lib/ Dart files."""
    lib_dir = os.path.join(ROOT, 'lib')
    skip_dirs = {'l10n', 'generated'}
    skip_files = {'app_localizations', 'firebase_options'}
    
    results = []  # list of (rel_path, line_no, string, in_arb, arb_key, has_l10n)
    
    for dirpath, dirnames, filenames in os.walk(lib_dir):
        dirnames[:] = [d for d in dirnames if d not in skip_dirs]
        for fn in filenames:
            if not fn.endswith('.dart'):
                continue
            if any(s in fn for s in skip_files):
                continue
            filepath = os.path.join(dirpath, fn)
            with open(filepath) as f:
                content = f.read()
                lines = content.split('\n')
            
            has_l10n = 'AppLocalizations' in content or 'final l = ' in content
            
            for i, line in enumerate(lines, 1):
                stripped = line.strip()
                if stripped.startswith('//') or stripped.startswith('*') or stripped.startswith('/*'):
                    continue
                if stripped.startswith('import '):
                    continue
                
                matches = re.findall(r"'([^']{2,})'|\"([^\"]{2,})\"", line)
                for m in matches:
                    s = m[0] or m[1]
                    if not s:
                        continue
                    if not re.search(r'[äöüÄÖÜß]', s):
                        continue
                    if s.startswith('http') or s.startswith('/') or s.startswith('assets/'):
                        continue
                    if s.startswith('package:') or s.startswith('firebase'):
                        continue
                    if '.' in s and ' ' not in s and len(s.split('.')) > 2:
                        continue
                    if 'l.' in s or 'l10n.' in s:
                        continue
                    
                    rel_path = os.path.relpath(filepath, ROOT)
                    in_arb = s in existing_values
                    arb_key = existing_values.get(s, '')
                    results.append({
                        'file': rel_path,
                        'line': i,
                        'string': s,
                        'in_arb': in_arb,
                        'existing_key': arb_key,
                        'has_l10n': has_l10n,
                    })
    
    return results


def is_presentation_file(filepath: str) -> bool:
    """Check if a file is in the presentation layer (has BuildContext)."""
    presentation_patterns = [
        '/screens/', '/presentation/', '/ui/', '/roles/',
        '_screen.dart', '_tab.dart', '_dialog.dart', '_sheet.dart',
        '_card.dart', '_tile.dart', '_page.dart', '_overlay.dart',
        '_banner.dart', '_widget.dart', '_indicator.dart',
    ]
    return any(p in filepath for p in presentation_patterns)


def main():
    results = find_hardcoded_strings()
    
    # Deduplicate strings and generate keys
    string_to_key = {}
    key_to_translations = {}
    used_keys = set(existing_keys)
    
    # Process each string
    for r in results:
        s = r['string']
        if s in string_to_key:
            continue  # already processed
        
        if r['in_arb']:
            string_to_key[s] = r['existing_key']
            continue
        
        # Generate key
        base_key = to_camel_case(s)
        key = base_key
        counter = 2
        while key in used_keys:
            key = f"{base_key}{counter}"
            counter += 1
        
        used_keys.add(key)
        string_to_key[s] = key
        key_to_translations[key] = {
            'de': s,
            'en': '',  # To be filled
            'ar': '',  # To be filled
            'ru': '',  # To be filled
            'tr': '',  # To be filled
        }
    
    # Build output structure
    output = {
        'summary': {
            'total_strings': len(results),
            'unique_strings': len(string_to_key),
            'new_keys_needed': len(key_to_translations),
            'presentation_files': len(set(r['file'] for r in results if is_presentation_file(r['file']))),
            'domain_files': len(set(r['file'] for r in results if not is_presentation_file(r['file']))),
        },
        'string_to_key': string_to_key,
        'new_translations': key_to_translations,
        'file_strings': {},  # file -> [(line, string, key)]
    }
    
    for r in results:
        f = r['file']
        if f not in output['file_strings']:
            output['file_strings'][f] = []
        output['file_strings'][f].append({
            'line': r['line'],
            'string': r['string'],
            'key': string_to_key.get(r['string'], ''),
            'is_presentation': is_presentation_file(f),
        })
    
    with open(OUTPUT, 'w', encoding='utf-8') as f:
        json.dump(output, f, ensure_ascii=False, indent=2)
    
    print(f"Extracted {output['summary']['total_strings']} strings")
    print(f"  Unique: {output['summary']['unique_strings']}")
    print(f"  New keys needed: {output['summary']['new_keys_needed']}")
    print(f"  Presentation files: {output['summary']['presentation_files']}")
    print(f"  Domain files: {output['summary']['domain_files']}")
    print(f"\nOutput: {OUTPUT}")
    print(f"\nNext: Fill in translations in the JSON, then run batch_l10n_apply.py")


if __name__ == '__main__':
    main()
