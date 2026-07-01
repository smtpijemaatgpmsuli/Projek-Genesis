import 'package:flutter/material.dart';

/// Breakpoints sesuai [11_RESPONSIVE_DESIGN_GUIDELINES.md].
const double _tabletMinWidth = 600;
const double _tabletMaxWidth = 1023;
const double _desktopMinWidth = 1024;

/// Widget adaptif yang menampilkan layout berbeda berdasarkan lebar layar.
///
/// - Mobile: layar < 600px
/// - Tablet: layar 600px - 1023px (opsional, fallback ke mobile jika null)
/// - Desktop: layar >= 1024px
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    required this.mobile,
    required this.desktop,
    this.tablet,
    super.key,
  });

  final Widget mobile;
  final Widget desktop;
  final Widget? tablet;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= _desktopMinWidth) {
      return desktop;
    }

    if (width >= _tabletMinWidth && width <= _tabletMaxWidth && tablet != null) {
      return tablet!;
    }

    return mobile;
  }
}
