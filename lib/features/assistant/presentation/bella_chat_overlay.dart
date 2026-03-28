import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../auth/user_profile_service.dart';
import '../../../main.dart';
import '../../../sync/connectivity_service.dart';
import '../../../ui/ui.dart';
import '../domain/bella_chat_exporter.dart';
import '../domain/chat_message.dart';
import 'bella_overlay_controller.dart';
import 'package:image_picker/image_picker.dart';

import '../../../features/pro/domain/trigger_context.dart';
import '../../../features/pro/presentation/smart_paywall.dart';
import 'widgets/bella_action_card.dart';
import 'widgets/bella_consent_card.dart';
import 'widgets/bella_pro_upsell_card.dart';
import 'widgets/bella_wound_analysis_card.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/suggestion_chips.dart';
import '../../../ui/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

/// Floating chat overlay for Bella AI.
///
/// Slides up from the bottom-right when opened; covers ~85 % of the
/// screen height with a glass-morphism card.
class BellaChatOverlay extends StatefulWidget {
  const BellaChatOverlay({super.key, required this.controller});

  final BellaOverlayController controller;

  @override
  State<BellaChatOverlay> createState() => _BellaChatOverlayState();
}

class _BellaChatOverlayState extends State<BellaChatOverlay> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onStateChanged);
    widget.controller.checkConsent();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
    _scrollToBottom();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onStateChanged);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    HapticFeedback.lightImpact();
    _textController.clear();
    widget.controller.send(trimmed);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: MotionDuration.medium,
          curve: MotionCurve.standard,
        );
      }
    });
  }

  Future<void> _handleCamera() async {
    final l = AppLocalizations.of(context)!;
    if (!ConnectivityService.instance.isOnline.value) return;

    final navContext = OperationsbegleiterApp
        .appNavigatorKey?.currentState?.overlay?.context;
    if (navContext == null) return;

    if (!widget.controller.isPro) {
      SmartPaywall.trigger(
        context: navContext,
        triggerContext: TriggerContext.assistantFeature,
      );
      return;
    }

    // Context obtained from global navigator key — safe after async gap.
    final source = await showCupertinoModalPopup<ImageSource>(
      // ignore: use_build_context_synchronously
      context: navContext,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(l.woundPhotoForAnalysis),
        message:
            Text(l.woundChoosePhoto),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, ImageSource.camera),
            child: Text(l.woundTakePhoto),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
            child: Text(l.woundFromGallery),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: Text(l.cancel),
        ),
      ),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    // Send with wound analysis prompt
    final prompt = _textController.text.trim().isNotEmpty
        ? _textController.text.trim()
        : l.bellaDefaultWoundPrompt;
    _textController.clear();
    HapticFeedback.lightImpact();
    widget.controller.sendWithImages(prompt, [picked.path]);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final messages = widget.controller.messages;
    final isTyping = widget.controller.isTyping;
    final bottomInset = mq.viewInsets.bottom; // keyboard height

    return Positioned.fill(
      child: Stack(
        children: [
          // Scrim
          GestureDetector(
            onTap: widget.controller.close,
            child: Container(color: Colors.black54),
          ),

          // Chat card
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: mq.padding.top + AppSpacing.xl,
            bottom: bottomInset > 0
                ? bottomInset + AppSpacing.xs
                : mq.padding.bottom + AppSpacing.xl,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  children: [
                    _Header(
                      onClose: widget.controller.close,
                      onNewChat: widget.controller.isPro
                          ? widget.controller.startNewChat
                          : null,
                      role: widget.controller.role,
                      dailyUsed: widget.controller.dailyUsed,
                      dailyLimit: widget.controller.dailyLimit,
                      isPro: widget.controller.isPro,
                      messages: widget.controller.messages,
                    ),
                    Expanded(
                      child: messages.isEmpty
                          ? _EmptyState(
                              onSuggestion: _send,
                              role: widget.controller.role,
                              isPro: widget.controller.isPro,
                              onSymptomCheck:
                                  widget.controller.startSymptomCheck,
                            )
                          : _MessageList(
                              messages: messages,
                              isTyping: isTyping,
                              scrollController: _scrollController,
                              controller: widget.controller,
                            ),
                    ),
                    if (messages.isNotEmpty && messages.length <= 4)
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: SuggestionChips(
                          onSelected: _send,
                          role: widget.controller.role,
                          isPro: widget.controller.isPro,
                          dynamicSuggestions:
                              widget.controller.dynamicSuggestions,
                          onSymptomCheck:
                              widget.controller.startSymptomCheck,
                        ),
                      ),
                    _InputBar(
                      controller: _textController,
                      focusNode: _focusNode,
                      onSend: () => _send(_textController.text),
                      onSubmitted: (t) {
                        _send(t);
                        _focusNode.requestFocus();
                      },
                      onCamera: widget.controller.isPro
                          ? _handleCamera
                          : null,
                      isUploading:
                          widget.controller.isUploadingImages,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.onClose,
    this.onNewChat,
    required this.role,
    required this.dailyUsed,
    required this.dailyLimit,
    required this.isPro,
    required this.messages,
  });
  final VoidCallback onClose;
  final VoidCallback? onNewChat;
  final AppUserRole role;
  final int dailyUsed;
  final int dailyLimit;
  final bool isPro;
  final List<ChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF0F5), Color(0xFFFCE4EC)],
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFFF6B9D).withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Bella avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B9D).withValues(alpha: 0.20),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/bella_avatar.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bella AI',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  ConnectivityService.instance.isOnline.value
                      ? switch (role) {
                          AppUserRole.doctor => l.bellaSubtitleDoctor,
                          AppUserRole.staff => l.bellaSubtitleStaff,
                          _ => l.bellaSubtitlePatient,
                        }
                      : l.offlineEingeschraenkterModus,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                    letterSpacing: -0.1,
                  ),
                ),
                if (dailyUsed > 0 && !isPro)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      l.bellaDailyUsage(dailyUsed, dailyLimit),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: dailyUsed >= dailyLimit
                            ? const Color(0xFFE53935)
                            : AppColors.textSecondary.withValues(alpha: 0.6),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // New chat button (Pro only)
          if (onNewChat != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: PressableScale(
                onTap: () {
                  Haptic.light();
                  onNewChat!();
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    CupertinoIcons.plus_bubble,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

          // Export button (≥3 messages; Free → paywall)
          if (messages.length >= 3)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: PressableScale(
                onTap: () async {
                  Haptic.light();
                  await BellaChatExporter.export(
                    messages: messages,
                    isPro: isPro,
                  );
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    CupertinoIcons.arrow_down_doc,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

          // Arzt-Briefing button (Pro only)
          if (isPro)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: PressableScale(
                onTap: () {
                  Haptic.light();
                  _openBellaBriefing(onClose);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    AppIcons.doctor,
                    size: 16,
                    color: AppIcons.doctorColor,
                  ),
                ),
              ),
            ),

          // Close button
          PressableScale(
            onTap: () {
              Haptic.light();
              onClose();
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Message list ─────────────────────────────────────────────────────

void _openBellaBriefing(VoidCallback onClose) {
  onClose();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    OperationsbegleiterApp.appNavigatorKey?.currentState?.pushNamed(
      '/bella-briefing',
    );
  });
}

void _openPaywall(BellaOverlayController controller) {
  controller.close();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    OperationsbegleiterApp.appNavigatorKey?.currentState?.pushNamed(
      '/paywall',
      arguments: {'source': 'bella_actions'},
    );
  });
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.isTyping,
    required this.scrollController,
    required this.controller,
  });

  final List<ChatMessage> messages;
  final bool isTyping;
  final ScrollController scrollController;
  final BellaOverlayController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isTyping) {
          return const TypingIndicator();
        }
        final msg = messages[index];
        final isLast = index >= messages.length - 2;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChatBubble(message: msg, animate: isLast),
            if (msg.isConsentRequest)
              BellaConsentCard(
                message: msg,
                onAccept: () => controller.acceptConsent(msg),
                onDecline: () => controller.declineConsent(msg),
              ),
            if (msg.pendingAction != null)
              BellaActionCard(
                message: msg,
                onConfirm: () => controller.confirmAction(msg),
                onCancel: () => controller.cancelAction(msg),
              ),
            if (msg.woundAnalysis != null)
              BellaWoundAnalysisCard(result: msg.woundAnalysis!),
            if (msg.showProUpsell && msg.pendingAction == null)
              BellaProUpsellCard(onTap: () => _openPaywall(controller)),
          ],
        );
      },
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onSuggestion, required this.role, required this.isPro, this.onSymptomCheck});
  final ValueChanged<String> onSuggestion;
  final AppUserRole role;
  final bool isPro;
  final VoidCallback? onSymptomCheck;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.xxxl),

          Text(
            l.bellaGreeting,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),

          Text(
            switch (role) {
              AppUserRole.doctor => l.bellaDescriptionDoctor,
              AppUserRole.staff => l.bellaDescriptionStaff,
              _ => l.bellaDescriptionPatient,
            },
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Feature pills
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: switch (role) {
              AppUserRole.doctor => [
                  _FeaturePill(icon: AppIcons.vitals,
                    iconColor: AppIcons.vitalsColor, label: l.bellaFeatureDashboard),
                  _FeaturePill(icon: AppIcons.family, iconColor: AppIcons.familyColor, label: l.bellaFeaturePatients),
                  _FeaturePill(icon: CupertinoIcons.device_phone_portrait, iconColor: AppColors.primary, label: l.bellaFeatureAppHelp),
                  _FeaturePill(icon: AppIcons.hospital,
                    iconColor: AppIcons.hospitalColor, label: l.bellaFeatureMedicalKnowledge),
                ],
              AppUserRole.staff => [
                  _FeaturePill(icon: AppIcons.clipboard,
                    iconColor: AppIcons.clipboardColor, label: l.bellaFeatureTasks),
                  _FeaturePill(icon: AppIcons.family, iconColor: AppIcons.familyColor, label: l.bellaFeaturePatients),
                  _FeaturePill(icon: CupertinoIcons.device_phone_portrait, iconColor: AppColors.primary, label: l.bellaFeatureAppHelp),
                  _FeaturePill(icon: AppIcons.hospital,
                    iconColor: AppIcons.hospitalColor, label: l.bellaFeatureMedicalKnowledge),
                ],
              _ => [
                  _FeaturePill(icon: AppIcons.hospital,
                    iconColor: AppIcons.hospitalColor, label: l.bellaFeatureMedicalKnowledge),
                  _FeaturePill(icon: CupertinoIcons.device_phone_portrait, iconColor: AppColors.primary, label: l.bellaFeatureAppHelp),
                  _FeaturePill(icon: AppIcons.wound,
                    iconColor: AppIcons.woundColor, label: l.bellaFeatureAftercare),
                  _FeaturePill(icon: AppIcons.redFlags,
                    iconColor: AppIcons.redFlagsColor, label: l.bellaFeatureWarnings),
                ],
            },
          ),
          const SizedBox(height: AppSpacing.xxl),

          SuggestionChips(onSelected: onSuggestion, role: role, isPro: isPro, onSymptomCheck: onSymptomCheck),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ─── Feature pill ─────────────────────────────────────────────────────

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon,
    required this.iconColor, required this.label});
  final IconData icon;

  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: AppRadius.borderRadiusPill,
        border: Border.all(
          color: Colors.grey.shade200,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassIcon(icon: icon, color: iconColor, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Input bar ────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.onSubmitted,
    this.onCamera,
    this.isUploading = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onCamera;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Camera / wound analysis button (Pro only)
              if (onCamera != null)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: PressableScale(
                    onTap: isUploading ? null : onCamera,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isUploading
                            ? Colors.grey.shade200
                            : const Color(0xFFFFF0F5),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isUploading
                              ? Colors.grey.shade300
                              : const Color(0xFFFF6B9D)
                                  .withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: isUploading
                          ? const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFFF6B9D),
                                ),
                              ),
                            )
                          : const Icon(
                              CupertinoIcons.camera_fill,
                              size: 17,
                              color: Color(0xFFFF6B9D),
                            ),
                    ),
                  ),
                ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: AppRadius.borderRadiusPill,
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 0.5,
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onSubmitted: onSubmitted,
                    textInputAction: TextInputAction.send,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.1,
                    ),
                    decoration: InputDecoration(
                      hintText: l.frageAnBella,
                      hintStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey400,
                      ),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              PressableScale(
                onTap: onSend,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF6B9D), Color(0xFFC44EBB)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(0xFFFF6B9D).withValues(alpha: 0.30),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l.bellaDisclaimer,
            style: TextStyle(
              fontSize: 9,
              color: AppColors.grey500.withValues(alpha: 0.7),
              letterSpacing: -0.1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
