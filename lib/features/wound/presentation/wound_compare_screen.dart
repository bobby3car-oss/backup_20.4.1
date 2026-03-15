import 'dart:io';

import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../domain/wound_entry.dart';
import '../../../ui/theme/app_icons.dart';

class WoundCompareScreen extends StatefulWidget {
  const WoundCompareScreen({
    super.key,
    required this.entryA,
    required this.entryB,
  });

  final WoundEntry entryA;
  final WoundEntry entryB;

  @override
  State<WoundCompareScreen> createState() => _WoundCompareScreenState();
}

class _WoundCompareScreenState extends State<WoundCompareScreen> {
  bool _overlayMode = false;
  double _overlayValue = 0.5;

  @override
  Widget build(BuildContext context) {
    final scoreDiff = widget.entryB.pain - widget.entryA.pain;
    final scoreLabel = scoreDiff == 0
        ? 'Unveraendert'
        : scoreDiff > 0
        ? '+$scoreDiff'
        : '$scoreDiff';

    return GlassPage(
      title: 'Wundvergleich',
      titleIcon: AppIcons.search,
      titleColor: AppColors.accent,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Overlay-Modus'),
                subtitle: const Text('A/B mit Slider mischen'),
                value: _overlayMode,
                onChanged: (value) {
                  setState(() => _overlayMode = value);
                },
              ),
              const SizedBox(height: 8),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _overlayMode
                      ? _OverlayCompareView(
                          entryA: widget.entryA,
                          entryB: widget.entryB,
                          value: _overlayValue,
                        )
                      : Row(
                          children: [
                            Expanded(child: _PhotoView(entry: widget.entryA)),
                            const SizedBox(width: 8),
                            Expanded(child: _PhotoView(entry: widget.entryB)),
                          ],
                        ),
                ),
              ),
              if (_overlayMode) ...[
                const SizedBox(height: 10),
                Slider(
                  value: _overlayValue,
                  onChanged: (value) => setState(() => _overlayValue = value),
                ),
                Row(
                  children: [const Text('A'), const Spacer(), const Text('B')],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _MetaCard(
                      title: 'Links (A)',
                      date: _formatDateTime(widget.entryA.createdAt),
                      score: widget.entryA.pain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetaCard(
                      title: 'Rechts (B)',
                      date: _formatDateTime(widget.entryB.createdAt),
                      score: widget.entryB.pain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 1,
                child: ListTile(
                  title: const Text('Schmerzscore Vergleich'),
                  subtitle: Text(
                    'A: ${widget.entryA.pain}/10   |   B: ${widget.entryB.pain}/10',
                  ),
                  trailing: Text(
                    scoreLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverlayCompareView extends StatelessWidget {
  const _OverlayCompareView({
    required this.entryA,
    required this.entryB,
    required this.value,
  });

  final WoundEntry entryA;
  final WoundEntry entryB;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _PhotoView(entry: entryA),
        Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: _PhotoView(entry: entryB),
        ),
      ],
    );
  }
}

class _PhotoView extends StatelessWidget {
  const _PhotoView({required this.entry});

  final WoundEntry entry;

  @override
  Widget build(BuildContext context) {
    final path = entry.photoPath;
    final hasPath = path != null && path.trim().isNotEmpty;
    final file = hasPath ? File(path.trim()) : null;

    if (file == null) return _placeholder();

    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snap) {
        if (snap.data == true) {
          return Image.file(file, fit: BoxFit.cover);
        }
        return _placeholder();
      },
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 40,
        color: Colors.grey.shade600,
      ),
    );
  }
}

class _MetaCard extends StatelessWidget {
  const _MetaCard({
    required this.title,
    required this.date,
    required this.score,
  });

  final String title;
  final String date;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(date),
            const SizedBox(height: 4),
            Text('Schmerz: $score/10'),
          ],
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime value) {
  final dd = value.day.toString().padLeft(2, '0');
  final mm = value.month.toString().padLeft(2, '0');
  final yyyy = value.year.toString().padLeft(4, '0');
  final hh = value.hour.toString().padLeft(2, '0');
  final min = value.minute.toString().padLeft(2, '0');
  return '$dd.$mm.$yyyy, $hh:$min';
}
