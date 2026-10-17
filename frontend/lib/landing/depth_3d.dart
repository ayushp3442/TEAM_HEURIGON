import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Depth3D Widget
// Applies true 3D perspective projection with translation (x, y, z),
// rotation (rotateX, rotateY, rotateZ), scale, and opacity.
// ---------------------------------------------------------------------------

class Depth3D extends StatelessWidget {
  final double x;
  final double y;
  final double z;
  final double rotateX;
  final double rotateY;
  final double rotateZ;
  final double scale;
  final double opacity;
  final Alignment alignment;
  final Widget child;

  const Depth3D({
    super.key,
    this.x = 0.0,
    this.y = 0.0,
    this.z = 0.0,
    this.rotateX = 0.0,
    this.rotateY = 0.0,
    this.rotateZ = 0.0,
    this.scale = 1.0,
    this.opacity = 1.0,
    this.alignment = Alignment.center,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final clampedOpacity = opacity.clamp(0.0, 1.0);
    if (clampedOpacity == 0.0) {
      return const SizedBox.shrink();
    }

    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // 3D Perspective focal depth
      // ignore: deprecated_member_use
      ..translate(x, y, z)
      ..rotateX(rotateX)
      ..rotateY(rotateY)
      ..rotateZ(rotateZ)
      // ignore: deprecated_member_use
      ..scale(scale);

    Widget result = Transform(
      transform: matrix,
      alignment: alignment,
      child: child,
    );

    if (clampedOpacity < 1.0) {
      result = Opacity(
        opacity: clampedOpacity,
        child: result,
      );
    }

    return result;
  }
}

// ---------------------------------------------------------------------------
// MouseTilt Widget (Desktop only)
// Tilts at most 4 degrees toward the pointer, eased, without third-party libs.
// ---------------------------------------------------------------------------

class MouseTilt extends StatefulWidget {
  final Widget child;
  final double maxTiltDegrees;
  final bool enabled;

  const MouseTilt({
    super.key,
    required this.child,
    this.maxTiltDegrees = 4.0,
    this.enabled = true,
  });

  @override
  State<MouseTilt> createState() => _MouseTiltState();
}

class _MouseTiltState extends State<MouseTilt> with SingleTickerProviderStateMixin {
  double _targetTiltX = 0.0;
  double _targetTiltY = 0.0;

  @override
  Widget build(BuildContext context) {
    final isDesktopWeb = kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux);

    if (!widget.enabled || !isDesktopWeb) {
      return widget.child;
    }

    final maxRad = widget.maxTiltDegrees * (math.pi / 180.0);

    return MouseRegion(
      onHover: (event) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;
        final size = renderBox.size;
        if (size.width == 0 || size.height == 0) return;

        final localPos = event.localPosition;
        final normX = ((localPos.dx / size.width) - 0.5) * 2.0; // -1.0 to 1.0
        final normY = ((localPos.dy / size.height) - 0.5) * 2.0; // -1.0 to 1.0

        setState(() {
          // Inverting Y so tilting feels natural to the light source
          _targetTiltX = -normY * maxRad;
          _targetTiltY = normX * maxRad;
        });
      },
      onExit: (_) {
        setState(() {
          _targetTiltX = 0.0;
          _targetTiltY = 0.0;
        });
      },
      child: TweenAnimationBuilder<Offset>(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: Offset(_targetTiltX, _targetTiltY),
        ),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        builder: (ctx, offset, child) {
          final matrix = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(offset.dx)
            ..rotateY(offset.dy);

          return Transform(
            transform: matrix,
            alignment: Alignment.center,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
