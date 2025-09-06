import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/prices_page.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/pages/prices/product_price_refresher.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

/// Card that displays buttons related to prices.
class PricesCard extends StatelessWidget {
  const PricesCard(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return buildProductSmoothCard(
      title: Text(appLocalizations.prices_generic_title),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.all(LARGE_SPACE),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
              child: _PricesCardViewButton(product),
            ),
            Padding(
              padding: const EdgeInsets.all(SMALL_SPACE),
              child: SmoothLargeButtonWithIcon(
                text: appLocalizations.prices_add_a_price,
                leadingIcon: const Icon(Icons.add),
                onPressed: () async => ProductPriceAddPage.showProductPage(
                  context: context,
                  product: PriceMetaProduct.product(product),
                  proofType: ProofType.priceTag,
                ),
              ),
            ),
          ],
        ),
      ),
      margin: const EdgeInsetsDirectional.only(
        start: SMALL_SPACE,
        end: SMALL_SPACE,
        top: VERY_LARGE_SPACE,
      ),
    );
  }
}

class PricesCounter extends StatefulWidget {
  const PricesCounter({required this.product, super.key, this.child});

  final Product product;
  final Widget Function(
    GetPricesModel model,
    ProductPriceRefresher productPriceRefresher,
  )?
  child;

  @override
  State<PricesCounter> createState() => _PricesCounterState();
}

class _PricesCounterState extends State<PricesCounter> {
  GetPricesModel? _model;
  ProductPriceRefresher? _productPriceRefresher;

  @override
  Widget build(BuildContext context) {
    _model ??= GetPricesModel.product(
      product: PriceMetaProduct.product(widget.product),
      context: context,
    );
    _productPriceRefresher ??= ProductPriceRefresher(
      model: _model!,
      userPreferences: context.read<UserPreferences>(),
      pricesResult: null,
      refreshDisplay: () {
        if (mounted) {
          setState(() {});
        }
      },
    );

    context.watch<LocalDatabase>();
    unawaited(_productPriceRefresher!.runIfNeeded());

    final int? total = _productPriceRefresher!.pricesResult?.total;
    return Badge(
      offset: Offset.zero,
      isLabelVisible: total != null,
      backgroundColor: context
          .extension<SmoothColorsThemeExtension>()
          .secondaryNormal,
      label: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: VERY_SMALL_SPACE,
          end: VERY_SMALL_SPACE,
          top: VERY_SMALL_SPACE,
          bottom: 6.0,
        ),
        child: Text(
          '$total',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: widget.child?.call(_model!, _productPriceRefresher!),
    );
  }
}

class _PricesCardViewButton extends StatelessWidget {
  const _PricesCardViewButton(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return PricesCounter(
      product: product,
      child:
          (GetPricesModel model, ProductPriceRefresher productPriceRefresher) =>
              SmoothLargeButtonWithIcon(
                text: appLocalizations.prices_view_prices,
                leadingIcon: const Icon(CupertinoIcons.tag_fill),
                onPressed: () async => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => PricesPage(
                      model,
                      pricesResult: productPriceRefresher.pricesResult,
                    ),
                  ),
                ),
              ),
    );
  }
}
