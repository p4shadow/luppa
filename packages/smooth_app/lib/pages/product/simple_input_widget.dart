import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_boolean_button.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_icon_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/helpers/collections_helper.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/pages/hunger_games/question_image_full_page.dart';
import 'package:smooth_app/pages/product/owner_field_info.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/pages/product/simple_input_text_field.dart';
import 'package:smooth_app/pages/text_field_helper.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_explanation_banner.dart';

/// Simple input widget: we have a list of terms, we add, we remove.
class SimpleInputWidget extends StatefulWidget {
  const SimpleInputWidget({
    required this.helper,
    required this.product,
    required this.controller,
    required this.displayTitle,
    this.newElementsToTop = true,
  });

  final AbstractSimpleInputPageHelper helper;
  final Product product;
  final TextEditingController controller;
  final bool displayTitle;
  final bool newElementsToTop;

  @override
  State<SimpleInputWidget> createState() => _SimpleInputWidgetState();
}

class _SimpleInputWidgetState extends State<SimpleInputWidget>
    with AutomaticKeepAliveClientMixin {
  late final FocusNode _focusNode;

  /// In order to add new items to the top of the list, we have our custom copy
  /// Because the [AbstractSimpleInputPageHelper] always add new items to the
  /// bottom of the list.
  late final List<String> _localTerms;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final Key _autocompleteKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    widget.helper.reInit(widget.product);
    _localTerms = List<String>.of(widget.helper.terms);

    widget.helper.loadRobotoffQuestions();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final Widget? extraWidget = widget.helper.getExtraWidget(
      context,
      widget.product,
    );

    final Widget child = MultiProvider(
      providers: <ChangeNotifierProvider<dynamic>>[
        ChangeNotifierProvider<ValueNotifier<SimpleInputSuggestionsState>>(
          create: (_) => widget.helper.getSuggestions(),
        ),
        ChangeNotifierProvider<
            ValueNotifier<Map<RobotoffQuestion, InsightAnnotation?>>>(
          create: (_) => widget.helper.getRobotoffQuestions(),
        ),
      ],
      builder: (BuildContext context, Widget? child) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          LayoutBuilder(
            builder: (_, BoxConstraints constraints) {
              return Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: SMALL_SPACE,
                  end: 4.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: SimpleInputTextField(
                        autocompleteKey: _autocompleteKey,
                        focusNode: _focusNode,
                        constraints: constraints,
                        tagType: widget.helper.getTagType(),
                        autocompleteManager:
                            widget.helper.getAutocompleteManager(),
                        textCapitalization:
                            widget.helper.getTextCapitalization(),
                        allowEmojis: widget.helper.getAllowEmojis(),
                        hintText: widget.helper.getAddHint(appLocalizations),
                        controller: widget.controller,
                        padding: const EdgeInsets.symmetric(
                          horizontal: LARGE_SPACE,
                          vertical: MEDIUM_SPACE,
                        ),
                        margin: const EdgeInsetsDirectional.only(
                          start: 3.0,
                        ),
                        productType: widget.product.productType,
                        borderRadius: CIRCULAR_BORDER_RADIUS,
                      ),
                    ),
                    Tooltip(
                      message: widget.helper.getAddTooltip(appLocalizations),
                      child: IconButton(
                        onPressed: _onAddItem,
                        splashRadius: 20.0,
                        icon: ListenableBuilder(
                          listenable: widget.controller,
                          builder: (
                            BuildContext context,
                            _,
                          ) =>
                              Icon(
                            Icons.add_circle,
                            color: IconTheme.of(context).color?.withValues(
                                  alpha: widget.controller.text.isEmpty
                                      ? 0.7
                                      : 1.0,
                                ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
          _getRobotoffList(context, appLocalizations),
          _getList(appLocalizations),
          if (extraWidget != null)
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: _localTerms.isEmpty ? SMALL_SPACE : 0.0,
              ),
              child: extraWidget,
            )
          else if (_localTerms.isEmpty)
            const SizedBox(height: MEDIUM_SPACE)
          else
            const SizedBox(height: VERY_SMALL_SPACE),
        ],
      ),
    );

    final Widget? trailingHeader = _getTrailingHeader(
      widget.helper.getAddExplanationsTitle(appLocalizations),
      widget.helper.getAddExplanationsContent(),
      appLocalizations,
    );

    return Column(
      children: <Widget>[
        SmoothCardWithRoundedHeader(
          leading: widget.helper.getIcon(),
          title: widget.helper.getTitle(appLocalizations),
          trailing: trailingHeader,
          contentPadding: const EdgeInsetsDirectional.only(
            top: BALANCED_SPACE,
          ),
          child: child,
        ),
        const SizedBox(height: MEDIUM_SPACE),
      ],
    );
  }

  Widget? _getTrailingHeader(
    String? title,
    WidgetBuilder? explanationsBuilder,
    AppLocalizations appLocalizations,
  ) {
    if (!widget.displayTitle) {
      return null;
    }

    final Widget? explanations = explanationsBuilder?.call(context);

    final List<Widget> children = <Widget>[
      if (widget.helper.isOwnerField(widget.product))
        const OwnerFieldSmoothCardIcon(),
      if (explanations != null)
        ExplanationTitleIcon(
          title: title ?? widget.helper.getTitle(appLocalizations),
          safeArea: explanations is! ExplanationBodyInfo,
          child: explanations,
        ),
    ];

    if (children.isEmpty) {
      return null;
    } else if (children.length == 1) {
      return children.first;
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }
  }

  Widget _getList(AppLocalizations appLocalizations) {
    if (!widget.helper.reorderable) {
      return Column(
        children: <Widget>[
          _SimpleInputListSuggestions(
            (String suggestion) {
              widget.controller.text = suggestion;
              _onAddItem();
            },
          ),
          AnimatedList(
            key: _listKey,
            initialItemCount: _localTerms.length,
            padding: EdgeInsets.zero,
            itemBuilder: (
              BuildContext context,
              int position,
              Animation<double> animation,
            ) {
              return KeyedSubtree(
                key: ValueKey<String>(_localTerms[position]),
                child: SizeTransition(
                  sizeFactor: animation,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: SMALL_SPACE,
                    ),
                    child: _getItem(context, position),
                  ),
                ),
              );
            },
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
        ],
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
      buildDefaultDragHandles: false,
      itemBuilder: (BuildContext context, int index) {
        return KeyedSubtree(
          key: ValueKey<String>(_localTerms[index]),
          child: _getItem(context, index),
        );
      },
      itemCount: _localTerms.length,
      onReorder: (int oldIndex, int newIndex) {
        if (oldIndex < newIndex) {
          newIndex--;
        }

        final String oldValue = _localTerms[oldIndex];
        _localTerms.removeAt(oldIndex);
        _localTerms.insert(newIndex, oldValue);
        widget.helper.replaceItems(_localTerms);
        setState(() {});
      },
      onReorderStart: (_) => SmoothHapticFeedback.lightNotification(),
      proxyDecorator: (Widget child, int index, Animation<double> animation) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 1, animValue)!;

        return Material(
          elevation: elevation,
          shadowColor: context.darkTheme() ? Colors.white24 : null,
          borderRadius: ANGULAR_BORDER_RADIUS,
          child: child,
        );
      },
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  Widget _getItem(
    BuildContext context,
    int position,
  ) {
    return _SimpleInputListItem(
      term: _localTerms[position],
      reorderable: widget.helper.reorderable,
      editable: widget.helper.editable,
      position: position,
      onChanged: (int position, String term) {
        widget.helper.replaceItem(position, term);
      },
      onRemoveItem: _onRemoveItem,
    );
  }

  Widget _getRobotoffList(
      BuildContext context, AppLocalizations appLocalizations) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    final ValueNotifier<Map<RobotoffQuestion, InsightAnnotation?>>
        questionsNotifier = context
            .watch<ValueNotifier<Map<RobotoffQuestion, InsightAnnotation?>>>();

    final Map<RobotoffQuestion, InsightAnnotation?> questions =
        questionsNotifier.value;

    const double horizontalPadding = MEDIUM_SPACE * 2;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: questions.isEmpty ? 0.0 : MEDIUM_SPACE,
      ),
      child: Column(
        children: questions.entries.map(
          (MapEntry<RobotoffQuestion, InsightAnnotation?> entry) {
            final RobotoffQuestion question = entry.key;
            final InsightAnnotation? annotation = entry.value;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: const EdgeInsetsDirectional.only(
                      start: horizontalPadding,
                      end: LARGE_SPACE,
                      top: SMALL_SPACE,
                      bottom: SMALL_SPACE),
                  color: extension.successBackground,
                  child: Row(
                    children: <Widget>[
                      ExcludeSemantics(
                        child: icons.Sparkles(
                          size: 18.0,
                          color: extension.success,
                        ),
                      ),
                      const SizedBox(width: SMALL_SPACE),
                      Expanded(
                        child: Text(
                          question.value!,
                          style: TextStyle(
                            color: extension.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SmoothBooleanButton(
                        value: annotation == null
                            ? null
                            : annotation == InsightAnnotation.YES,
                        onChanged: (bool? value) {
                          widget.helper.answerRobotoffQuestion(
                            question,
                            value == true
                                ? InsightAnnotation.YES
                                : value == false
                                    ? InsightAnnotation.NO
                                    : null,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                if (question.imageUrl != null)
                  SizedBox(
                    height: 100.0,
                    width: double.infinity,
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Image.network(
                            question.imageUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          left: 0.0,
                          top: 0.0,
                          child: Container(
                            color: Colors.black54,
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: horizontalPadding,
                              vertical: 6.0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const ExcludeSemantics(
                                  child: icons.ImageGallery(
                                    color: Colors.white,
                                    size: 14.0,
                                  ),
                                ),
                                const SizedBox(width: SMALL_SPACE),
                                Text(
                                  appLocalizations.product_edit_robotoff_proof,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: SMALL_SPACE,
                          right: LARGE_SPACE,
                          child: SmoothIconButton(
                            size: 24.0,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      QuestionImageFullPage(
                                    question,
                                  ),
                                ),
                              );
                            },
                            icon: const icons.Expand(),
                          ),
                        )
                      ],
                    ),
                  )
              ],
            );
          },
        ).toList(growable: false),
      ),
    );
  }

  void _onAddItem() {
    _focusNode.unfocus();

    if (widget.controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SmoothFloatingSnackbar.error(
          context: context,
          text: AppLocalizations.of(context).edit_product_form_item_error_empty,
        ),
      );

      return;
    }

    if (widget.helper.addItemsFromController(widget.controller)) {
      // Add new items to the top of our list
      final Iterable<String> newTerms = widget.helper.terms.diff(_localTerms);
      final int newTermsCount = newTerms.length;

      if (widget.newElementsToTop) {
        _localTerms.insertAll(0, newTerms);
        _listKey.currentState?.insertAllItems(0, newTermsCount);
      } else {
        _localTerms.addAll(newTerms);
        _listKey.currentState?.insertItem(_localTerms.length - newTermsCount);
      }

      SmoothHapticFeedback.lightNotification();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SmoothFloatingSnackbar.error(
          context: context,
          text: AppLocalizations.of(context)
              .edit_product_form_item_error_existing,
        ),
      );

      SmoothHapticFeedback.error();
    }
  }

  void _onRemoveItem(String term, Widget child) {
    if (widget.helper.removeTerm(term)) {
      final int position = _localTerms.indexOf(term);
      if (position >= 0) {
        _localTerms.removeAt(position);
        _listKey.currentState?.removeItem(position, (
          _,
          Animation<double> animation,
        ) {
          return FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              child: ListTile(title: child),
            ),
          );
        });

        setState(() {});
      }

      SmoothHapticFeedback.lightNotification();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}

class _SimpleInputListItem extends StatefulWidget {
  const _SimpleInputListItem({
    required this.term,
    required this.reorderable,
    required this.editable,
    required this.position,
    required this.onChanged,
    required this.onRemoveItem,
  });

  final String term;
  final bool reorderable;
  final bool editable;
  final int position;
  final Function(int position, String term) onChanged;
  final Function(String term, Widget child) onRemoveItem;

  @override
  State<_SimpleInputListItem> createState() => _SimpleInputListItemState();
}

class _SimpleInputListItemState extends State<_SimpleInputListItem> {
  late final TextEditingControllerWithHistory _controller;
  late final FocusNode _focusNode;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    if (widget.editable) {
      _controller = TextEditingControllerWithHistory(text: widget.term);
      _focusNode = FocusNode()..addListener(_onFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    Widget child;
    if (widget.editable) {
      child = _getEditableItem();
    } else {
      child = _getItem();
    }

    child = ListTile(
      leading: widget.reorderable
          ? ReorderableDelayedDragStartListener(
              index: widget.position,
              child: const icons.Menu.hamburger(),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (widget.editable) ...<Widget>[
            _SimpleInputListItemAction(
              tooltip: appLocalizations
                  .edit_product_form_item_save_edit_item_tooltip,
              icon: Icon(
                Icons.check_circle_rounded,
                color: extension.success,
              ),
              visible: _isEditing,
              onTap: _saveEdit,
            ),
            _SimpleInputListItemAction(
              tooltip: appLocalizations
                  .edit_product_form_item_cancel_edit_item_tooltip,
              icon: Icon(
                Icons.cancel,
                color: extension.error,
              ),
              visible: _isEditing,
              onTap: _cancelEdit,
            )
          ],
          _SimpleInputListItemAction(
            tooltip:
                appLocalizations.edit_product_form_item_remove_item_tooltip,
            icon: const Icon(Icons.delete),
            onTap: () => widget.onRemoveItem(widget.term, child),
            visible: !_isEditing,
          ),
        ],
      ),
      contentPadding: const EdgeInsetsDirectional.only(
        start: LARGE_SPACE,
      ),
      minTileHeight: 48.0,
      title: child,
    );

    if (widget.editable) {
      return ClipRRect(child: child);
    } else {
      return child;
    }
  }

  Widget _getItem() {
    return Text(widget.term);
  }

  Widget _getEditableItem() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      style: TextTheme.of(context).bodyLarge,
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      maxLines: 1,
      onEditingComplete: _saveEdit,
    );
  }

  void _saveEdit() {
    if (_controller.text.trim().isEmpty) {
      widget.onRemoveItem(widget.term, _getItem());
    } else {
      widget.onChanged(widget.position, _controller.text);
    }

    setState(() => _isEditing = false);
    _focusNode.unfocus();
  }

  void _cancelEdit() {
    _controller.resetToInitialValue();
    _focusNode.unfocus();
    setState(() => _isEditing = false);
  }

  void _onFocus() {
    if (_focusNode.hasFocus && !_isEditing) {
      setState(() => _isEditing = true);
    } else if (!_focusNode.hasFocus && _isEditing) {
      _cancelEdit();
    }
  }

  @override
  void dispose() {
    if (widget.editable) {
      _controller.dispose();
    }
    super.dispose();
  }
}

class _SimpleInputListItemAction extends StatefulWidget {
  const _SimpleInputListItemAction({
    required this.onTap,
    required this.icon,
    required this.tooltip,
    this.visible = true,
  });

  final VoidCallback onTap;
  final Widget icon;
  final String tooltip;
  final bool visible;

  @override
  State<_SimpleInputListItemAction> createState() =>
      _SimpleInputListItemActionState();
}

class _SimpleInputListItemActionState extends State<_SimpleInputListItemAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: SmoothAnimationsDuration.medium,
      reverseDuration: SmoothAnimationsDuration.short,
    )..addListener(() => setState(() {}));

    if (widget.visible) {
      _controller.forward(from: 1.0);
    }

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _sizeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void didUpdateWidget(_SimpleInputListItemAction oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _controller.forward(from: 0.0);
      } else {
        _controller.reverse(from: 1.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: _controller.value == 0.0,
      child: Opacity(
        opacity: _opacityAnimation.value,
        child: SizedBox(
          width: _sizeAnimation.value * (SMALL_SPACE * 2 + 24.0),
          child: Tooltip(
            message: widget.tooltip,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(SMALL_SPACE),
                child: widget.icon,
              ),
            ),
          ),
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

class _SimpleInputListSuggestions extends StatelessWidget {
  const _SimpleInputListSuggestions(
    this.onSelected,
  );

  final Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<SimpleInputSuggestionsState> state =
        context.watch<ValueNotifier<SimpleInputSuggestionsState>>();

    if (state.value is! SimpleInputSuggestionsLoaded) {
      return EMPTY_WIDGET;
    }

    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    return Padding(
      padding: const EdgeInsetsDirectional.only(top: SMALL_SPACE),
      child: ColoredBox(
        color: extension.successBackground,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 22.0,
            end: VERY_SMALL_SPACE,
          ),
          child: Column(
            children:
                (state.value as SimpleInputSuggestionsLoaded).suggestions.map(
              (String suggestion) {
                return _SimpleInputListSuggestionItem(suggestion, () {
                  onSelected(suggestion);
                });
              },
            ).toList(growable: false),
          ),
        ),
      ),
    );
  }
}

class _SimpleInputListSuggestionItem extends StatelessWidget {
  const _SimpleInputListSuggestionItem(
    this.label,
    this.onSelected,
  );

  final String label;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    return ColoredBox(
      color: extension.successBackground,
      child: Row(
        children: <Widget>[
          ExcludeSemantics(
            child: icons.Sparkles(
              color: extension.success,
              size: 18.0,
            ),
          ),
          const SizedBox(width: SMALL_SPACE),
          Expanded(
            child: Text(
              label,
              style: TextTheme.of(context).bodyLarge?.copyWith(
                    color: extension.success,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Tooltip(
            message: AppLocalizations.of(context)
                .edit_product_form_item_add_suggestion,
            child: IconButton(
              onPressed: onSelected,
              icon: Icon(
                Icons.add_circle_outlined,
                color: extension.success,
              ),
            ),
          )
        ],
      ),
    );
  }
}
