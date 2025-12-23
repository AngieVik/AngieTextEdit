import 'package:flutter/material.dart';

/// Responsive layout wrapper for adapting UI to different screen sizes
class ResponsiveLayout extends StatelessWidget {
  /// Widget to show on mobile devices (width < 600)
  final Widget mobile;

  /// Widget to show on tablets (600 <= width < 900)
  final Widget? tablet;

  /// Widget to show on desktop (width >= 900)
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 900;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  /// Get responsive value based on screen size
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= 600) {
      return tablet ?? mobile;
    }
    return mobile;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets padding(BuildContext context) {
    return value(
      context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(32),
    );
  }

  /// Get responsive sidebar width
  static double sidebarWidth(BuildContext context) {
    return value(
      context,
      mobile: 280.0,
      tablet: 320.0,
      desktop: 360.0,
    );
  }

  /// Check if sidebar should be visible by default
  static bool showSidebarByDefault(BuildContext context) {
    return isDesktop(context);
  }
}

/// Extension for responsive values
extension ResponsiveExtension on BuildContext {
  bool get isMobile => ResponsiveLayout.isMobile(this);
  bool get isTablet => ResponsiveLayout.isTablet(this);
  bool get isDesktop => ResponsiveLayout.isDesktop(this);

  EdgeInsets get responsivePadding => ResponsiveLayout.padding(this);
  double get sidebarWidth => ResponsiveLayout.sidebarWidth(this);
}
