/// An appliance the user added in setup because the list didn't have it,
/// or had it at other watts ("Tube light, 40 W" next to the LED bulbs).
class CustomAppliance {
  const CustomAppliance({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.watts,
    required this.quantity,
    required this.heavy,
  });

  /// Saved appliances with this id prefix came from here, so "Edit my home"
  /// lists them as added ones instead of counting them into a preset.
  static const idPrefix = 'custom-';

  static bool isCustomId(String id) => id.startsWith(idPrefix);

  final String id;
  final String name;

  /// A preset's icon key ("light") or "plug" for anything else.
  final String iconKey;
  final double watts;
  final int quantity;

  /// Draws a lot of power: saved switched off, listed with the heavy ones.
  final bool heavy;

  CustomAppliance copyWith({int? quantity}) => CustomAppliance(
    id: id,
    name: name,
    iconKey: iconKey,
    watts: watts,
    quantity: quantity ?? this.quantity,
    heavy: heavy,
  );
}
