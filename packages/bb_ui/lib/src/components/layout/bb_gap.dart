import 'package:flutter/widgets.dart';

import '../../foundations/tokens/spacing.dart';

/// Space between widgets, from the 4-pt scale only (DESIGN.md §4.1). Works
/// in rows and columns.
///
/// ```dart
/// Column(children: [title, const BbGap.md(), card])
/// ```
class BbGap extends StatelessWidget {
  const BbGap.xxs({super.key}) : size = AppSpacing.xxs;
  const BbGap.xs({super.key}) : size = AppSpacing.xs;
  const BbGap.sm({super.key}) : size = AppSpacing.sm;
  const BbGap.md({super.key}) : size = AppSpacing.md;
  const BbGap.lg({super.key}) : size = AppSpacing.lg;
  const BbGap.xl({super.key}) : size = AppSpacing.xl;
  const BbGap.xxl({super.key}) : size = AppSpacing.xxl;
  const BbGap.xxxl({super.key}) : size = AppSpacing.xxxl;

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(dimension: size);
}
