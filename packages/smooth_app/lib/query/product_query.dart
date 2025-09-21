import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/dao_secured_string.dart';
import 'package:smooth_app/database/dao_string.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/preferences/country_selector/country.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/product/product_type_extensions.dart';
import 'package:uuid/uuid.dart';

// ignore: avoid_classes_with_only_static_members
abstract class ProductQuery {
  const ProductQuery._();

  static const ProductQueryVersion productQueryVersion = ProductQueryVersion.v3;

  static late OpenFoodFactsCountry _country;

  static String replaceSubdomain(final String url) =>
      UriHelper.replaceSubdomain(
        Uri.parse(url),
        language: getLanguage(),
        country: getCountry(),
      ).toString();

  static OpenFoodFactsLanguage getLanguage() {
    final List<OpenFoodFactsLanguage> languages =
        OpenFoodAPIConfiguration.globalLanguages ?? <OpenFoodFactsLanguage>[];
    if (languages.isEmpty) {
      // very very unlikely
      return OpenFoodFactsLanguage.UNDEFINED;
    }
    return languages[0];
  }

  static void setLanguage(
    final BuildContext? context,
    final UserPreferences userPreferences, {
    String? languageCode,
  }) {
    languageCode ??=
        userPreferences.appLanguageCode ??
        (context == null ? 'en' : Localizations.localeOf(context).languageCode);
    OpenFoodFactsCountryLocalization.setLocale(languageCode);

    final OpenFoodFactsLanguage language = LanguageHelper.fromJson(
      languageCode,
    );
    OpenFoodAPIConfiguration.globalLanguages = <OpenFoodFactsLanguage>[
      language,
    ];
    if (languageCode != userPreferences.appLanguageCode) {
      userPreferences.setAppLanguageCode(languageCode);
    }
  }

  static OpenFoodFactsCountry getCountry() => _country;

  static Future<void> initCountry(final UserPreferences userPreferences) async {
    // not ideal, but we have many contributors monitoring France
    const OpenFoodFactsCountry defaultCountry = OpenFoodFactsCountry.FRANCE;
    final String? isoCode =
        userPreferences.userCountryCode ??
        PlatformDispatcher.instance.locale.countryCode?.toLowerCase();
    final OpenFoodFactsCountry country =
        OpenFoodFactsCountry.fromOffTag(isoCode) ?? defaultCountry;
    await _setCountry(userPreferences, country);
    if (userPreferences.userCurrencyCode == null) {
      // very very first time, or old app with new code
      final Currency? possibleCurrency = country.currency;
      if (possibleCurrency != null) {
        await userPreferences.setUserCurrencyCode(possibleCurrency.name);
      }
    }
  }

  static Future<bool> setCountry(
    final UserPreferences userPreferences,
    final String isoCode,
  ) async {
    final OpenFoodFactsCountry? country = OpenFoodFactsCountry.fromOffTag(
      isoCode,
    );
    if (country == null) {
      return false;
    }
    await _setCountry(userPreferences, country);
    return true;
  }

  static Future<void> _setCountry(
    final UserPreferences userPreferences,
    final OpenFoodFactsCountry country,
  ) async {
    _country = country;
    // we need this to run "world" queries
    OpenFoodAPIConfiguration.globalCountry = null;

    final String isoCode = country.offTag;
    if (isoCode != userPreferences.userCountryCode) {
      await userPreferences.setUserCountryCode(isoCode);
    }
  }

  static String getLocaleString() =>
      '${getLanguage().code}'
      '_'
      '${getCountry().offTag.toUpperCase()}';

  static void setUserAgentComment(final String comment) {
    final UserAgent? previous = OpenFoodAPIConfiguration.userAgent;
    if (previous == null) {
      return;
    }
    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: previous.name,
      version: previous.version,
      system: previous.system,
      url: previous.url,
      comment: comment,
    );
  }

  static const String _UUID_NAME = 'UUID_NAME_REV_1';

  static Future<void> setUuid(final LocalDatabase localDatabase) async {
    final DaoString uuidString = DaoString(localDatabase);
    String? uuid = await uuidString.get(_UUID_NAME);

    if (uuid == null) {
      // Crop down to 16 letters for matomo
      uuid = const Uuid().v4().replaceAll('-', '').substring(0, 16);
      await uuidString.put(_UUID_NAME, uuid);
    }
    OpenFoodAPIConfiguration.uuid = uuid;
    await Sentry.configureScope((Scope scope) {
      scope.contexts['uuid'] = OpenFoodAPIConfiguration.uuid;
      scope.setUser(SentryUser(username: OpenFoodAPIConfiguration.uuid));
    });
  }

  static User getReadUser() =>
      AnalyticsHelper.isEnabled ? getWriteUser() : _testUser;

  static User getWriteUser() =>
      OpenFoodAPIConfiguration.globalUser ?? _testUser;

  static User get _testUser => const User(
    userId: 'smoothie-app',
    password: 'strawberrybanana',
    comment: 'Test user for project smoothie',
  );

  static late UriProductHelper _uriProductHelper;
  static late UriProductHelper uriPricesHelper;
  static late UriHelper uriFolksonomyHelper;

  static bool isLoggedIn() => OpenFoodAPIConfiguration.globalUser != null;

  static void setQueryType(final UserPreferences userPreferences) {
    UriProductHelper getProductHelper(final String flagProd) =>
        userPreferences.getFlag(flagProd) ?? true
        ? uriHelperFoodProd
        : getTestUriProductHelper(userPreferences);

    _uriProductHelper = getProductHelper(
      UserPreferencesDevMode.userPreferencesFlagProd,
    );
    uriPricesHelper = getProductHelper(
      UserPreferencesDevMode.userPreferencesFlagPriceProd,
    );
    uriFolksonomyHelper = UriHelper(
      host:
          userPreferences.getDevModeString(
            UserPreferencesDevMode.userPreferencesFolksonomyHost,
          ) ??
          uriHelperFolksonomyProd.host,
    );
  }

  static UriProductHelper getTestUriProductHelper(
    final UserPreferences userPreferences,
  ) {
    final String testEnvDomain =
        userPreferences.getDevModeString(
          UserPreferencesDevMode.userPreferencesTestEnvDomain,
        ) ??
        '';
    return testEnvDomain.isEmpty
        ? uriHelperFoodTest
        : UriProductHelper(
            isTestMode: true,
            userInfoForPatch: HttpHelper.userInfoForTest,
            domain: testEnvDomain,
          );
  }

  static ProductType? extractProductType(
    final UriProductHelper uriProductHelper,
  ) {
    final String domain = uriProductHelper.domain;
    for (final ProductType productType in ProductType.values) {
      if (domain.contains(productType.getDomain())) {
        return productType;
      }
    }
    return null;
  }

  static UriProductHelper getUriProductHelper({
    required final ProductType? productType,
  }) {
    final UriProductHelper currentUriProductHelper = _uriProductHelper;
    if (productType == null) {
      return currentUriProductHelper;
    }
    final ProductType? currentProductType = extractProductType(
      currentUriProductHelper,
    );
    if (currentProductType == null) {
      return currentUriProductHelper;
    }
    if (currentProductType == productType) {
      return currentUriProductHelper;
    }
    return UriProductHelper(
      domain: currentUriProductHelper.domain.replaceFirst(
        currentProductType.getDomain(),
        productType.getDomain(),
      ),
    );
  }

  static String getProductTypeFromDomain(UriProductHelper uriProductHelper) {
    return uriProductHelper.domain;
  }

  static List<ProductField> get fields => const <ProductField>[
    ProductField.NAME,
    ProductField.BARCODE,
    // ... other fields
  ];

  static Future<MaybeError<String>> getPriceToken(
    final User user,
    final LocalDatabase localDatabase,
  ) async {
    final UriProductHelper uriHelper = ProductQuery.uriPricesHelper;
    final String key =
        'priceBearerToken:${user.userId}|${user.password}|${uriHelper.domain}';
    final String? cached = await DaoSecuredString.get(key);
    if (cached != null) {
      final MaybeError<Session> session =
          await OpenPricesAPIClient.getUserSession(
            bearerToken: cached,
            uriHelper: uriHelper,
          );
      if (session.isError) {
        await DaoSecuredString.remove(key: key);
      }
      return MaybeError<String>.value(cached);
    }
    final MaybeError<String> token =
        await OpenPricesAPIClient.getAuthenticationToken(
          username: user.userId,
          password: user.password,
          uriHelper: uriHelper,
        );
    if (token.isError) {
      throw Exception('Could not get token: ${token.error}');
    }
    if (token.value.isEmpty) {
      throw Exception('Unexpected empty token');
    }
    final String bearerToken = token.value;
    await DaoSecuredString.put(key: key, value: bearerToken);
    return token;
  }
}
