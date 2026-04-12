import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../notifications/local_notifications.dart';
import '../../../ui/ui.dart';
import '../../health_sync/health_sync_service.dart';
import '../../pro/domain/trigger_context.dart';
import '../../pro/presentation/smart_paywall.dart';
import '../data/vital_reminder_storage.dart';
import '../data/vital_repository_sync.dart';
import '../../onboarding_tutorial/data/feature_discovery_service.dart';
import '../domain/vital_entry.dart';
import '../../../ui/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

// ── Colors ───────────────────────────────────────────────────────────────────
const _kSysColor = Color(0xFFFF3B30);
const _kDiaColor = Color(0xFFFF9500);
const _kPulseColor = Color(0xFF34C759);
const _kTempColor = Color(0xFFAF52DE);
const _kSpO2Color = Color(0xFF30B0C7);
const _kWeightColor = Color(0xFFFF9F0A);
const _kBlue = Color(0xFF0A74FF);
const _kGray = Color(0xFF8E8E93);
const _kCardBg = Colors.white;

/// Card-layout vitals screen with sliders, interactive chart & reminder.
class VitalsScreen extends StatefulWidget {
  const VitalsScreen({super.key});

  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  static final VitalRepositorySync _repository = VitalRepositorySync.instance;
  static final VitalReminderStorage _reminderStorage =
      VitalReminderStorage.instance;

  // ── Input state ──
  double _systolic = 120;
  double _diastolic = 80;
  double _pulse = 70;
  double _temperature = 36.5;
  double _oxygenSaturation = 98;
  double _weight = 70;
  bool _extraExpanded = false;
  bool _temperatureActive = false;
  bool _oxygenActive = false;
  bool _weightActive = false;
  final TextEditingController _noteCtrl = TextEditingController();
  bool _saving = false;

  // ── Chart state ──
  _ChartRange _chartRange = _ChartRange.last5;

  // ── Reminder state ──
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _repository.loadFromDisk();
    try {
      await _repository.pullLatest();
    } catch (e) {
      debugPrint('[VitalsScreen] pullLatest failed (offline?): $e');
    }
    await _reminderStorage.init();
    // Trigger health sync if enabled – pulls new data from Apple Health / Health Connect.
    _syncHealthData();
    if (!mounted) return;
    setState(() {
      _reminderEnabled = _reminderStorage.isEnabled;
      _reminderTime = TimeOfDay(
        hour: _reminderStorage.hour,
        minute: _reminderStorage.minute,
      );
    });
    await _showDiscoveryTip();
  }

  Future<void> _showDiscoveryTip() async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final seen = await FeatureDiscoveryService.instance
        .hasSeenFeature('vitals');
    if (!seen && mounted) {
      await FeatureDiscoveryService.instance.markSeen('vitals');
      messenger.showSnackBar(
        SnackBar(
          content: Text(l.vitalsTipp),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _syncHealthData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final count = await HealthSyncService.instance.sync(ownerId: uid);
      if (count > 0 && mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l.neueMessungenSync(count)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('VitalsScreen: health sync error: $e');
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final l = AppLocalizations.of(context)!;
      final now = DateTime.now();
      final id = 'vital_${now.millisecondsSinceEpoch}';
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final note = _noteCtrl.text.trim();
      final entry = VitalEntry(
        id: id,
        ownerId: uid,
        systolic: _systolic.round(),
        diastolic: _diastolic.round(),
        pulse: _pulse.round(),
        temperature: _temperatureActive ? _temperature : null,
        oxygenSaturation: _oxygenActive ? _oxygenSaturation.round() : null,
        weight: _weightActive ? _weight : null,
        note: note.isNotEmpty ? note : null,
        createdAt: now,
        updatedAt: now,
        metadata: const <String, dynamic>{'source': 'vitals_screen'},
      );
      await _repository.upsert(entry);
      // Write manual entry back to Apple Health / Health Connect.
      unawaited(
        HealthSyncService.instance.writeVitalEntry(entry).then<void>((_) {}).catchError((Object e) {
          debugPrint('[Vitals] writeVitalEntry failed: $e');
        }),
      );
      if (!mounted) return;
      _noteCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.vitalsMeasurementSaved),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(userFacingError(e))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}, $hh:$min';
  }

  String _shortDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm';
  }

  bool get _isPro =>
      ProServices.maybeOf(context)?.entitlementService.isPro ?? false;

  // ── Chart range filter ────────────────────────────────────────────────────
  List<VitalEntry> _filterForRange(List<VitalEntry> all) {
    // Items come in newest-first order; reverse for chart (oldest→newest).
    final sorted = List<VitalEntry>.of(all)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    switch (_chartRange) {
      case _ChartRange.last5:
        if (sorted.length <= 5) return sorted;
        return sorted.sublist(sorted.length - 5);
      case _ChartRange.days7:
        final cutoff = DateTime.now().subtract(const Duration(days: 7));
        return sorted.where((e) => e.createdAt.isAfter(cutoff)).toList();
      case _ChartRange.days30:
        final cutoff = DateTime.now().subtract(const Duration(days: 30));
        return sorted.where((e) => e.createdAt.isAfter(cutoff)).toList();
    }
  }

  // ── Reminder toggle ───────────────────────────────────────────────────────
  Future<void> _toggleReminder(bool value) async {
    setState(() => _reminderEnabled = value);
    try {
      await _reminderStorage.setEnabled(value);
      if (value) {
        await LocalNotifications.scheduleVitalReminder(_reminderTime);
      } else {
        await LocalNotifications.cancelVitalReminder();
      }
    } catch (e) {
      debugPrint('[VitalsScreen] toggleReminder failed: $e');
    }
  }

  Future<void> _pickReminderTime() async {
    final l = AppLocalizations.of(context)!;
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      helpText: l.erinnerungszeitWaehlen,
    );
    if (picked == null || !mounted) return;
    setState(() => _reminderTime = picked);
    try {
      await _reminderStorage.setTime(picked.hour, picked.minute);
      if (_reminderEnabled) {
        await LocalNotifications.scheduleVitalReminder(picked);
      }
    } catch (e) {
      debugPrint('[VitalsScreen] pickReminderTime failed: $e');
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final sys = _systolic.round();
    final dia = _diastolic.round();
    final pul = _pulse.round();

    return GlassPage(
      title: l.vitalwerte,
      titleIcon: AppIcons.vitals,
      titleColor: const Color(0xFFFF6B6B),
      horizontalPadding: AppSpacing.lg,
      children: [
        const SizedBox(height: AppSpacing.xl),

        // ── Card 1: Neue Messung ─────────────────────────────
        _IosCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.neueMessung,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 20),

              _VitalSliderRow(
                label: l.systolisch,
                value: sys,
                unit: 'mmHg',
                valueColor: _kSysColor,
                min: 70,
                max: 220,
                sliderValue: _systolic,
                hint: l.normalSystolisch,
                onChanged: (v) => setState(() => _systolic = v),
              ),
              const SizedBox(height: 18),

              _VitalSliderRow(
                label: l.diastolisch,
                value: dia,
                unit: 'mmHg',
                valueColor: _kDiaColor,
                min: 40,
                max: 130,
                sliderValue: _diastolic,
                hint: l.normalDiastolisch,
                onChanged: (v) => setState(() => _diastolic = v),
              ),
              const SizedBox(height: 18),

              _VitalSliderRow(
                label: l.puls,
                value: pul,
                unit: 'bpm',
                valueColor: _kPulseColor,
                min: 40,
                max: 180,
                sliderValue: _pulse,
                hint: l.normalPuls,
                onChanged: (v) => setState(() => _pulse = v),
              ),

              const SizedBox(height: 20),

              // ── Expandable extra measurements ──
              GestureDetector(
                onTap: () =>
                    setState(() => _extraExpanded = !_extraExpanded),
                child: Row(
                  children: [
                    Icon(
                      _extraExpanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: _kBlue,
                      size: 22,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l.weitereWerteOptional,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _kBlue,
                      ),
                    ),
                  ],
                ),
              ),

              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _buildExtraFields(),
                crossFadeState: _extraExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),

              const SizedBox(height: 20),

              // ── Summary pill ─────────────────────────────
              _buildSummaryPill(sys, dia, pul),

              const SizedBox(height: 20),

              // ── Save button ──────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(l.save),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Card 2: Verlauf (Chart) ──────────────────────────
        StreamBuilder<List<VitalEntry>>(
          stream: _repository.watchAll(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <VitalEntry>[];
            return _IosCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.history,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRangeChips(),
                  const SizedBox(height: 16),
                  if (items.length < 2)
                    _buildEmptyState()
                  else
                    _buildChart(_filterForRange(items)),
                  const SizedBox(height: 16),
                  if (items.isNotEmpty) _buildHistoryList(items),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Card 3: Erinnerung ───────────────────────────────
        _IosCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.vitalsErinnerung,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.notifications_active_rounded,
                      color: _kBlue, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.taeglicheMesserinnerung,
                      style: TextStyle(fontSize: 16, color: Color(0xFF1C1C1E)),
                    ),
                  ),
                  Switch.adaptive(
                    value: _reminderEnabled,
                    activeTrackColor: _kBlue,
                    onChanged: _toggleReminder,
                  ),
                ],
              ),
              if (_reminderEnabled) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickReminderTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 20, color: _kGray),
                        const SizedBox(width: 10),
                        Text(
                          _reminderTime.format(context),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          l.aendern,
                          style: TextStyle(
                            fontSize: 15,
                            color: _kBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  // ── Extra fields (temperature, O₂, weight, note) ─────────────────────────
  Widget _buildExtraFields() {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          // Temperature
          _OptionalSliderRow(
            label: l.temperatur,
            icon: AppIcons.temperature,
                    iconColor: AppIcons.temperatureColor,
            active: _temperatureActive,
            onToggle: (v) => setState(() => _temperatureActive = v),
            valueText:
                '${_temperature.toStringAsFixed(1)} °C',
            valueColor: _kTempColor,
            min: 35.0,
            max: 42.0,
            divisions: 70,
            sliderValue: _temperature,
            hint: l.normalTemperatur,
            onChanged: (v) => setState(() => _temperature = v),
          ),
          const SizedBox(height: 14),

          // O₂ saturation
          _OptionalSliderRow(
            label: l.oSaettigung,
            icon: AppIcons.bloating,
                    iconColor: AppIcons.bloatingColor,
            active: _oxygenActive,
            onToggle: (v) => setState(() => _oxygenActive = v),
            valueText: '${_oxygenSaturation.round()} %',
            valueColor: _kSpO2Color,
            min: 80,
            max: 100,
            divisions: 20,
            sliderValue: _oxygenSaturation,
            hint: l.normalO2Saettigung,
            onChanged: (v) => setState(() => _oxygenSaturation = v),
          ),
          const SizedBox(height: 14),

          // Weight
          _OptionalSliderRow(
            label: l.fieldWeight,
            icon: AppIcons.weight,
                    iconColor: AppIcons.weightColor,
            active: _weightActive,
            onToggle: (v) => setState(() => _weightActive = v),
            valueText: '${_weight.toStringAsFixed(1)} kg',
            valueColor: _kWeightColor,
            min: 30,
            max: 200,
            divisions: 340,
            sliderValue: _weight,
            hint: '',
            onChanged: (v) => setState(() => _weight = v),
          ),
          const SizedBox(height: 14),

          // Note
          TextField(
            controller: _noteCtrl,
            maxLength: 300,
            maxLines: 2,
            minLines: 1,
            decoration: InputDecoration(
              hintText: l.notizOptional,
              hintStyle: const TextStyle(color: _kGray),
              filled: true,
              fillColor: const Color(0xFFF2F2F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              counterStyle: const TextStyle(fontSize: 11, color: _kGray),
            ),
            style: const TextStyle(fontSize: 15, color: Color(0xFF1C1C1E)),
          ),
        ],
      ),
    );
  }

  // ── Summary pill ──────────────────────────────────────────────────────────
  Widget _buildSummaryPill(int sys, int dia, int pul) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 14,
        runSpacing: 6,
        children: [
          Text(
            '$sys/$dia',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _kSysColor,
            ),
          ),
          GlassIcon(icon: AppIcons.vitals, color: AppIcons.vitalsColor, size: 14),
          Text(
            '$pul',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _kPulseColor,
            ),
          ),
          if (_temperatureActive)
            Text(
              '${_temperature.toStringAsFixed(1)}°',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _kTempColor,
              ),
            ),
          if (_oxygenActive)
            Text(
              '${_oxygenSaturation.round()}%',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _kSpO2Color,
              ),
            ),
        ],
      ),
    );
  }

  // ── Range chips ───────────────────────────────────────────────────────────
  Widget _buildRangeChips() {
    final l = AppLocalizations.of(context)!;
    return Row(
      children: _ChartRange.values.map((range) {
        final selected = _chartRange == range;
        final locked = range != _ChartRange.last5 && !_isPro;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              if (locked) {
                SmartPaywall.trigger(
                  context: context,
                  triggerContext: TriggerContext.vitalsChartsFeature,
                );
                return;
              }
              setState(() {
                _chartRange = range;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? _kBlue : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (locked) ...[
                    const Icon(Icons.lock_rounded,
                        size: 13, color: _kGray),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    range.label(l),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : _kGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    final l = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 12),
          const GlassIcon(icon: AppIcons.analytics, color: AppIcons.analyticsColor, size: 28),
          const SizedBox(height: 8),
          Text(
            l.mindZweiEintraege,
            style: const TextStyle(fontSize: 15, color: _kGray),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── Interactive line chart ────────────────────────────────────────────────
  Widget _buildChart(List<VitalEntry> entries) {
    // Filter out health-synced entries that have no BP/pulse data (all zeros).
    final charted = entries
        .where((e) => e.systolic > 0 || e.diastolic > 0 || e.pulse > 0)
        .toList();
    if (charted.length < 2) return _buildEmptyState();

    final spots = <String, List<FlSpot>>{
      'sys': [],
      'dia': [],
      'pulse': [],
    };

    for (var i = 0; i < charted.length; i++) {
      final e = charted[i];
      spots['sys']!.add(FlSpot(i.toDouble(), e.systolic.toDouble()));
      spots['dia']!.add(FlSpot(i.toDouble(), e.diastolic.toDouble()));
      spots['pulse']!.add(FlSpot(i.toDouble(), e.pulse.toDouble()));
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 30,
          maxY: 230,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 40,
            getDrawingHorizontalLine: (value) => FlLine(
              color: const Color(0xFFE5E5EA),
              strokeWidth: 0.8,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: 40,
                getTitlesWidget: (value, _) => Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontSize: 11, color: _kGray),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: charted.length > 6 ? 2 : 1,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= charted.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _shortDate(charted[i].createdAt),
                      style: const TextStyle(fontSize: 10, color: _kGray),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 140,
                color: _kSysColor.withValues(alpha: 0.3),
                strokeWidth: 1,
                dashArray: [6, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  style: TextStyle(
                    fontSize: 10,
                    color: _kSysColor.withValues(alpha: 0.6),
                  ),
                  labelResolver: (_) => 'SYS 140',
                ),
              ),
            ],
          ),
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF1C1C1E),
              tooltipRoundedRadius: 10,
              tooltipPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              getTooltipItems: (spots) {
                if (spots.isEmpty) return [];
                final i = spots.first.spotIndex;
                final e = i < charted.length ? charted[i] : null;
                if (e == null) return [null, null, null];
                return [
                  LineTooltipItem(
                    '${_shortDate(e.createdAt)}\n'
                    'SYS ${e.systolic}  DIA ${e.diastolic}\n'
                    '${e.pulse} bpm'
                    '${e.temperature != null ? '\n${e.temperature!.toStringAsFixed(1)}°C' : ''}'
                    '${e.oxygenSaturation != null ? '\n${e.oxygenSaturation}%' : ''}',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  null,
                  null,
                ];
              },
            ),
          ),
          lineBarsData: [
            _lineData(spots['sys']!, _kSysColor),
            _lineData(spots['dia']!, _kDiaColor),
            _lineData(spots['pulse']!, _kPulseColor),
          ],
        ),
      ),
    );
  }

  LineChartBarData _lineData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      preventCurveOverShooting: true,
      color: color,
      barWidth: 2.5,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, xPercentage, bar, index) => FlDotCirclePainter(
          radius: 3.5,
          color: color,
          strokeWidth: 1.5,
          strokeColor: Colors.white,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.08),
      ),
    );
  }

  // ── Legend ────────────────────────────────────────────────────────────────
  Widget _buildLegend() {
    final l = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendDot(color: _kSysColor, label: 'SYS'),
        const SizedBox(width: 16),
        _LegendDot(color: _kDiaColor, label: 'DIA'),
        const SizedBox(width: 16),
        _LegendDot(color: _kPulseColor, label: l.puls),
      ],
    );
  }

  // ── History list ──────────────────────────────────────────────────────────
  Widget _buildHistoryList(List<VitalEntry> items) {
    final recent = items.take(10).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegend(),
        const SizedBox(height: 12),
        ...recent.map(
          (e) => _HistoryRow(
            entry: e,
            formatDate: _formatDate,
            onTap: () => _showEntryDetail(e),
          ),
        ),
      ],
    );
  }

  // ── Detail bottom sheet ───────────────────────────────────────────────────
  void _showEntryDetail(VitalEntry e) {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D1D6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _formatDate(e.createdAt),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 16),
              _DetailRow(
                  label: l.systolisch,
                  value: '${e.systolic} mmHg',
                  color: _kSysColor),
              _DetailRow(
                  label: l.diastolisch,
                  value: '${e.diastolic} mmHg',
                  color: _kDiaColor),
              _DetailRow(
                  label: l.puls,
                  value: '${e.pulse} bpm',
                  color: _kPulseColor),
              if (e.temperature != null)
                _DetailRow(
                    label: l.temperatur,
                    value: '${e.temperature!.toStringAsFixed(1)} °C',
                    color: _kTempColor),
              if (e.oxygenSaturation != null)
                _DetailRow(
                    label: l.oSaettigung,
                    value: '${e.oxygenSaturation} %',
                    color: _kSpO2Color),
              if (e.weight != null)
                _DetailRow(
                    label: l.fieldWeight,
                    value: '${e.weight!.toStringAsFixed(1)} kg',
                    color: _kWeightColor),
              if (e.note != null && e.note!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    e.note!,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1C1C1E),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Chart range enum ─────────────────────────────────────────────────────────

enum _ChartRange {
  last5,
  days7,
  days30;

  String label(AppLocalizations l) => switch (this) {
        _ChartRange.last5 => l.chartLast5,
        _ChartRange.days7 => l.chartDays7,
        _ChartRange.days30 => l.chartDays30,
      };
}

// ── iOS card container ───────────────────────────────────────────────────────

class _IosCard extends StatelessWidget {
  const _IosCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Vital slider row ─────────────────────────────────────────────────────────

class _VitalSliderRow extends StatelessWidget {
  const _VitalSliderRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.valueColor,
    required this.min,
    required this.max,
    required this.sliderValue,
    required this.hint,
    required this.onChanged,
  });

  final String label;
  final int value;
  final String unit;
  final Color valueColor;
  final double min;
  final double max;
  final double sliderValue;
  final String hint;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$label ',
              style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1E)),
            ),
            Text(
              '$value $unit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: valueColor,
            inactiveTrackColor: const Color(0xFFE5E5EA),
            thumbColor: valueColor,
            overlayColor: valueColor.withValues(alpha: 0.12),
            trackHeight: 5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: sliderValue,
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
          ),
        ),
        if (hint.isNotEmpty)
          Center(
            child: Text(
              hint,
              style: const TextStyle(fontSize: 13, color: _kGray),
            ),
          ),
      ],
    );
  }
}

// ── Optional slider row (with toggle) ────────────────────────────────────────

class _OptionalSliderRow extends StatelessWidget {
  const _OptionalSliderRow({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.active,
    required this.onToggle,
    required this.valueText,
    required this.valueColor,
    required this.min,
    required this.max,
    required this.divisions,
    required this.sliderValue,
    required this.hint,
    required this.onChanged,
  });

  final String label;
  final IconData icon;

  final Color iconColor;
  final bool active;
  final ValueChanged<bool> onToggle;
  final String valueText;
  final Color valueColor;
  final double min;
  final double max;
  final int divisions;
  final double sliderValue;
  final String hint;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => onToggle(!active),
          child: Row(
            children: [
              GlassIcon(icon: icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 15, color: Color(0xFF1C1C1E)),
                ),
              ),
              if (active)
                Text(
                  valueText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                height: 28,
                child: Switch.adaptive(
                  value: active,
                  activeTrackColor: valueColor,
                  onChanged: onToggle,
                ),
              ),
            ],
          ),
        ),
        if (active) ...[
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: valueColor,
              inactiveTrackColor: const Color(0xFFE5E5EA),
              thumbColor: valueColor,
              overlayColor: valueColor.withValues(alpha: 0.12),
              trackHeight: 4,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: sliderValue,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          if (hint.isNotEmpty)
            Center(
              child: Text(
                hint,
                style: const TextStyle(fontSize: 12, color: _kGray),
              ),
            ),
        ],
      ],
    );
  }
}

// ── Legend dot ────────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: _kGray),
        ),
      ],
    );
  }
}

// ── History row ──────────────────────────────────────────────────────────────

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.entry,
    required this.formatDate,
    required this.onTap,
  });

  final VitalEntry entry;
  final String Function(DateTime) formatDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            // BP badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _kSysColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${entry.systolic}/${entry.diastolic}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: _kSysColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Pulse badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: _kPulseColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${entry.pulse} bpm',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: _kPulseColor,
                ),
              ),
            ),
            if (entry.note != null && entry.note!.isNotEmpty) ...[
              const SizedBox(width: 6),
              const Icon(Icons.note_rounded, size: 16, color: _kGray),
            ],
            const Spacer(),
            Text(
              formatDate(entry.createdAt),
              style: const TextStyle(fontSize: 13, color: _kGray),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: _kGray),
          ],
        ),
      ),
    );
  }
}

// ── Detail row (for bottom sheet) ────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF8E8E93),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
