import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/alert_scheduler.dart';
import '../../core/services/clock.dart';
import '../../core/services/notification_inbox.dart';
import '../../core/services/preferences.dart';
import '../../core/utils/fire_and_forget.dart';
import '../../core/utils/formatters.dart';
import '../../features/outages/domain/outage_outlook.dart';
import '../l10n/app_localizations.dart';
import '../locale/locale_controller.dart';

/// How long before the predicted outage the phone warns: time to charge
/// phones, fill water or switch heavy loads off.
const alertLead = Duration(minutes: 30);

class PlannedAlert {
  const PlannedAlert({
    required this.atUtc,
    required this.title,
    required this.body,
  });

  final DateTime atUtc;
  final String title;
  final String body;
}

/// The alert for [outlook]'s next outage, or null when there is nothing to
/// warn about: no prediction, the power is already out, or it is too late
/// for a heads-up.
PlannedAlert? planOutageAlert(
  OutageOutlook? outlook,
  DateTime nowUtc,
  AppLocalizations l10n,
) {
  final next = outlook?.next;
  final readiness = outlook?.readiness;
  if (outlook == null || next == null || readiness == null) return null;
  if (outlook.ongoing != null) return null;
  final startUtc = next.start.toUtc();
  final atUtc = startUtc.subtract(alertLead);
  if (!atUtc.isAfter(nowUtc)) return null;

  final when = Formatters.localClock(next.start);
  final soc = Formatters.percent(readiness.socAtStart);
  final backup = Formatters.duration(l10n, readiness.backup.hours);
  final outage = next.hours;
  return PlannedAlert(
    atUtc: atUtc,
    title: next.source == PredictionSource.schedule
        ? l10n.alertTitleScheduled(when)
        : l10n.alertTitleLikely(when),
    body: readiness.coversOutage == false && outage != null
        ? l10n.alertBodyShort(soc, backup, Formatters.duration(l10n, outage))
        : l10n.alertBodyReady(soc, backup),
  );
}

/// The user's switch in Settings; on by default.
class OutageAlertsEnabled extends Notifier<bool> {
  static const _key = 'outageAlerts';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? true;

  void set(bool on) {
    state = on;
    ref.read(sharedPreferencesProvider).setBool(_key, on);
  }
}

final outageAlertsEnabledProvider = NotifierProvider<OutageAlertsEnabled, bool>(
  OutageAlertsEnabled.new,
);

/// Keeps the one pending alert in step with the prediction. Watched by the
/// app root for the whole session. Reschedules only when the predicted
/// start changes, not on every minute's tick.
final outageAlertsProvider = Provider<void>((ref) {
  final scheduler = ref.watch(alertSchedulerProvider);
  DateTime? scheduledFor;

  void sync() {
    final enabled = ref.read(outageAlertsEnabledProvider);
    final now = ref.read(nowProvider).value ?? DateTime.now().toUtc();
    final l10n = lookupAppLocalizations(ref.read(localeProvider).locale);
    final plan = enabled
        ? planOutageAlert(ref.read(outageOutlookProvider), now, l10n)
        : null;
    if (plan?.atUtc == scheduledFor) return;
    scheduledFor = plan?.atUtc;
    planInbox(
      ref,
      const {InboxKind.outageAlert},
      [
        if (plan != null)
          InboxEntry(
            kind: InboxKind.outageAlert,
            at: plan.atUtc,
            title: plan.title,
            body: plan.body,
          ),
      ],
      now,
    );
    fireAndForget(
      plan == null
          ? scheduler.cancel()
          : scheduler.schedule(
              atUtc: plan.atUtc,
              title: plan.title,
              body: plan.body,
            ),
      'outage alert',
    );
  }

  ref.listen(outageOutlookProvider, (_, _) => sync());
  ref.listen(outageAlertsEnabledProvider, (_, _) => sync());
  ref.listen(localeProvider, (_, _) {
    scheduledFor = null; // Same time, new language: rewrite the text.
    sync();
  });
  sync();
});
