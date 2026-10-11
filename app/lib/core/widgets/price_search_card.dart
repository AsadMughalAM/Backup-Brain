import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_localizations.dart';
import '../services/external_links.dart';
import '../utils/fire_and_forget.dart';

/// One product the user can look up, e.g. ("Inverter", "6kW hybrid
/// inverter").
typedef PriceProduct = ({String label, String query});

/// "Check today's prices online": pick a product, open live listings on
/// Google, Daraz or OLX. Shared by the F5 estimator and F7 battery help.
/// The app's own estimates keep using the reviewed price files; these
/// listings are for the user's eyes only (golden rule 1).
class PriceSearchCard extends ConsumerStatefulWidget {
  const PriceSearchCard({super.key, required this.products, this.city});

  final List<PriceProduct> products;

  /// Narrows the Google search; Daraz and OLX use their own location.
  final String? city;

  @override
  ConsumerState<PriceSearchCard> createState() => _PriceSearchCardState();
}

class _PriceSearchCardState extends ConsumerState<PriceSearchCard> {
  var _selected = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (widget.products.isEmpty) return const SizedBox.shrink();
    final product =
        widget.products[_selected.clamp(0, widget.products.length - 1)];
    final city = widget.city;
    void open(PriceSite site) => fireAndForget(
      ref
          .read(externalLinksProvider)
          .openPriceSearch(
            site,
            site == PriceSite.google
                ? l10n.priceQueryGoogle(product.query, city ?? l10n.pakistan)
                : product.query,
          ),
      'price search',
    );

    return BbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.pricesOnlineTitle, style: context.textTheme.titleMedium),
          const BbGap.xs(),
          Text(
            l10n.pricesOnlineBody,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.textMuted,
            ),
          ),
          const BbGap.md(),
          if (widget.products.length > 1) ...[
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final (i, p) in widget.products.indexed)
                  BbChip(
                    label: p.label,
                    selected: i == _selected,
                    onSelected: () => setState(() => _selected = i),
                  ),
              ],
            ),
            const BbGap.md(),
          ],
          Text(
            l10n.pricesOnlineSearching(product.query),
            style: context.textTheme.bodyMedium,
          ),
          const BbGap.sm(),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (site, label) in [
                (PriceSite.google, l10n.priceSiteGoogle),
                (PriceSite.daraz, l10n.priceSiteDaraz),
                (PriceSite.olx, l10n.priceSiteOlx),
              ])
                BbButton.secondary(
                  label: label,
                  icon: BbIcons.shop,
                  size: BbButtonSize.sm,
                  onPressed: () => open(site),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
