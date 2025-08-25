import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/strings_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/themes/theme_provider.dart';

enum TextFieldTypes { PLAIN_TEXT, PASSWORD }

class SmoothTextFormField extends StatefulWidget {
  const SmoothTextFormField({
    required this.type,
    required this.controller,
    required this.hintText,
    super.key,
    this.enabled,
    this.textInputAction,
    this.textCapitalization,
    this.validator,
    this.autofillHints,
    this.hintTextStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputType,
    this.onChanged,
    this.onFieldSubmitted,
    this.autofocus,
    this.focusNode,
    this.spellCheckConfiguration,
    this.allowEmojis = true,
    this.maxLines,
    this.borderRadius,
    this.contentPadding,
  });

  final TextFieldTypes type;
  final TextEditingController? controller;
  final String hintText;
  final TextStyle? hintTextStyle;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool? enabled;
  final TextInputAction? textInputAction;
  final TextCapitalization? textCapitalization;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;
  final TextInputType? textInputType;
  final void Function(String?)? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool? autofocus;
  final FocusNode? focusNode;
  final SpellCheckConfiguration? spellCheckConfiguration;
  final bool allowEmojis;
  final int? maxLines;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<SmoothTextFormField> createState() => _SmoothTextFormFieldState();

  static TextStyle defaultHintTextStyle(BuildContext context) => TextStyle(
    fontStyle: FontStyle.italic,
    color: context.lightTheme()
        ? const Color(0x99000000)
        : const Color(0xBBFFFFFF),
  );
}

class _SmoothTextFormFieldState extends State<SmoothTextFormField> {
  late bool _obscureText;

  @override
  void initState() {
    _obscureText = widget.type == TextFieldTypes.PASSWORD;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool enableSuggestions = widget.type == TextFieldTypes.PLAIN_TEXT;
    final bool autocorrect = widget.type == TextFieldTypes.PLAIN_TEXT;
    final TextStyle textStyle = DefaultTextStyle.of(
      context,
    ).style.copyWith(fontSize: 15.0);
    final double textSize = textStyle.fontSize ?? 20.0;
    final AppLocalizations appLocalization = AppLocalizations.of(context);

    return TextFormField(
      keyboardType: widget.textInputType,
      controller: widget.controller,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
      validator: widget.validator,
      obscureText: _obscureText,
      enableSuggestions: enableSuggestions,
      autocorrect: autocorrect,
      focusNode: widget.focusNode,
      autofillHints: widget.autofillHints,
      autofocus: widget.autofocus ?? false,
      maxLines: widget.maxLines,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged:
          widget.onChanged ??
          (String data) {
            // Rebuilds for changing the eye icon
            if (widget.type == TextFieldTypes.PASSWORD && data.length != 1) {
              setState(() {});
            }
          },
      spellCheckConfiguration:
          widget.spellCheckConfiguration ??
          const SpellCheckConfiguration.disabled(),
      onFieldSubmitted: widget.onFieldSubmitted,
      style: TextStyle(fontSize: textSize),
      cursorHeight: textSize * (textStyle.height ?? 1.4),
      inputFormatters: <TextInputFormatter>[
        if (!widget.allowEmojis)
          FilteringTextInputFormatter.deny(TextHelper.emojiRegex),
      ],
      decoration: InputDecoration(
        contentPadding:
            widget.contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: LARGE_SPACE,
              vertical: SMALL_SPACE,
            ),
        isDense: widget.contentPadding != null,
        prefixIcon: widget.prefixIcon,
        filled: true,
        hintStyle: (widget.hintTextStyle ?? const TextStyle()).apply(
          overflow: TextOverflow.ellipsis,
        ),
        hintText: widget.hintText,
        hintMaxLines: widget.maxLines ?? 2,
        border: OutlineInputBorder(
          borderRadius: widget.borderRadius ?? CIRCULAR_BORDER_RADIUS,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: widget.borderRadius ?? CIRCULAR_BORDER_RADIUS,
          borderSide: const BorderSide(color: Colors.transparent, width: 5.0),
        ),
        suffixIcon:
            widget.suffixIcon ??
            (widget.type == TextFieldTypes.PASSWORD
                ? IconButton(
                    tooltip: appLocalization.show_password,
                    splashRadius: 10.0,
                    onPressed: () => setState(() {
                      _obscureText = !_obscureText;
                    }),
                    icon: _obscureText
                        ? const Icon(Icons.visibility_off)
                        : const Icon(Icons.visibility),
                  )
                : null),
        errorMaxLines: widget.maxLines ?? 2,
      ),
    );
  }
}
