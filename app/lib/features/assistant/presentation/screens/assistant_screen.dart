import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/assistant_repository.dart';
import '../../domain/energy_snapshot.dart';
import '../controllers/chat_controller.dart';

/// F9 — ask anything about the backup in English or Roman Urdu (DESIGN.md
/// §11 Assistant). Every number in an answer comes from the engine snapshot;
/// when the AI can't be reached the same numbers arrive as template text.
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final question = text ?? _input.text;
    if (question.trim().isEmpty) return;
    _input.clear();
    ref.read(chatControllerProvider.notifier).send(question);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chat = ref.watch(chatControllerProvider);
    // The list is reversed so the newest message sits by the input and
    // new ones never need a manual scroll.
    ref.listen(chatControllerProvider, (_, _) {
      if (_scroll.hasClients) _scroll.jumpTo(0);
    });

    return BbScaffold(
      title: l10n.tabAssistant,
      body: Column(
        children: [
          Expanded(
            child: chat.entries.isEmpty
                ? _Intro(onAsk: _send)
                : ListView(
                    controller: _scroll,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    children: [
                      if (chat.waiting)
                        BbChatBubble.typing(
                          semanticLabel: l10n.assistantTyping,
                        ),
                      for (final (i, entry)
                          in chat.entries.indexed.toList().reversed)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: _Entry(
                            entry: entry,
                            isLast: i == chat.entries.length - 1,
                          ),
                        ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: BbTextField(
                    label: l10n.assistantInputLabel,
                    controller: _input,
                    pill: true,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const BbGap.xs(),
                BbIconButton(
                  icon: BbIcons.send,
                  tooltip: l10n.assistantSend,
                  variant: BbIconButtonVariant.tonal,
                  onPressed: chat.waiting ? null : _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.onAsk});

  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final suggestions = [
      l10n.assistantSuggestBackup,
      l10n.assistantSuggestTurnOff,
      l10n.assistantSuggestSolar,
    ];
    return ListView(
      children: [
        BbEmptyState(
          icon: BbIcons.ai,
          title: l10n.assistantIntroTitle,
          message: l10n.assistantIntroBody,
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final s in suggestions)
              BbChip(label: s, selected: false, onSelected: () => onAsk(s)),
          ],
        ),
        const BbGap.lg(),
        Text(
          l10n.assistantFootnote,
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _Entry extends ConsumerWidget {
  const _Entry({required this.entry, required this.isLast});

  final ChatEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return switch (entry.kind) {
      ChatEntryKind.user => BbChatBubble(text: entry.text, fromUser: true),
      ChatEntryKind.assistant => BbChatBubble(
        text: entry.text,
        fromUser: false,
      ),
      ChatEntryKind.noData => BbChatBubble(
        text: l10n.assistantNoData,
        fromUser: false,
      ),
      // Never color alone: the banner carries an icon and a title too.
      ChatEntryKind.safety => BbBanner(
        tone: BbBannerTone.danger,
        title: l10n.assistantSafetyTitle,
        message: l10n.assistantSafetyBody,
      ),
      ChatEntryKind.fallback => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BbChatBubble(
            text: _fallback(l10n, ref.watch(energySnapshotProvider)),
            fromUser: false,
          ),
          // The exact cause, so a developer sees why without a debugger.
          if (kDebugMode && entry.failure?.detail != null) ...[
            const BbGap.xs(),
            SelectableText(
              entry.failure!.detail!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          ],
          // Retrying can't beat the daily limit.
          if (isLast &&
              entry.failure?.code != AssistantFailureCode.dailyLimit) ...[
            const BbGap.xs(),
            BbButton.secondary(
              label: l10n.tryAgain,
              icon: BbIcons.refresh,
              onPressed: () =>
                  ref.read(chatControllerProvider.notifier).retry(),
            ),
          ],
        ],
      ),
    };
  }

  /// Template text from the same engine numbers (TECH_STACK §7.6.4).
  String _fallback(AppLocalizations l10n, EnergySnapshot? s) {
    final why = switch (entry.failure?.code) {
      AssistantFailureCode.offline || null => l10n.assistantOffline,
      AssistantFailureCode.busy => l10n.assistantBusy,
      AssistantFailureCode.unavailable => l10n.assistantUnavailable,
      AssistantFailureCode.dailyLimit => l10n.assistantDailyLimit,
      AssistantFailureCode.notConfigured => l10n.assistantNotConfigured,
      AssistantFailureCode.badKey => l10n.assistantBadKey,
      AssistantFailureCode.badModel => l10n.assistantBadModel,
    };
    if (s == null) return why;
    final best = s.bestSwitchOff, gain = s.bestGainHours;
    return [
      why,
      l10n.assistantFallbackBackup(
        Formatters.duration(l10n, s.backupHours),
        Formatters.watts(s.loadW),
      ),
      if (best != null && gain != null)
        l10n.adviceTurnOff(best, Formatters.duration(l10n, gain)),
    ].join(' ');
  }
}
