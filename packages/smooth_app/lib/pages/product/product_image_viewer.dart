import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_image.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/resources/app_animations.dart';

/// Displays a full-screen image with an "edit" floating button.
class ProductImageViewer extends StatefulWidget {
  const ProductImageViewer({
    required this.product,
    required this.imageField,
    required this.language,
    required this.isInitialImageViewed,
  });

  final Product product;
  final ImageField imageField;
  final OpenFoodFactsLanguage language;

  /// If the image is opened from the gallery: is this image selected?
  /// If true, the Hero animation will be enabled only on this picture
  /// (otherwise, multiple Hero animations may start)
  final bool isInitialImageViewed;

  @override
  State<ProductImageViewer> createState() => _ProductImageViewerState();
}

class _ProductImageViewerState extends State<ProductImageViewer>
    with UpToDateMixin {
  late ProductImageData _imageData;

  @override
  void initState() {
    super.initState();
    initUpToDate(widget.product, context.read<LocalDatabase>());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    refreshUpToDate();
    _imageData = getProductImageData(
      upToDateProduct,
      widget.imageField,
      widget.language,
    );
    final TransientFile transientFile = _getTransientFile();
    final ImageProvider? imageProvider = transientFile.getImageProvider();
    final bool isLoading =
        transientFile.isImageAvailable() && !transientFile.isServerImage();
    final Iterable<OpenFoodFactsLanguage> selectedLanguages =
        getProductImageLanguages(upToDateProduct, widget.imageField);

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(MINIMUM_TOUCH_SIZE / 2),
              child: imageProvider == null
                  ? Stack(
                      children: <Widget>[
                        const Positioned.fill(
                          child: ExcludeSemantics(child: PictureNotFound()),
                        ),
                        Align(
                          alignment: const Alignment(0.0, -0.8),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: ROUNDED_BORDER_RADIUS,
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: LARGE_SPACE,
                                vertical: SMALL_SPACE,
                              ),
                              child: Text(
                                selectedLanguages.isEmpty
                                    ? appLocalizations.edit_photo_language_none
                                    : appLocalizations
                                          .edit_photo_language_not_this_one,
                                style:
                                    Theme.of(context).textTheme.headlineMedium
                                        ?.copyWith(color: Colors.black) ??
                                    const TextStyle(color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox.expand(
                      child: Stack(
                        children: <Widget>[
                          Positioned.fill(
                            child: AnimatedOpacity(
                              opacity: isLoading ? 0.5 : 1.0,
                              duration: SmoothAnimationsDuration.short,
                              child: PhotoView(
                                minScale: 0.2,
                                imageProvider: imageProvider,
                                heroAttributes: widget.isInitialImageViewed
                                    ? PhotoViewHeroAttributes(
                                        tag: ProductPicture.generateHeroTag(
                                          barcode,
                                          widget.imageField,
                                        ),
                                        flightShuttleBuilder:
                                            (
                                              _,
                                              Animation<double> animation,
                                              HeroFlightDirection
                                              flightDirection,
                                              BuildContext fromHeroContext,
                                              BuildContext toHeroContext,
                                            ) {
                                              return AnimatedBuilder(
                                                animation: animation,
                                                builder: (_, _) {
                                                  Widget widget;
                                                  if (flightDirection ==
                                                      HeroFlightDirection
                                                          .push) {
                                                    widget =
                                                        fromHeroContext.widget;
                                                  } else {
                                                    widget =
                                                        toHeroContext.widget;
                                                  }

                                                  return ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          1 - animation.value,
                                                        ) *
                                                        ROUNDED_RADIUS.x,
                                                    child: widget,
                                                  );
                                                },
                                              );
                                            },
                                      )
                                    : null,
                                backgroundDecoration: const BoxDecoration(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          if (isLoading)
                            Center(
                              child: CloudUploadAnimation.circle(
                                size:
                                    MediaQuery.sizeOf(context).longestSide *
                                    0.2,
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  TransientFile _getTransientFile() =>
      TransientFile.fromProductImageData(_imageData, barcode, widget.language);
}
