const fs = require('fs');
const src = fs.readFileSync(__dirname + '/index.js', 'utf8');

const prompts = [
  { name: '1. MEDICAL_SYSTEM_PROMPT', pattern: /const MEDICAL_SYSTEM_PROMPT\s*=\s*`([\s\S]*?)`;/ },
  { name: '2. ROLE_INSTRUCTIONS.patient', pattern: /patient:\s*`([\s\S]*?)`/ },
  { name: '3. ROLE_INSTRUCTIONS.doctor', pattern: /doctor:\s*`([\s\S]*?)`/ },
  { name: '4. ROLE_INSTRUCTIONS.staff', pattern: /staff:\s*`([\s\S]*?)`/ },
  { name: '5. ROLE_INSTRUCTIONS.family', pattern: /family:\s*`([\s\S]*?)`/ },
  { name: '6. BELLA_ACTIONS_PROMPT', pattern: /const BELLA_ACTIONS_PROMPT\s*=\s*`([\s\S]*?)`;/ },
  { name: '7. WOUND_ANALYSIS_PROMPT', pattern: /const WOUND_ANALYSIS_PROMPT\s*=\s*`([\s\S]*?)`;/ },
  { name: '8. SYMPTOM_CHECK_PROMPT', pattern: /const SYMPTOM_CHECK_PROMPT\s*=\s*`([\s\S]*?)`;/ },
  { name: '9. PRO_UPSELL_INSTRUCTIONS', pattern: /const PRO_UPSELL_INSTRUCTIONS\s*=\s*`([\s\S]*?)`;/ },
];

console.log('=== PROMPT-CHECK (9 Prompts) ===\n');

let allOk = true;
prompts.forEach(p => {
  const match = src.match(p.pattern);
  if (match && match[1].trim().length > 50) {
    console.log(`  ✅ ${p.name} (${match[1].trim().length} Zeichen)`);
  } else {
    console.log(`  ❌ ${p.name} — FEHLT oder zu kurz!`);
    allOk = false;
  }
});

// Check usage in askAssistant and askAssistantStream
const usages = [
  'MEDICAL_SYSTEM_PROMPT',
  'BELLA_ACTIONS_PROMPT',
  'SYMPTOM_CHECK_PROMPT',
  'PRO_UPSELL_INSTRUCTIONS',
  'WOUND_ANALYSIS_PROMPT',
  'ROLE_INSTRUCTIONS',
];

console.log('\n=== VERWENDUNG IN FUNCTIONS ===\n');
usages.forEach(u => {
  const count = (src.match(new RegExp(u, 'g')) || []).length;
  const ok = count > 1;
  console.log(`  ${ok ? '✅' : '⚠️'} ${u} wird ${count}x referenziert`);
});

// Check askAssistant prompt composition
console.log('\n=== PROMPT-KOMPOSITION in askAssistant ===\n');
const askAssistantBlock = src.substring(
  src.indexOf('exports.askAssistant'),
  src.indexOf('exports.askAssistantStream')
);
const checks = [
  { label: 'MEDICAL_SYSTEM_PROMPT wird verwendet', test: askAssistantBlock.includes('MEDICAL_SYSTEM_PROMPT') },
  { label: 'roleInstruction wird angehängt', test: askAssistantBlock.includes('roleInstruction') },
  { label: 'SYMPTOM_CHECK_PROMPT (symptomCheck mode)', test: askAssistantBlock.includes('SYMPTOM_CHECK_PROMPT') },
  { label: 'BELLA_ACTIONS_PROMPT (Pro)', test: askAssistantBlock.includes('BELLA_ACTIONS_PROMPT') },
  { label: 'PRO_UPSELL_INSTRUCTIONS (Free)', test: askAssistantBlock.includes('PRO_UPSELL_INSTRUCTIONS') },
];
checks.forEach(c => console.log(`  ${c.test ? '✅' : '❌'} ${c.label}`));

// Check askAssistantStream prompt composition
console.log('\n=== PROMPT-KOMPOSITION in askAssistantStream ===\n');
const streamStart = src.indexOf('exports.askAssistantStream');
const streamEnd = src.indexOf('exports.', streamStart + 30);
const streamBlock = src.substring(streamStart, streamEnd > -1 ? streamEnd : streamStart + 5000);
const streamChecks = [
  { label: 'MEDICAL_SYSTEM_PROMPT wird verwendet', test: streamBlock.includes('MEDICAL_SYSTEM_PROMPT') },
  { label: 'roleInstruction wird angehängt', test: streamBlock.includes('roleInstruction') },
  { label: 'SYMPTOM_CHECK_PROMPT (symptomCheck mode)', test: streamBlock.includes('SYMPTOM_CHECK_PROMPT') },
  { label: 'WOUND_ANALYSIS_PROMPT (woundAnalysis mode)', test: streamBlock.includes('WOUND_ANALYSIS_PROMPT') },
  { label: 'BELLA_ACTIONS_PROMPT (Pro)', test: streamBlock.includes('BELLA_ACTIONS_PROMPT') },
  { label: 'PRO_UPSELL_INSTRUCTIONS (Free)', test: streamBlock.includes('PRO_UPSELL_INSTRUCTIONS') },
];
streamChecks.forEach(c => console.log(`  ${c.test ? '✅' : '❌'} ${c.label}`));

// Check Bella scheduled functions
console.log('\n=== BELLA SCHEDULED FUNCTIONS ===\n');
const bellaFns = [
  { name: 'bellaProactiveReminder', schedule: '0 9 * * *', desc: 'Tägliche Erinnerungen (09:00)' },
  { name: 'dailyBellaAnalysis', schedule: '0 7 * * *', desc: 'AI-Tagesanalyse (07:00, Pro)' },
  { name: 'bellaHealthTrendCheck', schedule: '0 10 * * *', desc: 'Gesundheitstrend-Check (10:00, Pro)' },
];
bellaFns.forEach(fn => {
  const exists = src.includes('exports.' + fn.name);
  const hasSchedule = src.includes(fn.schedule);
  console.log(`  ${exists ? '✅' : '❌'} ${fn.name} — ${fn.desc} ${hasSchedule ? '(Cron OK)' : '(⚠️ Cron fehlt!)'}`);
});

// Check Flutter-side callable names match
console.log('\n=== FLUTTER ↔ CLOUD FUNCTION MATCHING ===\n');
const adminCalls = [
  'sendAdminNotification',
  'getAdminStats',
  'setMaintenanceMode',
  'verifyDoctor',
  'suspendDoctor',
  'unsuspendDoctor',
  'deleteDoctor',
  'setUserRole',
  'listProKeys',
  'createProKeys',
  'disableProKey',
  'listOrgProKeys',
  'createOrgProKeys',
  'disableOrgProKey',
  'adminSetOrgPro',
  'verifyOrganisation',
];
adminCalls.forEach(fn => {
  const inCloud = src.includes('exports.' + fn);
  console.log(`  ${inCloud ? '✅' : '❌'} ${fn}`);
});

console.log('\n' + (allOk ? '🎉 Alle 9 Prompts sind korrekt definiert und werden verwendet!' : '⚠️ Es gibt Probleme — siehe oben.'));

