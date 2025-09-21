import 'dart:async';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/user_management_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage();

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TraceableClientMixin {
  static const double space = 10;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _password1Controller = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();

  final FocusNode _userFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _password1FocusNode = FocusNode();
  final FocusNode _password2FocusNode = FocusNode();

  bool _agree = false;
  bool _subscribe = false;
  bool _disagreed = false;

  @override
  String get actionName => 'Opened sign_up_page';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Size size = MediaQuery.sizeOf(context);
    final ThemeData theme = Theme.of(context);

    Color getCheckBoxColor(Set<WidgetState> states) {
      const Set<WidgetState> interactiveStates = <WidgetState>{
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return theme.colorScheme.onSurface;
      }
      if (theme.colorScheme.brightness == Brightness.light) {
        return theme.colorScheme.primary;
      } else {
        return theme.colorScheme.secondary;
      }
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        SystemNavigator.pop();
      },
      child: SmoothScaffold(
        fixKeyboard: true,
        appBar: SmoothAppBar(
          title: Text(appLocalizations.sign_up_page_title),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: AutofillGroup(
          child: Form(
            onChanged: () => setState(() {}),
            key: _formKey,
            child: Scrollbar(
              child: ListView(
                padding: EdgeInsetsDirectional.only(
                  start: size.width * 0.05,
                  end: size.width * 0.05,
                  bottom: MediaQuery.viewInsetsOf(context).bottom * 0.25,
                ),
                children: <Widget>[
                  SmoothTextFormField(
                    textInputType: TextInputType.name,
                    type: TextFieldTypes.PLAIN_TEXT,
                    controller: _displayNameController,
                    textInputAction: TextInputAction.next,
                    hintText: appLocalizations.sign_up_page_display_name_hint,
                    prefixIcon: const Icon(Icons.person),
                    autofillHints: const <String>[AutofillHints.name],
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return appLocalizations
                            .sign_up_page_display_name_error_empty;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: space),
                  SmoothTextFormField(
                    textInputType: TextInputType.emailAddress,
                    type: TextFieldTypes.PLAIN_TEXT,
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    textInputAction: TextInputAction.next,
                    hintText: appLocalizations.sign_up_page_email_hint,
                    prefixIcon: const Icon(Icons.person),
                    autofillHints: const <String>[AutofillHints.email],
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return appLocalizations.sign_up_page_email_error_empty;
                      } else if (!UserManagementHelper.isEmailValid(
                        _emailController.trimmedText,
                      )) {
                        return appLocalizations
                            .sign_up_page_email_error_invalid;
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: space),
                  SmoothTextFormField(
                    type: TextFieldTypes.PLAIN_TEXT,
                    controller: _userController,
                    focusNode: _userFocusNode,
                    textInputAction: TextInputAction.next,
                    hintText: appLocalizations.sign_up_page_username_hint,
                    prefixIcon: const Icon(Icons.person),
                    autofillHints: const <String>[AutofillHints.newUsername],
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return appLocalizations
                            .sign_up_page_username_error_empty;
                      }
                      if (!UserManagementHelper.isUsernameValid(
                        _userController.trimmedText,
                      )) {
                        return appLocalizations
                            .sign_up_page_username_description;
                      }
                      if (!UserManagementHelper.isUsernameLengthValid(
                        _userController.trimmedText,
                      )) {
                        const int maxLength =
                            OpenFoodAPIClient.USER_NAME_MAX_LENGTH;
                        return appLocalizations
                            .sign_up_page_username_length_invalid(maxLength);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: space),
                  SmoothTextFormField(
                    type: TextFieldTypes.PASSWORD,
                    controller: _password1Controller,
                    focusNode: _password1FocusNode,
                    textInputAction: TextInputAction.next,
                    hintText: appLocalizations.sign_up_page_password_hint,
                    maxLines: 1,
                    onFieldSubmitted: (_) => FocusScope.of(
                      context,
                    ).requestFocus(_password2FocusNode),
                    prefixIcon: const Icon(Icons.vpn_key),
                    autofillHints: const <String>[AutofillHints.newPassword],
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return appLocalizations
                            .sign_up_page_password_error_empty;
                      } else if (!UserManagementHelper.isPasswordValid(value)) {
                        return appLocalizations
                            .sign_up_page_password_error_invalid;
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: space),
                  SmoothTextFormField(
                    type: TextFieldTypes.PASSWORD,
                    controller: _password2Controller,
                    focusNode: _password2FocusNode,
                    textInputAction: TextInputAction.send,
                    hintText:
                        appLocalizations.sign_up_page_confirm_password_hint,
                    maxLines: 1,
                    prefixIcon: const Icon(Icons.vpn_key),
                    autofillHints: const <String>[AutofillHints.newPassword],
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return appLocalizations
                            .sign_up_page_confirm_password_error_empty;
                      } else if (_password2Controller.text !=
                          _password1Controller.text) {
                        return appLocalizations
                            .sign_up_page_confirm_password_error_invalid;
                      } else {
                        return null;
                      }
                    },
                    onFieldSubmitted: (String password) {
                      if (password.isNotEmpty) {
                        _signUp(context);
                      } else {
                        _formKey.currentState!.validate();
                      }
                    },
                  ),
                  const SizedBox(height: space),
                  _TermsOfUseCheckbox(
                    agree: _agree,
                    disagree: _disagreed,
                    checkboxColorResolver: getCheckBoxColor,
                    onCheckboxChanged: (bool checked) {
                      setState(() {
                        _agree = checked;
                      });
                    },
                  ),
                  const SizedBox(height: space),
                  ListTile(
                    onTap: () {
                      setState(() => _subscribe = !_subscribe);
                    },
                    contentPadding: EdgeInsets.zero,
                    leading: IgnorePointer(
                      ignoring: true,
                      child: Checkbox(
                        value: _subscribe,
                        fillColor: WidgetStateProperty.resolveWith(
                          getCheckBoxColor,
                        ),
                        onChanged: (_) {},
                      ),
                    ),
                    title: Text(
                      appLocalizations.sign_up_page_subscribe_checkbox,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: space),
                  ElevatedButton(
                    onPressed: () => _signUp(context),
                    style: ButtonStyle(
                      minimumSize: WidgetStateProperty.all<Size>(
                        Size(size.width * 0.5, theme.buttonTheme.height + 10),
                      ),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                          borderRadius: CIRCULAR_BORDER_RADIUS,
                        ),
                      ),
                    ),
                    child: Text(
                      appLocalizations.sign_up_page_action_button,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 18.0,
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: space),
                  TextButton(
                    onPressed: () => GoRouter.of(context).go(AppRoutes.LOGIN),
                    child: Text(
                      'Already have an account? Sign In',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: space),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signUp(BuildContext context) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _disagreed = !_agree;
    if (_disagreed) {
      setState(() {});
      return;
    }

    final User user = User(
      userId: _userController.trimmedText,
      password: _password1Controller.text,
    );

    final String? errorMessage = await LoadingDialog.run<String?>(
      context: context,
      future: _performManualRegistration(user),
      title: appLocalizations.sign_up_page_action_doing_it,
    );

    if (!mounted) {
      return;
    }

    if (errorMessage != null) {
      await LoadingDialog.error(context: context, title: errorMessage);
      return;
    }

    AnalyticsHelper.trackEvent(AnalyticsEvent.registerAction);
    await context.read<UserManagementProvider>().putUser(user);

    final UserPreferences userPreferences =
        await UserPreferences.getUserPreferences();
    userPreferences.resetOnboarding();

    if (!mounted) {
      return;
    }

    GoRouter.of(context).go(AppRoutes.PREFERENCES(PreferencePageType.ACCOUNT));
  }

  Future<String?> _performManualRegistration(User user) async {
    try {
      final Uri uri = Uri.https('world.luppa.ar', '/cgi/user.pl');
      final http.MultipartRequest request = http.MultipartRequest('POST', uri)
        ..fields['user_id'] = user.userId
        ..fields['password'] = user.password
        ..fields['name'] = _displayNameController.trimmedText
        ..fields['email'] = _emailController.trimmedText
        ..fields['newsletter'] = _subscribe ? 'on' : 'off'
        ..fields['process'] = 'Sign-up'
        ..fields['type'] = 'add_user_json';

      final http.StreamedResponse response = await request.send();
      final String responseBody = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        return 'Server error: ${response.statusCode}';
      }

      final dynamic jsonResponse = json.decode(responseBody);
      if (jsonResponse['status'] != null &&
          jsonResponse['status'] == 'user_created') {
        return null; // Success
      } else if (jsonResponse['error'] != null) {
        return jsonResponse['error'];
      } else {
        return 'An unknown error occurred.';
      }
    } catch (e) {
      return e.toString();
    }
  }
}

class _TermsOfUseCheckbox extends StatelessWidget {
  const _TermsOfUseCheckbox({
    required this.agree,
    required this.disagree,
    required this.onCheckboxChanged,
    required this.checkboxColorResolver,
  });

  final bool agree;
  final bool disagree;
  final WidgetPropertyResolver<Color?> checkboxColorResolver;
  final ValueChanged<bool> onCheckboxChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return InkWell(
      excludeFromSemantics: true,
      onTap: () {
        onCheckboxChanged(!agree);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                IgnorePointer(
                  ignoring: true,
                  child: Checkbox(
                    value: agree,
                    fillColor: WidgetStateProperty.resolveWith(
                      checkboxColorResolver,
                    ),
                    onChanged: (_) {},
                  ),
                ),
                const SizedBox(width: 20.0),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: '${appLocalizations.sign_up_page_agree_text} ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        TextSpan(
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.blue,
                          ),
                          text: appLocalizations.sign_up_page_terms_text,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _onTermsClicked(appLocalizations),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _onTermsClicked(appLocalizations),
                  customBorder: const CircleBorder(),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Icon(
                      semanticLabel: appLocalizations.termsOfUse,
                      Icons.info,
                      color: checkboxColorResolver(<WidgetState>{
                        WidgetState.selected,
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Offstage(
            offstage: !disagree,
            child: Text(
              appLocalizations.sign_up_page_agree_error_invalid,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onTermsClicked(AppLocalizations appLocalizations) async {
    final String url = appLocalizations.sign_up_page_agree_url;

    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
    } catch (_) {}
  }
}
