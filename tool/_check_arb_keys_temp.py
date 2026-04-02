import json, sys

with open('lib/l10n/app_de.arb', 'r') as f:
    data = json.load(f)

keys = [k for k in data.keys() if not k.startswith('@') and k != '@@locale']
print(f'Total keys: {len(keys)}')

needed = [
    'tabOverview','tabDoctors','tabTeam','tabPatients','tabProfile','tabCalendar','tabPlan',
    'greetingMorning','greetingDay','greetingEvening','today','logout','aerzte','praeOp',
    'uebersicht','profil','patienten','fieldName','fieldType','fieldTitle','fieldNotes',
    'fieldWebsite','proStatus','statusActive','notProvided','searchPatient','sorting',
    'compliance','quickActions','templates','monthlyReport','myPatients','verified',
    'tabReport','tabWound','tabPain','tabDocuments','tabMedications','tabQuestions','tabNotes',
    'noAppointmentsToday','phasePreOp','phasePostOp','phaseOpDay','phaseDischarged',
    'totalPatients','activePatients','openRedFlags','phaseDistribution',
    'erstelltAm','orgRegContactPerson','orgRegAddress','orgRegPhone','orgRegRoleBadge','fieldEmail'
]

for k in needed:
    if k in data:
        v = data[k]
        if isinstance(v, str):
            print(f'  EXISTS: {k} = {v[:60]}')
        else:
            print(f'  EXISTS: {k} (complex)')
    else:
        print(f'  MISSING: {k}')
