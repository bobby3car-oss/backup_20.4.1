import 'package:flutter/material.dart';

import '../../../ui/ui.dart';

// ---------------------------------------------------------------------------
// Tab data model (purely local)
// ---------------------------------------------------------------------------

class _TabData {
  const _TabData({
    required this.label,
    required this.icon,
    required this.title,
    required this.items,
  });

  final String label;
  final String icon;
  final String title;
  final List<String> items;
}

const _tabs = <_TabData>[
  _TabData(
    label: 'Ablauf',
    icon: '🔁',
    title: '🔁 Ablauf',
    items: [
      'Aufnahme & Anmeldung in der Klinik',
      'Identitätsprüfung & Armbandanlegen',
      'Gespräch mit Anästhesie & Chirurgie',
      'OP-Vorbereitung im Vorbereitungsraum',
      'Eingriff im OP-Saal',
      'Aufwachraum & erste Überwachung',
      'Verlegung auf Station / Zimmer',
    ],
  ),
  _TabData(
    label: 'Vorbereitung',
    icon: '📝',
    title: '📝 Vorbereitung',
    items: [
      'Nüchternheitsregel beachten (mind. 6 h vorher)',
      'Rasur / Reinigung des OP-Gebiets nach Anweisung',
      'Medikamenten-Anpassung mit Arzt besprechen',
      'Kompressionsstrümpfe ggf. mitbringen',
      'Krankenhaus-Tasche vorbereiten (Packliste nutzen)',
      'Begleitperson & Transport organisieren',
      'Einwilligungsbogen unterschrieben mitbringen',
    ],
  ),
  _TabData(
    label: 'Nach OP',
    icon: '🩹',
    title: '🩹 Nach der OP',
    items: [
      'Schmerzmittel nach Plan einnehmen',
      'Wunde beobachten (Rötung, Schwellung, Fieber)',
      'Frühe Mobilisation nach ärztlicher Freigabe',
      'Ausreichend Flüssigkeit zu sich nehmen',
      'Nachsorgetermine wahrnehmen',
      'Belastung nur im empfohlenen Rahmen steigern',
      'Bei Warnzeichen sofort Arzt kontaktieren',
    ],
  ),
  _TabData(
    label: 'Fragen',
    icon: '❓',
    title: '❓ Häufige Fragen',
    items: [
      'Wie lange dauert der Eingriff?',
      'Wann darf ich wieder essen und trinken?',
      'Welche Schmerzmittel bekomme ich?',
      'Wann darf ich wieder duschen?',
      'Wie lange bin ich krankgeschrieben?',
      'Wann findet die nächste Kontrolle statt?',
      'Wer ist mein Ansprechpartner bei Problemen?',
    ],
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class OpInfoScreen extends StatefulWidget {
  const OpInfoScreen({super.key});

  @override
  State<OpInfoScreen> createState() => _OpInfoScreenState();
}

class _OpInfoScreenState extends State<OpInfoScreen> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final tab = _tabs[_selected];

    return GlassPage(
      title: 'OP-Infos',
      titleEmoji: '🏥',
      titleColor: AppColors.primary,
      scrollableBody: (headerHeight) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: headerHeight),
          // ---- Chip row ---------------------------------------------------
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final isActive = i == _selected;
                return Padding(
                  padding: EdgeInsets.only(
                    right: i < _tabs.length - 1 ? 10 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => setState(() => _selected = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : const Color(0xFFD1D1D6),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _tabs[i].label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),

          // ---- Content card -----------------------------------------------
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              physics: adaptiveScrollPhysics,
              children: [
                // White card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 24,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tab.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      for (int i = 0; i < tab.items.length; i++) ...[
                        if (i > 0)
                          const Divider(height: 1, color: Color(0xFFE5E5EA)),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '•  ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  tab.items[i],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.4,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Hint box
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ℹ️ ', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Wichtig: Folgen Sie den Anweisungen Ihres Behandlungsteams.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
