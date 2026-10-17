import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// ScrollEngine & SceneProgress Helper
// Converts continuous overall scroll progress into localized 0.0 -> 1.0
// scene progress values with smooth easing curves and windowing.
// ---------------------------------------------------------------------------

class SceneRange {
  final double start;
  final double end;

  const SceneRange(this.start, this.end);
}

class SceneProgress {
  static const int totalScenes = 8;

  // Each scene has an entry/exit segment along the normalized 0.0 -> 1.0 scroll
  static const List<SceneRange> ranges = [
    SceneRange(0.000, 0.125), // Scene 0: Hero
    SceneRange(0.125, 0.250), // Scene 1: The doubt
    SceneRange(0.250, 0.375), // Scene 2: The search
    SceneRange(0.375, 0.500), // Scene 3: Still stuck
    SceneRange(0.500, 0.625), // Scene 4: A senior who has been there
    SceneRange(0.625, 0.750), // Scene 5: How it works
    SceneRange(0.750, 0.875), // Scene 6: Chat for 24 hours
    SceneRange(0.875, 1.000), // Scene 7: Your turn
  ];

  /// Raw unclamped relative progress for a given scene
  static double raw(int sceneIndex, double overall) {
    if (sceneIndex < 0 || sceneIndex >= ranges.length) return 0.0;
    final r = ranges[sceneIndex];
    if (r.end == r.start) return 0.0;
    return (overall - r.start) / (r.end - r.start);
  }

  /// Clamped local progress in [0.0, 1.0]
  static double progress(int sceneIndex, double overall) {
    final v = raw(sceneIndex, overall);
    return v.clamp(0.0, 1.0);
  }

  /// Eased progress using standard Cubic easeInOut
  static double easeInOut(double t) {
    return Curves.easeInOut.transform(t.clamp(0.0, 1.0));
  }

  /// Linear interpolation helper
  static double lerp(double a, double b, double t) {
    return ui.lerpDouble(a, b, t) ?? a;
  }

  /// Smooth clamp helper
  static double clamp(double v, double min, double max) {
    return v.clamp(min, max);
  }

  /// Scene visibility test for performance culling:
  /// returns true if the scene is within its active window plus a small buffer.
  static bool isVisible(int sceneIndex, double overall, {double margin = 0.04}) {
    if (sceneIndex < 0 || sceneIndex >= ranges.length) return false;
    final r = ranges[sceneIndex];
    return overall >= (r.start - margin) && overall <= (r.end + margin);
  }
}
