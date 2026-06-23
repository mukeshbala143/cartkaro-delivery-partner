import 'package:flutter/material.dart';

/// Responsive utility helpers for scaling UI across mobile, tablet
/// and desktop/web screen sizes.
class Responsive {
  final BuildContext context;
  late double screenWidth;
  late double screenHeight;
  late Orientation orientation;

  Responsive(this.context) {
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    orientation = MediaQuery.of(context).orientation;
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  /// Returns a width based on a percentage of the current screen width.
  double widthPercent(double percent) => screenWidth * (percent / 100);

  /// Returns a height based on a percentage of the current screen height.
  double heightPercent(double percent) => screenHeight * (percent / 100);

  /// Returns a responsive font size scaled against a 375px design baseline
  /// (iPhone X logical width), clamped to avoid extreme scaling.
  double sp(double size) {
    final scale = screenWidth / 375;
    final clamped = scale.clamp(0.85, 1.25);
    return size * clamped;
  }

  /// Picks the right value for the current breakpoint.
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }
}

/// Convenience accessor: `context.responsive`.
extension ResponsiveExtension on BuildContext {
  Responsive get responsive => Responsive(this);
}