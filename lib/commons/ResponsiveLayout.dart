import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context, double containerWidth) builder;
  final List<BreakPoint> breakPoints;

  const ResponsiveLayout({
    Key? key,
    required this.builder,
    required this.breakPoints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sortedBreakPoints = List<BreakPoint>.from(breakPoints)
          ..sort((a, b) => b.minWidth.compareTo(a.minWidth));

        for (var breakPoint in sortedBreakPoints) {
          if (constraints.maxWidth >= breakPoint.minWidth) {
            return builder(context, breakPoint.containerWidth);
          }
        }

        // デフォルトの場合（最小のブレークポイント以下の場合）
        return builder(context, sortedBreakPoints.last.containerWidth);
      },
    );
  }
}

class BreakPoint {
  final double minWidth;
  final double containerWidth;

  const BreakPoint({required this.minWidth, required this.containerWidth});
}
