import 'package:bb_ui/bb_ui.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/services/external_links.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/nearby_shops_repository.dart';

/// F7 "Find help nearby". With a map key and a home location, real shops
/// load as soon as the screen opens and one tap gives directions; without
/// them, Google Maps searches open instead.
class NearbyShopsSection extends ConsumerStatefulWidget {
  const NearbyShopsSection({
    super.key,
    required this.city,
    required this.area,
    required this.site,
    required this.suggested,
  });

  final String? city;

  /// Neighbourhood ("Johar Town"): shops are searched around it.
  final String? area;
  final SiteLocation? site;

  /// Picked from the diagnosis until the user chooses another kind.
  final ShopKind suggested;

  @override
  ConsumerState<NearbyShopsSection> createState() => _NearbyShopsSectionState();
}

class _NearbyShopsSectionState extends ConsumerState<NearbyShopsSection> {
  ShopKind? _picked;
  var _linkFailed = false;

  Future<void> _open(Future<bool> Function(ExternalLinks) open) async {
    var opened = false;
    try {
      opened = await open(ref.read(externalLinksProvider));
    } on Exception catch (e) {
      debugPrint('Opening Google Maps failed: $e');
    }
    if (mounted) setState(() => _linkFailed = !opened);
  }

  /// "Johar Town, Lahore", or just the city.
  String? get _place {
    final parts = [
      widget.area,
      widget.city,
    ].nonNulls.map((p) => p.trim()).where((p) => p.isNotEmpty);
    return parts.isEmpty ? null : parts.join(', ');
  }

  void _searchMaps(String query) {
    final place = _place;
    _open(
      (links) => links.openMapsSearch(
        place == null ? query : '$query ${place.replaceAll(',', '')}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final city = widget.city;
    final site = widget.site;
    final live =
        site != null &&
        city != null &&
        ref.watch(nearbyShopsRepositoryProvider) != null;
    final kind = _picked ?? widget.suggested;
    final kinds = [
      (ShopKind.battery, l10n.nearbyBatteryShops, l10n.queryBatteryShop),
      (ShopKind.upsRepair, l10n.nearbyUpsRepair, l10n.queryUpsRepair),
      (
        ShopKind.solarInstaller,
        l10n.nearbySolarInstallers,
        l10n.querySolarInstaller,
      ),
    ];
    final mapsQuery = kinds.firstWhere((k) => k.$1 == kind).$3;
    final muted = context.textTheme.bodyMedium?.copyWith(
      color: context.colors.textMuted,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.nearbyTitle, style: context.textTheme.titleMedium),
        const BbGap.xs(),
        Text(switch (_place) {
          final c? when live => l10n.nearbyLiveBody(c),
          final c? => l10n.nearbyBody(c),
          null => l10n.nearbyBodyNoCity,
        }, style: muted),
        const BbGap.md(),
        if (!live)
          for (final (_, label, query) in kinds) ...[
            BbButton.secondary(
              label: label,
              icon: BbIcons.location,
              expand: true,
              onPressed: () => _searchMaps(query),
            ),
            const BbGap.sm(),
          ]
        else ...[
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (k, label, _) in kinds)
                BbChip(
                  label: label,
                  selected: k == kind,
                  onSelected: () => setState(() => _picked = k),
                ),
            ],
          ),
          const BbGap.md(),
          _Results(
            query: (
              kind: kind,
              lat: site.lat,
              lon: site.lon,
              area: widget.area,
            ),
            onDirections: (shop) => _open(
              (links) => links.openDirections(shop.site.lat, shop.site.lon),
            ),
          ),
          const BbGap.sm(),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: BbButton.ghost(
              label: l10n.nearbyMoreOnMaps,
              icon: BbIcons.location,
              onPressed: () => _searchMaps(mapsQuery),
            ),
          ),
        ],
        if (_linkFailed) ...[
          const BbGap.xs(),
          Row(
            children: [
              Icon(
                BbIcons.warning,
                size: AppSizes.iconXs,
                color: context.colors.textMuted,
              ),
              const BbGap.xs(),
              Expanded(child: Text(l10n.mapsOpenFailed, style: muted)),
            ],
          ),
        ],
      ],
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.query, required this.onDirections});

  final ShopQuery query;
  final ValueChanged<NearbyShop> onDirections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final muted = context.textTheme.bodyMedium?.copyWith(
      color: context.colors.textMuted,
    );
    return switch (ref.watch(nearbyShopsProvider(query))) {
      AsyncData(value: final shops) when shops.isEmpty => Text(
        l10n.nearbyNoneFound,
        style: muted,
      ),
      AsyncData(value: final shops) => BbCard.list(
        children: [
          for (final shop in shops)
            _ShopRow(shop: shop, onDirections: () => onDirections(shop)),
        ],
      ),
      AsyncError() => BbEmptyState(
        icon: BbIcons.offline,
        title: l10n.nearbyFailedTitle,
        message: l10n.errorNetwork,
        action: BbButton.secondary(
          label: l10n.tryAgain,
          onPressed: () => ref.invalidate(nearbyShopsProvider(query)),
        ),
      ),
      _ => Row(
        children: [
          IconTheme.merge(
            data: IconThemeData(color: context.colors.textMuted),
            child: const BbSpinner(size: BbSpinnerSize.xs),
          ),
          const BbGap.sm(),
          Text(l10n.nearbyFinding, style: muted),
        ],
      ),
    };
  }
}

class _ShopRow extends StatelessWidget {
  const _ShopRow({required this.shop, required this.onDirections});

  final NearbyShop shop;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shop.name, style: context.textTheme.bodyLarge),
                Text(
                  [
                    Formatters.distance(shop.distanceMeters),
                    if (shop.address.isNotEmpty) shop.address,
                  ].join(' · '),
                  // Map addresses can run long (plus code, postcode, country).
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const BbGap.sm(),
          BbButton.secondary(
            label: l10n.nearbyDirections,
            size: BbButtonSize.sm,
            onPressed: onDirections,
          ),
        ],
      ),
    );
  }
}
