#!/usr/bin/env python3
"""Add doctor profile l10n keys to ARB files."""
import json

DE_KEYS = {
    "doctorProfileNotSpecified": "Nicht hinterlegt",
    "doctorProfilePracticeInfo": "Praxisinformationen",
    "doctorProfileWebsite": "Website",
    "doctorProfileOpeningHours": "\u00d6ffnungszeiten",
    "doctorProfileSpecialties": "Spezialgebiete",
    "doctorProfileProfessionalInfo": "Berufliche Angaben",
    "doctorProfileApprobation": "Approbation",
    "doctorProfileKvNumber": "KV-Nummer",
    "doctorProfilePracticeName": "Praxisname",
    "doctorProfileStaffMember": "Mitarbeiter/in",
    "doctorProfileAccountSupport": "Konto & Support",
    "doctorProfileImageUploadError": "Profilbild konnte nicht hochgeladen werden.",
    "doctorProfileYourProfile": "Dein Profil",
    "doctorProfileVerified": "Verifiziert",
    "doctorProfileVerificationPending": "Pr\u00fcfung ausstehend",
    "doctorProfileClosed": "Geschlossen",
    "doctorProfileNoSpecialties": "Keine Spezialgebiete hinterlegt",
    "doctorProfileNewSpecialtyHint": "Neues Spezialgebiet\u2026",
}

EN_KEYS = {
    "doctorProfileNotSpecified": "Not specified",
    "doctorProfilePracticeInfo": "Practice information",
    "doctorProfileWebsite": "Website",
    "doctorProfileOpeningHours": "Opening hours",
    "doctorProfileSpecialties": "Specialties",
    "doctorProfileProfessionalInfo": "Professional credentials",
    "doctorProfileApprobation": "Medical license",
    "doctorProfileKvNumber": "KV number",
    "doctorProfilePracticeName": "Practice name",
    "doctorProfileStaffMember": "Staff member",
    "doctorProfileAccountSupport": "Account & Support",
    "doctorProfileImageUploadError": "Profile picture could not be uploaded.",
    "doctorProfileYourProfile": "Your profile",
    "doctorProfileVerified": "Verified",
    "doctorProfileVerificationPending": "Verification pending",
    "doctorProfileClosed": "Closed",
    "doctorProfileNoSpecialties": "No specialties specified",
    "doctorProfileNewSpecialtyHint": "New specialty\u2026",
}

def update_arb(path, new_keys):
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    data.update(new_keys)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")

update_arb("lib/l10n/app_de.arb", DE_KEYS)
update_arb("lib/l10n/app_en.arb", EN_KEYS)
print("Done: added doctor profile keys to both ARB files")
