import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:luppa_app/helpers/product_cards_helper.dart';
import 'package:luppa_app/pages/product/product_field_editor.dart';

/// "Add (new) packaging" button for user contribution.
class AddPackagingButton extends StatelessWidget {
  AddPackagingButton({
    required this.product,
  });

  final Product product;

  final ProductFieldEditor _editor = ProductFieldPackagingEditor();

  @override
  Widget build(BuildContext context) => addPanelButton(
        _editor.getLabel(AppLocalizations.of(context)),
        onPressed: () async => _editor.edit(
          context: context,
          product: product,
          isLoggedInMandatory: true,
        ),
      );
}
