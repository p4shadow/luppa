import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/num_utils.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/image/product_image_helper.dart';
import 'package:smooth_app/pages/product/edit_ocr/edit_ocr_page.dart';
import 'package:smooth_app/pages/product/edit_ocr/ocr_helper.dart';
import 'package:smooth_app/pages/product/helpers/pinch_to_zoom_indicator.dart';
import 'package:smooth_app/pages/product/owner_field_info.dart';
import 'package:smooth_app/resources/app_animations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_indicator_icon.dart';
import 'package:smooth_app/widgets/smooth_interactive_viewer.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

class EditOCRImageWidget extends StatefulWidget {
  const EditOCRImageWidget({
    required this.helper,
    required this.transientFile,
    required this.ownerField,
    required this.onTakePicture,
    required this.onTakePictureWithChoices,
    required this.onEditImage,
    required this.onExtractText,
  });

  final OcrHelper helper;
  final TransientFile transientFile;
  final bool ownerField;

  final VoidCallback onTakePicture;
  final VoidCallback onTakePictureWithChoices;
  final VoidCallback onEditImage;
  final VoidCallback onExtractText;

  @override
  State<EditOCRImageWidget> createState() => _EditOCRImageWidgetState();
}

class _EditOCRImageWidgetState extends State<EditOCRImageWidget> {
  bool _imageError = false;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final ImageProvider? imageProvider =
        widget.transientFile.getImageProvider();
    final bool hasImage = imageProvider != null;

    final Size screenSize = MediaQuery.sizeOf(context);
    final double height = screenSize.height;

    Widget child;
    Widget? headerIcons;

    /// If the ownerField icon is visible, we need to reduce the header size
    /// (this icon already contains the padding)
    bool reduceHeader = false;

    if (_imageError) {
      child = const ClipRRect(
        child: PictureNotFound.ink(
          backgroundDecoration: BoxDecoration(
            borderRadius: ROUNDED_BORDER_RADIUS,
          ),
          style: PictureNotFoundStyle.sad,
        ),
      );
    } else if (hasImage) {
      child = SizedBox(
        height: height,
        child: _EditOCRImageFound(
          imageProvider: imageProvider,
          onError: () {
            if (!_imageError) {
              onNextFrame(() => setState(() => _imageError = true));
            }
          },
        ),
      );

      if (widget.transientFile.expired) {
        headerIcons = Tooltip(
          message: appLocalizations.product_image_outdated_message,
          textAlign: TextAlign.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 40.0,
              minWidth: 40.0,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(VERY_SMALL_SPACE),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _openOutdatedPictureExplanations(context),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: extension.warning,
                      borderRadius: ROUNDED_BORDER_RADIUS,
                    ),
                    child: const Padding(
                      padding: EdgeInsetsDirectional.only(
                        top: 6.5,
                        bottom: 7.5,
                        start: 7.0,
                        end: 7.0,
                      ),
                      child: icons.Outdated(size: 15.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      if (widget.ownerField) {
        reduceHeader = true;

        if (headerIcons == null) {
          headerIcons = const OwnerFieldSmoothCardIcon();
        } else {
          headerIcons = Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const OwnerFieldSmoothCardIcon(),
              headerIcons,
            ],
          );
        }
      }
    } else {
      child = _EditOCRImageNotFound(
        onTap: widget.onTakePictureWithChoices,
      );
    }

    return SmoothCardWithRoundedHeader(
      title: widget.helper.getPhotoTitle(appLocalizations),
      leading: const icons.Camera.happy(),
      trailing: headerIcons,
      titlePadding: reduceHeader
          ? const EdgeInsetsDirectional.symmetric(
              vertical: 2.0,
              horizontal: LARGE_SPACE,
            )
          : null,
      contentPadding: EdgeInsets.zero,
      contentBackgroundColor: lightTheme ? extension.primaryBlack : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: double.infinity,
          maxWidth: double.infinity,
          minHeight: height * 0.3,
          maxHeight: height * 0.35,
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: ROUNDED_BORDER_RADIUS,
                child: child,
              ),
            ),
            _EditOCRImageActions(
              helper: widget.helper,
              hasImage: hasImage,
              hasError: _imageError,
              onTakePicture: widget.onTakePicture,
              onTakePictureWithChoices: widget.onTakePictureWithChoices,
              onEditImage: widget.onEditImage,
              onExtractText: widget.onExtractText,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openOutdatedPictureExplanations(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return showSmoothModalSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SmoothModalSheet(
          title: appLocalizations.product_image_outdated_explanations_title,
          prefixIndicator: true,
          body: SmoothModalSheetBodyContainer(
            child: TextWithBoldParts(
              text:
                  appLocalizations.product_image_outdated_explanations_content,
            ),
          ),
        );
      },
    );
  }
}

class _EditOCRImageFound extends StatefulWidget {
  const _EditOCRImageFound({
    required this.imageProvider,
    required this.onError,
  });

  final ImageProvider imageProvider;
  final VoidCallback onError;

  @override
  State<_EditOCRImageFound> createState() => _EditOCRImageFoundState();
}

class _EditOCRImageFoundState extends State<_EditOCRImageFound> {
  bool _isLoading = true;

  @override
  void didUpdateWidget(_EditOCRImageFound oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.imageProvider != widget.imageProvider) {
      _isLoading = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: ROUNDED_BORDER_RADIUS,
      child: Consumer<OcrState>(
        builder: (BuildContext context, OcrState state, _) {
          return Stack(
            children: <Widget>[
              Positioned.fill(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                  child: Image(
                    fit: BoxFit.cover,
                    image: widget.imageProvider,
                    opacity: AlwaysStoppedAnimation<double>(
                      context.lightTheme() ? 0.3 : 0.55,
                    ),
                    errorBuilder: _onError,
                  ),
                ),
              ),
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: state == OcrState.EXTRACTING_DATA,
                  child: SmoothInteractiveViewer(
                    interactionEndFrictionCoefficient: double.infinity,
                    minScale: 0.1,
                    maxScale: 5.0,
                    child: Image(
                      fit: BoxFit.contain,
                      image: widget.imageProvider,
                      frameBuilder: (
                        BuildContext context,
                        Widget child,
                        int? frame,
                        bool wasSynchronouslyLoaded,
                      ) {
                        if (frame == null) {
                          return _loadingWidget();
                        } else if (_isLoading) {
                          onNextFrame(
                            () => setState(() => _isLoading = false),
                          );
                        }
                        return child;
                      },
                      loadingBuilder: (
                        BuildContext context,
                        Widget child,
                        ImageChunkEvent? loadingProgress,
                      ) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return _loadingWidget();
                      },
                      errorBuilder: _onError,
                    ),
                  ),
                ),
              ),
              if (state == OcrState.IMAGE_LOADED && !_isLoading)
                const Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: PinchToZoomExplainer(),
                )
              else if (state == OcrState.IMAGE_LOADING)
                const Center(
                  child: CloudUploadAnimation.circle(size: 65.0),
                )
              else if (state == OcrState.EXTRACTING_DATA)
                Builder(builder: (BuildContext context) {
                  final SmoothColorsThemeExtension extension =
                      context.extension<SmoothColorsThemeExtension>();

                  return Positioned.fill(
                    child: _ExtractTextAnimation(
                      tintColor: extension.secondaryNormal,
                      tintColorGradient: extension.secondaryLight,
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  ColoredBox _loadingWidget() {
    return const ColoredBox(
      color: PictureNotFound.defaultBackgroundColor,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _onError(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    widget.onError.call();
    return EMPTY_WIDGET;
  }
}

class _EditOCRImageNotFound extends StatelessWidget {
  const _EditOCRImageNotFound({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: ROUNDED_BORDER_RADIUS,
      onTap: onTap,
      child: const Stack(
        children: <Widget>[
          Positioned.fill(
            child: PictureNotFound.ink(
              backgroundDecoration: BoxDecoration(
                borderRadius: ROUNDED_BORDER_RADIUS,
              ),
              style: PictureNotFoundStyle.add,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: ExcludeSemantics(
              child: SmoothIndicatorIcon(
                padding: EdgeInsetsDirectional.all(6.0),
                icon: Icon(Icons.more_vert_outlined, size: 19.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditOCRImageActions extends StatelessWidget {
  const _EditOCRImageActions({
    required this.helper,
    required this.hasImage,
    required this.hasError,
    required this.onTakePicture,
    required this.onTakePictureWithChoices,
    required this.onEditImage,
    required this.onExtractText,
  });

  final OcrHelper helper;
  final bool hasImage;
  final bool hasError;
  final VoidCallback onTakePicture;
  final VoidCallback onTakePictureWithChoices;
  final VoidCallback onEditImage;
  final VoidCallback onExtractText;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: BALANCED_SPACE,
        start: LARGE_SPACE,
        end: LARGE_SPACE,
        bottom: MEDIUM_SPACE,
      ),
      child: Consumer<OcrState>(
        builder: (BuildContext context, OcrState ocrState, _) {
          return Column(
            children: <Widget>[
              _extractTextButton(
                context,
                appLocalizations,
                ocrState,
                hasError,
              ),
              const SizedBox(height: BALANCED_SPACE),
              if (hasImage)
                _editPictureButton(appLocalizations, ocrState)
              else
                _takePictureButton(appLocalizations, ocrState),
            ],
          );
        },
      ),
    );
  }

  _EditOCRImageButton _extractTextButton(
    BuildContext context,
    AppLocalizations appLocalizations,
    OcrState state,
    bool hasError,
  ) {
    final VoidCallback? onTap;

    if (hasError) {
      onTap = null;
    } else if (!hasImage) {
      onTap = () => _onImageUnavailable(context);
    } else if (state == OcrState.IMAGE_LOADING) {
      onTap = () => _onImageUpload(context);
    } else {
      onTap = onExtractText;
    }

    return _EditOCRImageButton(
      label: helper.getActionExtractShortText(appLocalizations),
      icon: const icons.OCR(
        size: 18.0,
      ),
      onPressed: onTap,
      enabled: hasImage && state == OcrState.IMAGE_LOADED && !hasError,
    );
  }

  _EditOCRImageButton _editPictureButton(
    AppLocalizations appLocalizations,
    OcrState state,
  ) {
    return _EditOCRImageButton(
      label: appLocalizations.product_edit_photo_title,
      icon: const icons.Edit(
        size: 16.0,
      ),
      onPressed: state != OcrState.EXTRACTING_DATA ? onEditImage : null,
    );
  }

  _EditOCRImageButton _takePictureButton(
    AppLocalizations appLocalizations,
    OcrState state,
  ) {
    return _EditOCRImageButton(
      label: appLocalizations.edit_product_action_take_picture,
      icon: const Icon(
        Icons.add_a_photo_rounded,
        size: 18.0,
      ),
      padding: const EdgeInsetsDirectional.only(
        start: VERY_SMALL_SPACE,
        end: 6.0,
        top: SMALL_SPACE,
        bottom: SMALL_SPACE,
      ),
      onPressed: state != OcrState.EXTRACTING_DATA ? onTakePicture : null,
    );
  }

  Future<void> _onImageUnavailable(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return showSmoothModalSheet(
      context: context,
      builder: (BuildContext context) {
        return SmoothModalSheet(
          title: appLocalizations.edit_ocr_extract_disabled_title,
          body: SmoothModalSheetBodyContainer(
            child: Text(appLocalizations.edit_ocr_extract_disabled_message),
          ),
        );
      },
    );
  }

  Future<void> _onImageUpload(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return showSmoothModalSheet(
      context: context,
      builder: (BuildContext context) {
        return SmoothModalSheet(
          title: helper.getActionLoadingPhotoDialogTitle(appLocalizations),
          body: SmoothModalSheetBodyContainer(
            child: Text(
              helper.getActionLoadingPhotoDialogBody(appLocalizations),
            ),
          ),
        );
      },
    );
  }
}

class _EditOCRImageButton extends StatelessWidget {
  const _EditOCRImageButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.enabled = true,
    this.padding,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool enabled;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final Color color =
        (onPressed != null && enabled) ? Colors.white : const Color(0x88FFFFFF);

    return Ink(
      decoration: BoxDecoration(
        borderRadius: ROUNDED_BORDER_RADIUS,
        border: Border.all(
          color: color,
          width: 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: ROUNDED_BORDER_RADIUS,
        onTap: onPressed,
        child: IconTheme(
          data: IconThemeData(
            color: SmoothCardWithRoundedHeaderTop.getHeaderColor(context),
          ),
          child: Row(
            children: <Widget>[
              SizedBox.square(
                dimension: 34.0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: padding ??
                        const EdgeInsetsDirectional.all(
                          SMALL_SPACE,
                        ),
                    child: icon,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: MEDIUM_SPACE,
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 1.5),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExtractTextAnimation extends StatefulWidget {
  const _ExtractTextAnimation({
    required this.tintColor,
    required this.tintColorGradient,
  });

  final Color tintColor;
  final Color tintColorGradient;

  @override
  State<_ExtractTextAnimation> createState() => _ExtractTextAnimationState();
}

class _ExtractTextAnimationState extends State<_ExtractTextAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _controller
      ..addListener(() => setState(() {}))
      ..addStatusListener((AnimationStatus status) {
        if (_controller.isCompleted) {
          _controller.reverse();
        }
        if (_controller.isDismissed) {
          _controller.forward();
        }
      })
      ..repeat();

    _progress = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeInOutCubic))
        .animate(_controller);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _progress.value;

    return CustomPaint(
      painter: _ExtractTextAnimationPainter(
        progress: progress,
        lineColor: widget.tintColor.withValues(
          alpha: progress.progressAndClamp(0.0, 0.8, 1.0),
        ),
        gradient: LinearGradient(
          colors: <Color>[
            Colors.transparent,
            widget.tintColorGradient.withValues(
              alpha: progress,
            ),
          ],
          stops: const <double>[0.4, 1.0],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ExtractTextAnimationPainter extends CustomPainter {
  _ExtractTextAnimationPainter({
    required this.progress,
    required this.gradient,
    required this.lineColor,
  });

  final double progress;
  final LinearGradient gradient;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width * progress;

    final Paint paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0.0, 0.0, width, size.height),
      );

    final Rect rect = Rect.fromLTWH(0.0, 0.0, width, size.height);
    canvas.drawRect(rect, paint);

    paint
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..shader = null;

    canvas.drawLine(
      Offset(width, 0),
      Offset(width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ExtractTextAnimationPainter oldDelegate) =>
      oldDelegate.progress != progress;

  @override
  bool shouldRebuildSemantics(_ExtractTextAnimationPainter oldDelegate) =>
      false;
}
