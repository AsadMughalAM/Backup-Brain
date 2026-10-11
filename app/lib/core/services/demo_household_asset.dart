import 'dart:convert';

import 'package:flutter/services.dart';

/// The bundled demo household (ARCHITECTURE.md §12) — Demo Mode data, kept
/// in JSON so wattages and battery specs stay out of code.
typedef DemoHouseholdLoader = Future<Map<String, dynamic>> Function();

Future<Map<String, dynamic>> loadDemoHouseholdAsset() async =>
    json.decode(await rootBundle.loadString('assets/data/demo_household.json'))
        as Map<String, dynamic>;
