import 'package:flutter/material.dart';

import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';
import '../feedback/bb_typing_indicator.dart';

/// One chat message (DESIGN.md §11 Assistant). The user's sit right in navy,
/// the assistant's left on the muted surface; the corner nearest the sender
/// is the 4 px "tail". No border — fill alone separates it (DESIGN §5).
/// Numbers in the text use the tabular metric style so they line up and
/// stand out.
///
/// ```dart
/// BbChatBubble(text: message.text, fromUser: message.fromUser)
/// BbChatBubble.typing(semanticLabel: l10n.assistantTyping)
/// ```
class BbChatBubble extends StatelessWidget {
  const BbChatBubble({
    super.key,
    required String this.text,
    required this.fromUser,
  }) : typingLabel = null;

  /// The assistant is still writing: the bubble holds a `BbTypingIndicator`.
  const BbChatBubble.typing({super.key, required String semanticLabel})
    : text = null,
      fromUser = false,
      typingLabel = semanticLabel;

  final String? text;
  final bool fromUser;
  final String? typingLabel;

  /// Bubbles stop well short of the far edge so who said what stays clear.
  static const _maxWidthShare = 0.85;
  static const _tail = Radius.circular(AppRadius.xs);
  static const _round = Radius.circular(AppRadius.lg);

  // "3h", "28m", "2,170 W", "5:35 PM", "3.3–4.5 kWh", "85%".
  static final _number = RegExp(
    r'\d[\d,.:–]*(?:\s?(?:kWh|kW|W|h|m|%|AM|PM)\b|%)?',
  );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fill = fromUser ? c.secondary : c.surfaceMuted;
    final fg = fromUser ? c.onSecondary : c.textPrimary;
    final text = this.text;
    final typingLabel = this.typingLabel;

    return Align(
      alignment: fromUser
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: LayoutBuilder(
        builder: (context, constraints) => ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth * _maxWidthShare,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadiusDirectional.only(
                topStart: _round,
                topEnd: _round,
                bottomStart: fromUser ? _round : _tail,
                bottomEnd: fromUser ? _tail : _round,
              ),
            ),
            child: text == null
                ? BbTypingIndicator(semanticLabel: typingLabel!)
                : Text.rich(_spans(context, text, fg)),
          ),
        ),
      ),
    );
  }

  TextSpan _spans(BuildContext context, String text, Color fg) {
    final body = context.textTheme.bodyLarge?.copyWith(color: fg);
    final metric = context.text.metricSmall.copyWith(color: fg);
    final spans = <TextSpan>[];
    var start = 0;
    for (final m in _number.allMatches(text)) {
      if (m.start > start) {
        spans.add(TextSpan(text: text.substring(start, m.start)));
      }
      spans.add(TextSpan(text: m[0], style: metric));
      start = m.end;
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
    return TextSpan(style: body, children: spans);
  }
}
