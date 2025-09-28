import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_base_card.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/scan/carousel/scan_carousel.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/widgets/text/text_highlighter.dart';

class ScanProductCardNotFound extends StatelessWidget {
  ScanProductCardNotFound({required this.barcode, this.onRemoveProduct})
    : assert(barcode.isNotEmpty);

  final String barcode;
  final OnRemoveCallback? onRemoveProduct;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();
    final bool dense = context.read<ScanCardDensity>() == ScanCardDensity.DENSE;

    return ScanProductBaseCard(
      headerLabel: appLocalizations.carousel_unknown_product_header,
      headerIndicatorColor: theme.error,
      onRemove: onRemoveProduct,
      backgroundChild: Container(),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Widget spacer;

          if (dense) {
            spacer = const SizedBox(height: MEDIUM_SPACE);
          } else {
            spacer = const Spacer();
          }

          final Widget child = Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ScanProductBaseCardTitle(
                title: appLocalizations.carousel_unknown_product_title,
                padding: EdgeInsetsDirectional.only(
                  top: dense ? 0.0 : 5.0,
                  end: 25.0,
                ),
              ),
              SizedBox(height: dense ? BALANCED_SPACE : LARGE_SPACE),
              ScanProductBaseCardText(
                text: Text(appLocalizations.carousel_unknown_product_text),
              ),
              spacer,
              SmoothSimpleButton(
                child: Text(appLocalizations.carousel_unknown_product_button),
                onPressed: () async {
                  final bool? result = await AppNavigator.of(
                    context,
                  ).push(AppRoutes.NEW_PRODUCT_SUBMISSION);
                  if (result == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          appLocalizations.new_product_submission_success,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          );

          if (dense) {
            return SingleChildScrollView(child: InkWell(child: child));
          } else {
            return child;
          }
        },
      ),
    );
  }
}
