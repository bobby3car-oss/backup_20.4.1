import 'package:flutter/material.dart';

/// Centers content and constrains its width on wide viewports.
///
/// On narrow screens (< [breakpoint]) this is a passthrough.
/// On wider screens it caps at [maxWidth] with extra horizontal padding,
/// giving the app a clean centered-column layout for web and tablets.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 720,
    this.breakpoint = 760,
  });

  final Widget child;
  final double maxWidth;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < breakpoint) return child;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
