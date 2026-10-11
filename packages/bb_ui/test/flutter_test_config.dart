import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the real fonts (Geist, Geist Mono, Phosphor) before any test, so
/// goldens show actual glyphs instead of flutter_test's placeholder boxes.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadFonts();
  await testMain();
}

Future<void> _loadFonts() async {
  final manifest =
      json.decode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final family = entry['family'] as String;
    final assets = [
      for (final f in (entry['fonts'] as List).cast<Map<String, dynamic>>())
        f['asset'] as String,
    ];
    // bb_ui's own fonts are listed without the package prefix here, but
    // styles reference them as `packages/bb_ui/<family>`.
    final names = family.startsWith('packages/')
        ? [family]
        : [family, 'packages/bb_ui/$family'];
    for (final name in names) {
      final loader = FontLoader(name);
      for (final asset in assets) {
        loader.addFont(rootBundle.load(asset));
      }
      await loader.load();
    }
  }
}
