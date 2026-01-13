import 'package:flutter/services.dart';

class AppHaptics {
  /// Light haptic feedback for standard student inputs
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Heavy haptic feedback for faculty alerts and critical thresholds
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Medium haptic feedback for general interactions
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Selection click for toggles and switches
  static void selection() {
    HapticFeedback.selectionClick();
  }
}
