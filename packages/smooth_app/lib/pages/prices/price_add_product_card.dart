import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/prices/price_amount_model.dart';
import 'package:smooth_app/pages/prices/price_category_input_page.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/price_scan_page.dart';

/// Card where the user can input a price product: type the barcode or scan.
class PriceAddProductCard extends StatefulWidget {
  const PriceAddProductCard();

  @override
  State<PriceAddProductCard> createState() => _PriceAddProductCardState();
}

class _PriceAddProductCardState extends State<PriceAddProductCard> {
  static const TextInputType _textInputType = TextInputType.number;

  String? _latestScannedBarcode;

  // we create dummy focus nodes to focus on, when we need to unfocus.
  final List<FocusNode> _dummyFocusNodes = <FocusNode>[];

  @override
  void dispose() {
    for (final FocusNode focusNode in _dummyFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothCardWithRoundedHeader(
      title: appLocalizations.prices_add_an_item,
      leading: const Icon(Icons.add_circle_outlined),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: SMALL_SPACE,
        vertical: MEDIUM_SPACE,
      ),
      child: Column(
        children: <Widget>[
          SmoothLargeButtonWithIcon(
            text: appLocalizations.prices_barcode_reader_action,
            leadingIcon: const Icon(Icons.barcode_reader),
            onPressed: () async {
              final UserPreferences userPreferences =
                  context.read<UserPreferences>();
              final List<String>? barcodes =
                  await Navigator.of(context).push<List<String>>(
                MaterialPageRoute<List<String>>(
                  builder: (BuildContext context) => PriceScanPage(
                    latestScannedBarcode: _latestScannedBarcode,
                    isMultiProducts: userPreferences.getFlag(
                          UserPreferencesDevMode
                              .userPreferencesFlagPricesReceiptMultiSelection,
                        ) ??
                        false,
                  ),
                ),
              );
              if (barcodes == null || barcodes.isEmpty) {
                return;
              }
              _latestScannedBarcode = barcodes.last;
              if (!context.mounted) {
                return;
              }
              await _addBarcodesToList(barcodes, context);
            },
          ),
          SmoothLargeButtonWithIcon(
            text: appLocalizations.prices_barcode_enter,
            leadingIcon: const Icon(Icons.text_fields),
            onPressed: () async {
              final String? barcode = await _textInput(context);
              if (barcode == null) {
                return;
              }
              _latestScannedBarcode = null;
              if (!context.mounted) {
                return;
              }
              await _addBarcodesToList(<String>[barcode], context);
            },
          ),
          SmoothLargeButtonWithIcon(
            text: appLocalizations.prices_category_enter,
            leadingIcon: const Icon(Icons.restaurant),
            onPressed: () async {
              final PriceMetaProduct? priceMetaProduct =
                  await Navigator.push<PriceMetaProduct>(
                context,
                MaterialPageRoute<PriceMetaProduct>(
                  builder: (BuildContext context) =>
                      const PriceCategoryInputPage(),
                ),
              );
              if (priceMetaProduct == null) {
                return;
              }
              if (!context.mounted) {
                return;
              }
              _addCategoryToList(priceMetaProduct, context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addBarcodesToList(
    final List<String> barcodes,
    final BuildContext context,
  ) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final PriceModel priceModel = Provider.of<PriceModel>(
      context,
      listen: false,
    );

    bool barcodeAlreadyThere(final String barcode) {
      for (int i = 0; i < priceModel.length; i++) {
        final PriceAmountModel model = priceModel.elementAt(i);
        if (model.product.barcode == barcode) {
          return true;
        }
      }
      if (priceModel.existingPrices != null) {
        for (final Price price in priceModel.existingPrices!) {
          if (price.productCode == barcode) {
            return true;
          }
        }
      }
      return false;
    }

    final List<String> alreadyThere = <String>[];
    final List<String> notThere = <String>[];
    for (final String barcode in barcodes) {
      if (barcodeAlreadyThere(barcode)) {
        alreadyThere.add(barcode);
      } else {
        notThere.add(barcode);
      }
    }

    if (notThere.isNotEmpty) {
      for (final String barcode in notThere) {
        _addProductToList(
          priceModel,
          PriceMetaProduct.unknown(
            barcode,
            localDatabase,
            priceModel,
          ),
          context,
        );
      }
      priceModel.notifyListeners();
    }

    for (final String barcode in alreadyThere) {
      if (!context.mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (final BuildContext context) => SmoothAlertDialog(
          body: Text(appLocalizations.prices_barcode_already(barcode)),
          positiveAction: SmoothActionButton(
            text: appLocalizations.okay,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }
  }

  void _addCategoryToList(
    final PriceMetaProduct priceMetaProduct,
    final BuildContext context,
  ) {
    final PriceModel priceModel = Provider.of<PriceModel>(
      context,
      listen: false,
    );
    _addProductToList(
      priceModel,
      priceMetaProduct,
      context,
    );
    priceModel.notifyListeners();
  }

  void _addProductToList(
    final PriceModel priceModel,
    final PriceMetaProduct product,
    final BuildContext context,
  ) {
    priceModel.add(PriceAmountModel(product: product));

    // unfocus from the previous price amount text field.
    // looks like the most efficient way to unfocus: focus somewhere in space...
    final FocusNode focusNode = FocusNode();
    _dummyFocusNodes.add(focusNode);
    FocusScope.of(context).requestFocus(focusNode);
  }

  Future<String?> _textInput(final BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return showDialog<String>(
      context: context,
      builder: (final BuildContext context) => StatefulBuilder(
        builder: (
          final BuildContext context,
          void Function(VoidCallback fn) setState,
        ) =>
            SmoothAlertDialog(
          title: appLocalizations.prices_add_an_item,
          body: SmoothTextFormField(
            autofocus: true,
            type: TextFieldTypes.PLAIN_TEXT,
            controller: controller,
            hintText: appLocalizations.barcode,
            textInputType: _textInputType,
            onChanged: (_) {
              final String barcode = controller.text;
              final String cleanBarcode = _getCleanBarcode(barcode);
              setState(() => controller.text = cleanBarcode);
            },
            onFieldSubmitted: (_) => !_isValidBarcode(controller.text)
                ? null
                : Navigator.of(context).pop(controller.text),
          ),
          positiveAction: SmoothActionButton(
            text: appLocalizations.validate,
            onPressed: !_isValidBarcode(controller.text)
                ? null
                : () => Navigator.of(context).pop(controller.text),
          ),
          negativeAction: SmoothActionButton(
            text: appLocalizations.cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  bool _isValidBarcode(final String barcode) => barcode.length >= 8;

  // Probably there's a regexp for that, but at least it's readable code.
  String _getCleanBarcode(final String input) {
    const int ascii0 = 48;
    const int ascii9 = 48 + 10 - 1;

    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final int charCode = input.codeUnitAt(i);
      if (charCode >= ascii0 && charCode <= ascii9) {
        buffer.writeCharCode(charCode);
      }
    }
    return buffer.toString();
  }
}
