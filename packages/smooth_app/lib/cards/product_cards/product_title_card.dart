import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_base_card.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_image.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/gallery_view/product_image_gallery_view.dart';

class ProductTitleCard extends StatelessWidget {
  const ProductTitleCard(
    this.product,
    this.isSelectable, {
    this.heroTag,
    this.isPictureVisible = true,
    this.dense = false,
    this.onRemove,
  });

  final Product product;
  final bool dense;
  final bool isSelectable;
  final String? heroTag;
  final OnRemoveCallback? onRemove;
  final bool isPictureVisible;

  @override
  Widget build(BuildContext context) {
    final Widget trailing = _ProductTitleCardTrailing(selectable: isSelectable);

    final Size imageSize = Size.square(
      MediaQuery.sizeOf(context).width * (dense ? 0.22 : 0.25),
    );

    Widget child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: DefaultTextStyle.of(context).style.fontSize! * 2.0,
          ),
          child: _ProductTitleCardName(selectable: isSelectable, dense: dense),
        ),
        const SizedBox(height: SMALL_SPACE),
        _ProductTitleCardBrand(selectable: isSelectable, dense: dense),
        const SizedBox(height: 2.0),
        trailing,
      ],
    );

    if (isSelectable) {
      child = SelectionArea(child: child);
    }

    final List<Widget> children = <Widget>[
      Padding(
        padding: const EdgeInsetsDirectional.only(top: SMALL_SPACE),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (isPictureVisible)
                TooltipTheme(
                  data: TooltipThemeData(
                    verticalOffset: imageSize.width / 2,
                    preferBelow: true,
                  ),
                  child: ProductPicture.fromProduct(
                    product: product,
                    imageField: ImageField.FRONT,
                    fallbackUrl: product.imageFrontUrl,
                    allowAlternativeLanguage: true,
                    size: imageSize,
                    showObsoleteIcon: true,
                    imageFoundBorder: 1.0,
                    imageNotFoundBorder: 1.0,
                    heroTag: heroTag,
                    noImageBuilder: (_) => const PictureNotFound(),
                    onTap: !dense
                        ? () async => Navigator.push<void>(
                            context,
                            MaterialPageRoute<bool>(
                              builder: (BuildContext context) =>
                                  ProductImageGalleryView(product: product),
                            ),
                          )
                        : null,
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: SMALL_SPACE,
                    top: VERY_SMALL_SPACE,
                    bottom: VERY_SMALL_SPACE,
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    return Provider<Product>.value(
      value: product,
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _ProductTitleCardName extends StatelessWidget {
  const _ProductTitleCardName({required this.selectable, this.dense = false});

  final bool dense;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Product product = context.watch<Product>();

    final TextStyle? textStyle = Theme.of(context).textTheme.headlineMedium;

    return Text(
      getProductName(product, appLocalizations),
<<<<<<< HEAD
      style: dense ? textStyle : textStyle?.copyWith(fontSize: 18.0),
=======
      style: dense
          ? textStyle?.copyWith(fontWeight: FontWeight.bold)
          : textStyle?.copyWith(fontSize: 24.0, fontWeight: FontWeight.bold),
>>>>>>> 33fe57b5c (Primer commit)
      textAlign: TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _ProductTitleCardBrand extends StatelessWidget {
  const _ProductTitleCardBrand({required this.selectable, this.dense = false});

  final bool selectable;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Product product = context.watch<Product>();

    final String brands = getProductBrands(product, appLocalizations);

    return Text(
      brands,
      maxLines: dense ? 1 : 2,
      overflow: dense ? TextOverflow.ellipsis : null,
      style: Theme.of(context).textTheme.bodyMedium,
      textAlign: TextAlign.start,
    );
  }
}

class _ProductTitleCardTrailing extends StatelessWidget {
  const _ProductTitleCardTrailing({required this.selectable});

  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final Product product = context.watch<Product>();

    return Text(
      product.quantity ?? '',
      style: Theme.of(context).textTheme.bodyMedium,
      textAlign: TextAlign.end,
    );
  }
}
