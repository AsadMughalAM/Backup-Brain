import 'package:flutter/material.dart';

/// LAYER 2 — energy meanings mapped onto the same three brand families plus
/// status colors (DESIGN.md §2.5). Read via `context.energy`.
@immutable
class EnergyColors extends ThemeExtension<EnergyColors> {
  const EnergyColors({
    required this.solar,
    required this.solarStroke,
    required this.solarText,
    required this.grid,
    required this.load,
    required this.batteryHigh,
    required this.batteryMid,
    required this.batteryLow,
    required this.offline,
  });

  /// Large fills only (ring arcs ≥ 8 px, areas, bars). In light mode always
  /// pair with [solarStroke] — the fill alone is 1.6:1 on white.
  final Color solar;

  /// Lines, thin marks, small icons.
  final Color solarStroke;

  /// Solar numbers such as "4.2 kWh".
  final Color solarText;

  /// WAPDA/DISCO grid power.
  final Color grid;

  /// Household consumption. Drawn dashed in charts to separate it from grid.
  final Color load;

  /// > 50%.
  final Color batteryHigh;

  /// 20–50%.
  final Color batteryMid;

  /// < 20%.
  final Color batteryLow;

  /// Grid down / offline, always with the `lightningSlash` icon.
  final Color offline;

  /// Status color for a state of charge given as a fraction 0–1. Always
  /// show it with a battery icon and the percentage.
  Color battery(double soc) => soc > 0.5
      ? batteryHigh
      : soc >= 0.2
      ? batteryMid
      : batteryLow;

  Map<String, Color> get tokens => {
    'solar': solar,
    'solarStroke': solarStroke,
    'solarText': solarText,
    'grid': grid,
    'load': load,
    'batteryHigh': batteryHigh,
    'batteryMid': batteryMid,
    'batteryLow': batteryLow,
    'offline': offline,
  };

  @override
  EnergyColors copyWith({
    Color? solar,
    Color? solarStroke,
    Color? solarText,
    Color? grid,
    Color? load,
    Color? batteryHigh,
    Color? batteryMid,
    Color? batteryLow,
    Color? offline,
  }) => EnergyColors(
    solar: solar ?? this.solar,
    solarStroke: solarStroke ?? this.solarStroke,
    solarText: solarText ?? this.solarText,
    grid: grid ?? this.grid,
    load: load ?? this.load,
    batteryHigh: batteryHigh ?? this.batteryHigh,
    batteryMid: batteryMid ?? this.batteryMid,
    batteryLow: batteryLow ?? this.batteryLow,
    offline: offline ?? this.offline,
  );

  @override
  EnergyColors lerp(EnergyColors? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return EnergyColors(
      solar: c(solar, other.solar),
      solarStroke: c(solarStroke, other.solarStroke),
      solarText: c(solarText, other.solarText),
      grid: c(grid, other.grid),
      load: c(load, other.load),
      batteryHigh: c(batteryHigh, other.batteryHigh),
      batteryMid: c(batteryMid, other.batteryMid),
      batteryLow: c(batteryLow, other.batteryLow),
      offline: c(offline, other.offline),
    );
  }
}
