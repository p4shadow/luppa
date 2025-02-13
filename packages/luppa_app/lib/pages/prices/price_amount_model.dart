import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:luppa_app/pages/prices/price_meta_product.dart';

/// Model for the price of a single product.
class PriceAmountModel {
  PriceAmountModel({
    required this.product,
  });

  final PriceMetaProduct product;

  bool _hasChanged = false;

  bool get hasChanged => _hasChanged;

  String _paidPrice = '';

  String get paidPrice => _paidPrice;

  set paidPrice(final String value) {
    _hasChanged = true;
    _paidPrice = value;
  }

  String _priceWithoutDiscount = '';

  String get priceWithoutDiscount => _priceWithoutDiscount;

  set priceWithoutDiscount(final String value) {
    _hasChanged = true;
    _priceWithoutDiscount = value;
  }

  late double _checkedPaidPrice;
  double? _checkedPriceWithoutDiscount;

  double get checkedPaidPrice => _checkedPaidPrice;

  double? get checkedPriceWithoutDiscount => _checkedPriceWithoutDiscount;

  bool _promo = false;

  bool get promo => _promo;

  set promo(final bool value) {
    _hasChanged = true;
    _promo = value;
  }

  static double? validateDouble(final String value) =>
      double.tryParse(value) ??
      double.tryParse(
        value.replaceAll(',', '.'),
      );

  String? checkParameters(final BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (product.barcode.isEmpty) {
      return appLocalizations.prices_amount_no_product;
    }
    _checkedPaidPrice = validateDouble(paidPrice)!;
    _checkedPriceWithoutDiscount = null;
    if (promo) {
      if (priceWithoutDiscount.isNotEmpty) {
        _checkedPriceWithoutDiscount = validateDouble(priceWithoutDiscount);
        if (_checkedPriceWithoutDiscount == null) {
          return appLocalizations.prices_amount_price_incorrect;
        }
      }
    }
    return null;
  }
}
