import 'package:flutter/material.dart';

import '../theme/spacing.dart';

/// A responsive grid that adapts column count to the available width.
///
/// - **< 600 dp**: 1 column (single-column layout)
/// - **≥ 600 dp**: 2 columns
/// - **≥ 1000 dp**: 3 columns
///
/// Children are sized equally within each row, with [AppSpacing.md]
/// horizontal and vertical spacing.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final int crossAxisCount;
        if (width >= 1000) {
          crossAxisCount = 3;
        } else if (width >= 600) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        const spacing = AppSpacing.md;

        // Use Wrap for intrinsic-height children (GridView forces uniform
        // cell heights which rarely suits mixed-content cards).
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: _childWidth(width, crossAxisCount), child: child),
          ],
        );
      },
    );
  }

  static double _childWidth(double totalWidth, int columns) {
    const spacing = AppSpacing.md;
    return (totalWidth - spacing * (columns - 1)) / columns;
  }
}
