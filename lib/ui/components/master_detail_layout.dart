import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Breakpoint above which master and detail are shown side-by-side.
const _kWideBreakpoint = 900.0;

/// A responsive master–detail layout.
///
/// - **≥ 900 dp**: both panels shown side-by-side (master flex 2, detail
///   flex 3) separated by a [VerticalDivider]. When [detailWidget] is null
///   a placeholder is shown on the right.
/// - **< 900 dp**: only [masterWidget] is visible. When [detailSelected] is
///   `true` and a [detailWidget] is provided, the detail replaces the master
///   full-screen. Call [onBackFromDetail] to return to the master.
class MasterDetailLayout extends StatelessWidget {
  const MasterDetailLayout({
    super.key,
    required this.masterWidget,
    this.detailWidget,
    this.detailSelected = false,
    this.onBackFromDetail,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyText = 'Bitte wählen Sie einen Eintrag',
  });

  /// The list / master panel.
  final Widget masterWidget;

  /// The detail panel shown on the right (wide) or full-screen (narrow).
  final Widget? detailWidget;

  /// Whether a detail item is currently selected.
  /// On narrow screens this swaps from master to detail view.
  final bool detailSelected;

  /// Called when the user taps the back button on narrow detail view.
  final VoidCallback? onBackFromDetail;

  /// Icon shown in the empty-state placeholder on wide screens.
  final IconData emptyIcon;

  /// Text shown in the empty-state placeholder on wide screens.
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= _kWideBreakpoint;

    if (isWide) {
      return Row(
        children: [
          Expanded(flex: 2, child: masterWidget),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            flex: 3,
            child: detailWidget ?? _EmptyDetailPlaceholder(
              icon: emptyIcon,
              text: emptyText,
            ),
          ),
        ],
      );
    }

    // Narrow: show detail full-screen when selected.
    if (detailSelected && detailWidget != null) {
      return Column(
        children: [
          _NarrowDetailBar(onBack: onBackFromDetail),
          Expanded(child: detailWidget!),
        ],
      );
    }

    return masterWidget;
  }
}

/// A slim back-button bar for the narrow detail view.
class _NarrowDetailBar extends StatelessWidget {
  const _NarrowDetailBar({this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 4, top: 4),
          child: BackButton(onPressed: onBack),
        ),
      ),
    );
  }
}

/// Placeholder shown on the detail side when nothing is selected.
class _EmptyDetailPlaceholder extends StatelessWidget {
  const _EmptyDetailPlaceholder({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.grey400),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
