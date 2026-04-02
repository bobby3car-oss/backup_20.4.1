#!/usr/bin/env python3
"""Add Bella AI multi-role l10n keys to both DE and EN arb files."""
import json

DE_KEYS = {
    "bellaDescriptionOrganisation": "Ich helfe dir bei der Verwaltung deiner Organisation, \u00c4rzten, Mitarbeitern und Statistiken.",
    "bellaSubtitleOrganisation": "Dein Organisations-Assistent \U0001f430",
    "bellaFeatureBilling": "Abrechnung",
    "bellaFeatureDoctors": "\u00c4rzte",
    "bellaFeatureOrgStats": "Statistiken",
    "bellaFeatureTeam": "Team",
    "bellaChipDoctorBroadcast": "Nachricht an alle Patienten senden",
    "bellaChipDoctorCreateAppointment": "Termin f\u00fcr Patient erstellen",
    "bellaChipDoctorInvitePatient": "Neuen Patienten einladen",
    "bellaChipManageDoctors": "Wie verwalte ich meine \u00c4rzte?",
    "bellaChipOrgBillingInfo": "Wie ist unser Abonnement-Status?",
    "bellaChipOrgDashboard": "Zeig mir unsere Organisations-\u00dcbersicht",
    "bellaChipOrgInviteDoctor": "Einen neuen Arzt einladen",
    "bellaChipOrgStats": "Zeig mir unsere Statistiken",
    "bellaChipStaffCreateAppointment": "Termin f\u00fcr Patient erstellen",
}

EN_KEYS = {
    "bellaDescriptionOrganisation": "I help you manage your organisation, doctors, staff, and statistics.",
    "bellaSubtitleOrganisation": "Your organisation assistant \U0001f430",
    "bellaFeatureBilling": "Billing",
    "bellaFeatureDoctors": "Doctors",
    "bellaFeatureOrgStats": "Statistics",
    "bellaFeatureTeam": "Team",
    "bellaChipDoctorBroadcast": "Send a message to all patients",
    "bellaChipDoctorCreateAppointment": "Create an appointment for a patient",
    "bellaChipDoctorInvitePatient": "Invite a new patient",
    "bellaChipManageDoctors": "How do I manage my doctors?",
    "bellaChipOrgBillingInfo": "What is our subscription status?",
    "bellaChipOrgDashboard": "Show our organisation overview",
    "bellaChipOrgInviteDoctor": "Invite a new doctor",
    "bellaChipOrgStats": "Show our statistics",
    "bellaChipStaffCreateAppointment": "Create an appointment for a patient",
}

def update_arb(path, new_keys):
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    added = 0
    for k, v in new_keys.items():
        if k not in data:
            data[k] = v
            added += 1
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(f"  {path}: {added} new keys added ({len(new_keys) - added} already existed)")

if __name__ == "__main__":
    update_arb("lib/l10n/app_de.arb", DE_KEYS)
    update_arb("lib/l10n/app_en.arb", EN_KEYS)
    print("Done!")
