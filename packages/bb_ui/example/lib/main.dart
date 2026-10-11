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
          IconButton(
            tooltip: 'Switch theme',
            onPressed: onToggleTheme,
            icon: Icon(
              context.isDarkTheme ? BbIcons.themeLight : BbIcons.themeDark,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        children: [
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
