import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden.dart';

void main() {
  testWidgets('user bubbles sit at the end, assistant bubbles at the start', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(
        const Column(
          children: [
            BbChatBubble(text: 'Kitni der chalegi?', fromUser: true),
            BbChatBubble(text: 'About 3h 28m.', fromUser: false),
          ],
        ),
      ),
    );
    final user = tester.getRect(find.text('Kitni der chalegi?'));
    final reply = tester.getRect(find.textContaining('About'));
    expect(user.center.dx, greaterThan(200));
    expect(reply.center.dx, lessThan(200));
  });

  testWidgets('typing bubble announces itself', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      themed(const BbChatBubble.typing(semanticLabel: 'Assistant is typing')),
    );
    expect(find.bySemanticsLabel('Assistant is typing'), findsOneWidget);
    expect(find.byType(BbTypingIndicator), findsOneWidget);
    handle.dispose();
  });

  goldenMatrix(
    'bb_chat',
    () => const Column(
      children: [
        BbChatBubble(
          text: 'Raat 2 baje tak fan chal sakta hai?',
          fromUser: true,
        ),
        BbGap.md(),
        BbChatBubble(
          text:
              'Yes. At 410 W your battery lasts 3h 28m, so it runs until '
              'about 2:15 AM. Turning off the TV adds 37m.',
          fromUser: false,
        ),
        BbGap.md(),
        BbChatBubble.typing(semanticLabel: 'Assistant is typing'),
      ],
    ),
    size: const Size(400, 360),
  );
}
