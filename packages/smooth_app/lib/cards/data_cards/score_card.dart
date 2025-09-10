import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/svg_icon_chip.dart';
import 'package:smooth_app/helpers/score_card_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
//import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

enum CardEvaluation {
  UNKNOWN(backgroundColor: GREY_COLOR, textColor: PRIMARY_GREY_COLOR),
  VERY_BAD(backgroundColor: RED_BACKGROUND_COLOR, textColor: RED_COLOR),
  BAD(backgroundColor: ORANGE_BACKGROUND_COLOR, textColor: LIGHT_ORANGE_COLOR),
  NEUTRAL(
    backgroundColor: YELLOW_BACKGROUND_COLOR,
    textColor: DARK_YELLOW_COLOR,
  ),
  GOOD(
    backgroundColor: LIGHT_GREEN_BACKGROUND_COLOR,
    textColor: LIGHT_GREEN_COLOR,
  ),
  VERY_GOOD(
    backgroundColor: DARK_GREEN_BACKGROUND_COLOR,
    textColor: DARK_GREEN_COLOR,
  );

  const CardEvaluation({
    required this.backgroundColor,
    required this.textColor,
  });

  final Color backgroundColor;
  final Color textColor;
}

class ScoreCard extends StatelessWidget {
  ScoreCard.attribute({
    required this.attribute,
    required this.isClickable,
    this.margin,
    this.onTap,
  }) : type = ScoreCardType.attribute,
       iconUrl = attribute?.iconUrl,
       description =
           attribute?.descriptionShort ?? attribute?.description ?? '',
       cardEvaluation = attribute != null
           ? getCardEvaluationFromAttribute(attribute)
           : CardEvaluation.UNKNOWN;

  ScoreCard.titleElement({
    required TitleElement titleElement,
    required this.isClickable,
    this.margin,
    this.onTap,
  }) : type = ScoreCardType.title,
       attribute = null,
       iconUrl = titleElement.iconUrl,
       description = titleElement.title,
       cardEvaluation = getCardEvaluationFromKnowledgePanelTitleElement(
         titleElement,
       );

  final Attribute? attribute;
  final String? iconUrl;
  final String description;
  final CardEvaluation cardEvaluation;
  final bool isClickable;
  final EdgeInsetsGeometry? margin;
  final ScoreCardType type;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final double iconHeight = IconWidgetSizer.getIconSizeFromContext(context);
    final ThemeData themeData = Theme.of(context);
    final double opacity = themeData.brightness == Brightness.light
        ? 1
        : SmoothTheme.ADDITIONAL_OPACITY_FOR_DARK;
    final Color backgroundColor = cardEvaluation.backgroundColor.withValues(
      alpha: opacity,
    );
    final SvgIconChip? iconChip = iconUrl == null
        ? null
        : SvgIconChip(iconUrl!, height: iconHeight);

    return Semantics(
      value: _generateSemanticsValue(context),
      excludeSemantics: true,
      header: type == ScoreCardType.title,
      button: isClickable,
      child: InkWell(
        onTap: onTap,
        borderRadius: ANGULAR_BORDER_RADIUS,
        child: Padding(
          padding: margin ?? const EdgeInsets.symmetric(vertical: SMALL_SPACE),
          child: Ink(
            padding: const EdgeInsets.all(SMALL_SPACE),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: ANGULAR_BORDER_RADIUS,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (iconChip != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: SMALL_SPACE),
                    child: iconChip,
                  ),
                //if (attribute?.id == Attribute.ATTRIBUTE_NOVA)
                // Flexible(
                //   child: Text(
                //     'Producto procesado',
                //     style: themeData.textTheme.headlineMedium!.apply(
                //       color: cardEvaluation.textColor,
                //     ),
                //     textAlign: TextAlign.center,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _generateSemanticsValue(BuildContext context) {
    if (type == ScoreCardType.title) {
      return description;
    }

    final String? iconLabel = SvgCache.getSemanticsLabel(context, iconUrl!);

    if (iconLabel == null) {
      return description;
    } else {
      return '$iconLabel: $description';
    }
  }
}

enum ScoreCardType { title, attribute }
