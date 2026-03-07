import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../ui/ui.dart';
import '../../data/ad_config.dart';
import '../../data/ad_service.dart';
import '../../data/partner_ad.dart';
import '../ad_banner_widget.dart';

class AdsAdminTab extends StatefulWidget {
  const AdsAdminTab({super.key});

  @override
  State<AdsAdminTab> createState() => _AdsAdminTabState();
}

class _AdsAdminTabState extends State<AdsAdminTab> {
  AdService get _adService => AdServiceScope.of(context);

  bool _saving = false;

  // Local state that mirrors Firestore config.
  bool _adsEnabled = false;
  bool _googleAdsEnabled = false;
  bool _partnerAdsEnabled = false;
  int _adFrequency = 5;
  bool _dirty = false;

  StreamSubscription<List<PartnerAd>>? _adsSub;
  List<PartnerAd> _allAds = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_adsSub == null) {
      _syncFromConfig(_adService.config.value);
      _adService.config.addListener(_onConfigChanged);
      _adsSub = _adService.allPartnerAdsStream().listen((ads) {
        if (mounted) setState(() => _allAds = ads);
      });
    }
  }

  void _onConfigChanged() {
    if (!_dirty) _syncFromConfig(_adService.config.value);
  }

  void _syncFromConfig(AdConfig c) {
    setState(() {
      _adsEnabled = c.adsEnabled;
      _googleAdsEnabled = c.googleAdsEnabled;
      _partnerAdsEnabled = c.partnerAdsEnabled;
      _adFrequency = c.adFrequency;
    });
  }

  @override
  void dispose() {
    _adService.config.removeListener(_onConfigChanged);
    _adsSub?.cancel();
    super.dispose();
  }

  Future<void> _saveConfig() async {
    setState(() => _saving = true);
    try {
      await _adService.updateConfig(AdConfig(
        adsEnabled: _adsEnabled,
        googleAdsEnabled: _googleAdsEnabled,
        partnerAdsEnabled: _partnerAdsEnabled,
        adFrequency: _adFrequency,
      ));
      _dirty = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Einstellungen gespeichert.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addPartnerAd() async {
    final result = await showDialog<_PartnerAdFormResult>(
      context: context,
      builder: (_) => _AddPartnerAdDialog(adService: _adService),
    );
    if (result == null) return;

    try {
      String imageUrl = '';
      if (result.imageBytes != null) {
        // Upload image first, then create the ad with the URL.
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
        imageUrl =
            await _adService.uploadAdImage(tempId, result.imageBytes!);
      }
      await _adService.createPartnerAd(
        title: result.title,
        imageUrl: imageUrl,
        linkUrl: result.linkUrl,
        displayOrder: _allAds.length,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Erstellen: $e')),
        );
      }
    }
  }

  Future<void> _deleteAd(PartnerAd ad) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Anzeige löschen?'),
        content: Text('„${ad.title}" wird unwiderruflich gelöscht.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Löschen',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _adService.deletePartnerAd(ad.id);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Werbung')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPartnerAd,
        icon: const Icon(Icons.add),
        label: const Text('Partner-Anzeige'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // ── Global settings ──────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    child: Text('Globale Einstellungen',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  SwitchListTile(
                    title: const Text('Werbung aktiviert'),
                    subtitle: const Text(
                        'Globaler Schalter für alle Werbeformate'),
                    value: _adsEnabled,
                    onChanged: (v) =>
                        setState(() { _adsEnabled = v; _dirty = true; }),
                  ),
                  SwitchListTile(
                    title: const Text('Google Ads'),
                    subtitle:
                        const Text('AdMob Banner-Werbung anzeigen'),
                    value: _googleAdsEnabled,
                    onChanged: _adsEnabled
                        ? (v) => setState(
                            () { _googleAdsEnabled = v; _dirty = true; })
                        : null,
                  ),
                  SwitchListTile(
                    title: const Text('Partner-Anzeigen'),
                    subtitle: const Text(
                        'Eigene Bild-Anzeigen mit Link anzeigen'),
                    value: _partnerAdsEnabled,
                    onChanged: _adsEnabled
                        ? (v) => setState(
                            () { _partnerAdsEnabled = v; _dirty = true; })
                        : null,
                  ),
                  ListTile(
                    title: const Text('Häufigkeit'),
                    subtitle: Text(
                        'Alle $_adFrequency Listeneinträge eine Anzeige'),
                    trailing: SizedBox(
                      width: 180,
                      child: Slider(
                        min: 2,
                        max: 15,
                        divisions: 13,
                        value: _adFrequency.toDouble(),
                        label: '$_adFrequency',
                        onChanged: _adsEnabled
                            ? (v) => setState(() {
                                  _adFrequency = v.round();
                                  _dirty = true;
                                })
                            : null,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    child: FilledButton.icon(
                      onPressed: _dirty && !_saving ? _saveConfig : null,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.save),
                      label: const Text('Speichern'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Partner ads list ─────────────────────────────────────
          Text('Partner-Anzeigen (${_allAds.length})',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),

          if (_allAds.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Center(
                  child: Text(
                    'Noch keine Partner-Anzeigen vorhanden.',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ),
              ),
            )
          else
            ...List.generate(_allAds.length, (i) {
              final ad = _allAds[i];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  leading: ad.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            ad.imageUrl,
                            width: 56,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                                Icons.broken_image, size: 40),
                          ),
                        )
                      : const Icon(Icons.image, size: 40),
                  title: Text(ad.title.isNotEmpty ? ad.title : '(kein Titel)'),
                  subtitle: Text(
                    ad.linkUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: ad.isActive,
                        onChanged: (v) =>
                            _adService.togglePartnerAd(ad.id, isActive: v),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: cs.error,
                        onPressed: () => _deleteAd(ad),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog: Create partner ad
// ─────────────────────────────────────────────────────────────────────────────

class _PartnerAdFormResult {
  _PartnerAdFormResult({
    required this.title,
    required this.linkUrl,
    this.imageBytes,
  });
  final String title;
  final String linkUrl;
  final Uint8List? imageBytes;
}

class _AddPartnerAdDialog extends StatefulWidget {
  const _AddPartnerAdDialog({required this.adService});
  final AdService adService;

  @override
  State<_AddPartnerAdDialog> createState() => _AddPartnerAdDialogState();
}

class _AddPartnerAdDialogState extends State<_AddPartnerAdDialog> {
  final _titleCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  Uint8List? _imageBytes;
  String? _imageName;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 80,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _imageBytes = bytes;
      _imageName = file.name;
    });
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final url = _urlCtrl.text.trim();
    if (title.isEmpty || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Titel und URL sind erforderlich.')),
      );
      return;
    }
    Navigator.pop(
      context,
      _PartnerAdFormResult(
        title: title,
        linkUrl: url,
        imageBytes: _imageBytes,
      ),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Partner-Anzeige erstellen'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Titel / Beschreibung',
                hintText: 'z. B. Reha-Klinik Mustermann',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlCtrl,
              decoration: const InputDecoration(
                labelText: 'Link-URL',
                hintText: 'https://example.com',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text(_imageName ?? 'Bild auswählen'),
            ),
            if (_imageBytes != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(_imageBytes!,
                    height: 80, fit: BoxFit.cover),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Erstellen'),
        ),
      ],
    );
  }
}
