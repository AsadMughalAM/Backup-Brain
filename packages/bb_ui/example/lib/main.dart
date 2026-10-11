import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';

/// Component Gallery: the single place to review bb_ui tokens and components
/// in both themes before using them in screens (TECH_STACK.md §6.8).
/// A developer tool, so its labels are not localized.
void main() => runApp(const GalleryApp());

class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  var _mode = ThemeMode.light;

  void _toggle() => setState(
    () => _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
  );

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'bb_ui Gallery',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: _mode,
    themeAnimationDuration: AppMotion.normal,
    home: _GalleryPage(onToggleTheme: _toggle),
  );
}

class _GalleryPage extends StatelessWidget {
  const _GalleryPage({required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: const Text('bb_ui Gallery'),
        actions: [
          BbIconButton(
            tooltip: 'Switch theme',
            onPressed: onToggleTheme,
            icon: context.isDarkTheme ? BbIcons.themeLight : BbIcons.themeDark,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        children: [
          const _Section('BbCountdownRing', child: _RingDemo()),
          const _Section('BbStatTile', child: _StatTilesDemo()),
          const _Section('BbButton / BbIconButton', child: _ButtonsDemo()),
          const _Section('BbBanner', child: _BannersDemo()),
          const _Section('BbCard', child: _CardsDemo()),
          const _Section('Metrics (Geist Mono)', child: _MetricsDemo()),
          const _Section('Type scale (Geist)', child: _TypeScale()),
          _Section('AppColors', child: _Swatches(colors.tokens)),
          _Section('EnergyColors', child: _Swatches(context.energy.tokens)),
          const _Section('BbIcons', child: _IconGrid()),
          const _Section('Elevation', child: _ElevationDemo()),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, {required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    ),
  );
}

/// Drag the slider to watch the arc animate and change status color; the
/// switch triggers the one-time overload pulse.
class _RingDemo extends StatefulWidget {
  const _RingDemo();

  @override
  State<_RingDemo> createState() => _RingDemoState();
}

class _RingDemoState extends State<_RingDemo> {
  var _soc = 0.62;
  var _overloaded = false;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      BbCard(
        variant: BbCardVariant.hero,
        child: Center(
          child: BbCountdownRing(
            soc: _soc,
            timeLabel: '3h 28m',
            caption: 'left at 420 W',
            footnote: 'Stops protecting battery at 15%',
            isOverloaded: _overloaded,
          ),
        ),
      ),
      Slider(value: _soc, onChanged: (v) => setState(() => _soc = v)),
      SwitchListTile(
        title: const Text('Overload'),
        value: _overloaded,
        onChanged: (v) => setState(() => _overloaded = v),
      ),
      if (_overloaded)
        const BbBanner(
          tone: BbBannerTone.danger,
          title: 'Overload',
          message: 'Load is above what your inverter can supply.',
        ),
    ],
  );
}

class _StatTilesDemo extends StatelessWidget {
  const _StatTilesDemo();

  @override
  Widget build(BuildContext context) => const Column(
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: BbStatTile(
              icon: BbIcons.batteryHigh,
              tone: BbTone.success,
              label: 'Battery',
              value: '62',
              unit: '%',
            ),
          ),
          BbGap.md(),
          Expanded(
            child: BbStatTile(
              icon: BbIcons.loads,
              tone: BbTone.load,
              label: 'Load',
              value: '420',
              unit: 'W',
            ),
          ),
        ],
      ),
      BbGap.md(),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: BbStatTile(
              icon: BbIcons.solar,
              tone: BbTone.solar,
              label: 'Solar today',
              value: '3.8',
              unit: 'kWh',
              delta: '35% below normal',
            ),
          ),
          BbGap.md(),
          Expanded(
            child: BbStatTile(
              icon: BbIcons.schedule,
              tone: BbTone.grid,
              label: 'Next outage',
              value: '7:00',
              unit: 'PM',
            ),
          ),
        ],
      ),
    ],
  );
}

class _ButtonsDemo extends StatefulWidget {
  const _ButtonsDemo();

  @override
  State<_ButtonsDemo> createState() => _ButtonsDemoState();
}

class _ButtonsDemoState extends State<_ButtonsDemo> {
  var _loading = false;

  Future<void> _fakeLoad() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      BbButton(
        label: 'What should I turn off?',
        icon: BbIcons.loads,
        onPressed: () {},
      ),
      const BbGap.sm(),
      BbButton.secondary(label: 'My battery is kharab', onPressed: () {}),
      const BbGap.sm(),
      BbButton.tonal(
        label: 'Add appliance',
        icon: BbIcons.add,
        onPressed: () {},
      ),
      const BbGap.sm(),
      BbButton.ghost(label: 'See all', onPressed: () {}),
      const BbGap.sm(),
      BbButton.danger(label: 'Delete appliance', onPressed: () {}),
      const BbGap.sm(),
      const BbButton(label: 'Disabled', onPressed: null),
      const BbGap.sm(),
      BbButton.secondary(
        label: 'Find shops (tap me)',
        loading: _loading,
        loadingLabel: 'Finding shops…',
        icon: BbIcons.location,
        onPressed: _fakeLoad,
      ),
      const BbGap.sm(),
      BbButton(
        label: 'Light gayi',
        size: BbButtonSize.lg,
        expand: true,
        icon: BbIcons.gridOff,
        onPressed: () {},
      ),
      const BbGap.sm(),
      Row(
        children: [
          BbIconButton(
            icon: BbIcons.settings,
            tooltip: 'Settings',
            onPressed: () {},
          ),
          BbIconButton(
            icon: BbIcons.close,
            tooltip: 'Close',
            variant: BbIconButtonVariant.tonal,
            onPressed: () {},
          ),
        ],
      ),
    ],
  );
}

class _BannersDemo extends StatelessWidget {
  const _BannersDemo();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      BbBanner(
        message: 'Prices last updated 3 Oct. Estimates only.',
        onDismiss: () {},
        dismissLabel: 'Close',
      ),
      const BbGap.sm(),
      const BbBanner(
        tone: BbBannerTone.success,
        message: 'Battery will be full by 4:30 PM.',
      ),
      const BbGap.sm(),
      const BbBanner(
        tone: BbBannerTone.warning,
        title: 'Deep discharge',
        message: 'Avoid discharging below 50%.',
      ),
      const BbGap.sm(),
      const BbBanner(
        tone: BbBannerTone.danger,
        title: 'Battery swelling or heat',
        message: 'Disconnect the battery and call a technician.',
      ),
    ],
  );
}

class _CardsDemo extends StatelessWidget {
  const _CardsDemo();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const BbCard(child: Text('Standard card')),
      const BbGap.md(),
      BbCard(
        variant: BbCardVariant.highlight,
        child: Row(
          children: [
            Icon(
              BbIcons.ai,
              size: AppSizes.iconSm,
              color: context.colors.textMuted,
            ),
            const BbGap.sm(),
            const Expanded(
              child: Text(
                'Tomorrow may be 35% below normal. Avoid heavy loads after 6 PM.',
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _MetricsDemo extends StatelessWidget {
  const _MetricsDemo();

  @override
  Widget build(BuildContext context) {
    final muted = context.textTheme.bodySmall?.copyWith(
      color: context.colors.textMuted,
    );
    Widget valueUnit(String value, String unit, TextStyle style) => Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(value, style: style),
        const SizedBox(width: AppSpacing.xxs),
        Text(unit, style: muted),
      ],
    );
    final t = context.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        valueUnit('3h 28m', 'left', t.metricHero),
        valueUnit('420', 'W', t.metricLarge),
        valueUnit('1,85,000', 'PKR', t.metricMedium),
        valueUnit('+2h 10m', '', t.metricSmall),
        Text(
          'updated 3 h ago',
          style: t.metricCaption.copyWith(color: context.colors.textMuted),
        ),
      ],
    );
  }
}

class _TypeScale extends StatelessWidget {
  const _TypeScale();

  @override
  Widget build(BuildContext context) {
    final t = context.textTheme;
    final roles = {
      'displaySmall': t.displaySmall,
      'headlineMedium': t.headlineMedium,
      'headlineSmall': t.headlineSmall,
      'titleLarge': t.titleLarge,
      'titleMedium': t.titleMedium,
      'titleSmall': t.titleSmall,
      'bodyLarge': t.bodyLarge,
      'bodyMedium': t.bodyMedium,
      'bodySmall': t.bodySmall,
      'labelLarge': t.labelLarge,
      'labelMedium': t.labelMedium,
      'labelSmall': t.labelSmall,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final MapEntry(:key, :value) in roles.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text('$key · Light gayi', style: value),
          ),
      ],
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches(this.tokens);

  final Map<String, Color> tokens;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.md,
    runSpacing: AppSpacing.md,
    children: [
      for (final MapEntry(:key, :value) in tokens.entries)
        SizedBox(
          width: 104,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hairline so swatches matching the page stay visible.
              DecoratedBox(
                decoration: BoxDecoration(
                  color: value,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: context.colors.outlineVariant),
                ),
                child: const SizedBox(height: 48, width: double.infinity),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(key, style: context.textTheme.labelMedium),
              Text(
                _hex(value),
                style: context.text.metricCaption.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
            ],
          ),
        ),
    ],
  );

  static String _hex(Color c) =>
      '#${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
}

class _IconGrid extends StatelessWidget {
  const _IconGrid();

  static const _icons = {
    'home': BbIcons.home,
    'homeActive': BbIcons.homeActive,
    'loads': BbIcons.loads,
    'solar': BbIcons.solar,
    'battery': BbIcons.battery,
    'assistant': BbIcons.assistant,
    'ai': BbIcons.ai,
    'gridOn': BbIcons.gridOn,
    'gridOff': BbIcons.gridOff,
    'batteryLow': BbIcons.batteryLow,
    'batteryCharging': BbIcons.batteryCharging,
    'batteryWarning': BbIcons.batteryWarning,
    'solarPanel': BbIcons.solarPanel,
    'cloudy': BbIcons.cloudy,
    'countdown': BbIcons.countdown,
    'schedule': BbIcons.schedule,
    'estimator': BbIcons.estimator,
    'money': BbIcons.money,
    'shop': BbIcons.shop,
    'repair': BbIcons.repair,
    'location': BbIcons.location,
    'fan': BbIcons.fan,
    'light': BbIcons.light,
    'tv': BbIcons.tv,
    'router': BbIcons.router,
    'water': BbIcons.water,
    'iron': BbIcons.iron,
    'plug': BbIcons.plug,
    'offline': BbIcons.offline,
    'success': BbIcons.success,
    'warning': BbIcons.warning,
    'danger': BbIcons.danger,
    'info': BbIcons.info,
    'settings': BbIcons.settings,
  };

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.md,
    runSpacing: AppSpacing.md,
    children: [
      for (final MapEntry(:key, :value) in _icons.entries)
        SizedBox(
          width: 80,
          child: Column(
            children: [
              Icon(value, size: AppSizes.iconMd),
              const SizedBox(height: AppSpacing.xs),
              Text(
                key,
                style: context.textTheme.labelSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
    ],
  );
}

class _ElevationDemo extends StatelessWidget {
  const _ElevationDemo();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.lg,
      children: [
        for (final level in AppElevation.values)
          Container(
            width: 120,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: level == AppElevation.level0
                  ? context.colors.surfaceMuted
                  : level.index >= 2
                  ? context.colors.surfaceRaised
                  : context.colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: level.shadows(brightness),
            ),
            child: Text(level.name, style: context.textTheme.labelLarge),
          ),
      ],
    );
  }
}
