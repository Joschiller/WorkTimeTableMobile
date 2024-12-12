import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class CircleDecoration extends Decoration {
  const CircleDecoration({
    required this.colorLeft,
    required this.colorRight,
    required this.radius,
    required this.rotation,
  });

  final Color colorLeft;
  final Color colorRight;
  final double radius;
  final double rotation;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _CircleDecorationPainter(
        colorLeft: colorLeft,
        colorRight: colorRight,
        radius: radius,
        rotation: rotation,
      );
}

enum CircleSide { left, right }

const correctionOffset = 0.5;

class _CircleDecorationPainter extends BoxPainter {
  _CircleDecorationPainter({
    required this.colorLeft,
    required this.colorRight,
    required this.radius,
    required this.rotation,
  });

  final Color colorLeft;
  final Color colorRight;
  final double radius;
  final double rotation;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final bounds = offset & (configuration.size ?? Size.zero);
    canvas.drawPath(
      _drawSide(
        side: CircleSide.left,
        radius: radius,
        rotation: rotation,
        bounds: bounds,
      ),
      Paint()..color = colorLeft,
    );
    canvas.drawPath(
      _drawSide(
        side: CircleSide.right,
        radius: radius,
        rotation: rotation,
        bounds: bounds,
      ),
      Paint()..color = colorRight,
    );
  }

  Path _drawSide({
    required CircleSide side,
    required Rect bounds,
    required double radius,
    required double rotation,
  }) {
    final path = Path();

    switch (side) {
      case CircleSide.left:
        path.moveTo(correctionOffset, -radius);
        path.arcToPoint(
          Offset(correctionOffset, radius),
          radius: Radius.elliptical(radius, radius),
          clockwise: false,
        );
        break;
      case CircleSide.right:
        path.moveTo(0, -radius);
        path.arcToPoint(
          Offset(0, radius),
          radius: Radius.elliptical(radius, radius),
          clockwise: true,
        );
        break;
    }
    path.close();

    final rotationMatrix = Float64List.fromList(
      [
        cos(rotation),
        sin(rotation),
        0,
        0,
        -sin(rotation),
        cos(rotation),
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        1,
      ],
    );
    final translationMatrix = Float64List.fromList([
      1,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      1,
      0,
      bounds.center.dx,
      bounds.center.dy,
      0,
      1
    ]);
    return path.transform(rotationMatrix).transform(translationMatrix);
  }
}
