import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/guides/guide/guide_nutriscore_v2.dart';
import 'package:smooth_app/pages/navigator/error_page.dart';
import 'package:smooth_app/pages/navigator/external_page.dart';
import 'package:smooth_app/pages/navigator/external_page_webview.dart';
import 'package:smooth_app/pages/navigator/slide_up_transition.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/premium/premium_page.dart';
import 'package:smooth_app/pages/product/add_new_product/add_new_product_page.dart';
import 'package:smooth_app/pages/product/edit_product/edit_product_page.dart';
import 'package:smooth_app/pages/product/new_product_submission_page.dart';
import 'package:smooth_app/pages/product/product_loader_page.dart';
import 'package:smooth_app/pages/product/product_page/new_product_header.dart';
import 'package:smooth_app/pages/product/product_page/new_product_page.dart';
import 'package:smooth_app/pages/scan/carousel/scan_carousel_manager.dart';
import 'package:smooth_app/pages/search/search_page.dart';
import 'package:smooth_app/pages/search/search_product_helper.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';
import 'package:smooth_app/pages/user_management/sign_up_page.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/text/text_extensions.dart';

class AppNavigator extends InheritedWidget {
  AppNavigator({
    required super.child,
    super.key,
    List<NavigatorObserver>? observers,
  }) : _router = _SmoothGoRouter(observers: observers);

  final _SmoothGoRouter _router;

  static AppNavigator of(BuildContext context) {
    final AppNavigator? result = context
        .dependOnInheritedWidgetOfExactType<AppNavigator>();
    assert(result != null, 'No AppNavigator found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppNavigator oldWidget) {
    return oldWidget._router != _router;
  }

  RouterConfig<Object> get router => _router.router;

  Future<T?> push<T extends Object?>(String routeName, {dynamic extra}) async {
    assert(routeName.isNotEmpty);
    return _router.router.push(routeName, extra: extra);
  }

  void pushReplacement(String routeName, {dynamic extra}) {
    assert(routeName.isNotEmpty);
    _router.router.pushReplacement(routeName, extra: extra);
  }

  void clearStack() {
    while (_router.router.canPop() == true) {
      _router.router.pop();
    }
  }

  bool pop([dynamic result]) {
    try {
      _router.router.pop(result);
      return true;
    } on GoError catch (_) {
      return false;
    }
  }
}

class _SmoothGoRouter {
  factory _SmoothGoRouter({List<NavigatorObserver>? observers}) {
    _singleton ??= _SmoothGoRouter._internal(observers: observers);
    return _singleton!;
  }

  _SmoothGoRouter._internal({List<NavigatorObserver>? observers}) {
    router = GoRouter(
      observers: observers,
      routes: <GoRoute>[
        GoRoute(
          path: _InternalAppRoutes.HOME_PAGE,
          builder: (BuildContext context, GoRouterState state) {
            if (!_appLanguageInitialized) {
              _initAppLanguage(context);
            }
            final UserPreferences userPreferences = context
                .read<UserPreferences>();
            final OnboardingPage lastVisitedOnboardingPage =
                userPreferences.lastVisitedOnboardingPage;
            if (lastVisitedOnboardingPage == OnboardingPage.NOT_STARTED) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await userPreferences.setCrashReports(true);
                await userPreferences.setUserTracking(true);
                if (context.mounted) {
                  OnboardingFlowNavigator(
                    userPreferences,
                  ).navigateToPage(context, OnboardingPage.HEALTH_CARD_EXAMPLE);
                }
              });
            }
            return _findLastOnboardingPage(context);
          },
          routes: <GoRoute>[
            GoRoute(
              path: '${_InternalAppRoutes.PRODUCT_DETAILS_PAGE}/:productId',
              pageBuilder: (BuildContext context, GoRouterState state) {
                Product product;
                if (state.extra is Product) {
                  product = state.extra! as Product;
                } else if (state.extra is Map<String, dynamic>) {
                  product = Product.fromJson(
                    state.extra! as Map<String, dynamic>,
                  );
                } else {
                  throw Exception('No product provided!');
                }
                Widget widget = ProductPage(
                  product,
                  withHeroAnimation:
                      state.uri.queryParameters['heroAnimation'] != 'false',
                  heroTag: state.uri.queryParameters['heroTag'],
                  backButton: ProductPageBackButton.byName(
                    state.uri.queryParameters['backButtonType'],
                  ),
                );
                if (ExternalScanCarouselManager.find(context) == null) {
                  widget = ExternalScanCarouselManager(child: widget);
                }
                return switch (ProductPageTransition.byName(
                  state.uri.queryParameters['transition'],
                )) {
                  ProductPageTransition.standard => MaterialPage<void>(
                    key: state.pageKey,
                    child: widget,
                  ),
                  ProductPageTransition.slideUp =>
                    OpenUpwardsPage.getTransition<void>(
                      key: state.pageKey,
                      child: widget,
                    ),
                };
              },
            ),
            GoRoute(
              path: '${_InternalAppRoutes.PRODUCT_EDITOR_PAGE}/:productId',
              builder: (BuildContext context, GoRouterState state) {
                Product product;
                if (state.extra is Product) {
                  product = state.extra! as Product;
                } else {
                  throw Exception('No product provided!');
                }
                return EditProductPage(product);
              },
            ),
            GoRoute(
              path: '${_InternalAppRoutes.PRODUCT_LOADER_PAGE}/:productId',
              builder: (BuildContext context, GoRouterState state) {
                final String barcode = state.pathParameters['productId']!;
                return ProductLoaderPage(
                  barcode: barcode,
                  mode: state.uri.queryParameters['edit'] == 'true'
                      ? ProductLoaderMode.editProduct
                      : ProductLoaderMode.viewProduct,
                );
              },
            ),
            GoRoute(
              path: '${_InternalAppRoutes.PRODUCT_CREATOR_PAGE}/:productId',
              builder: (BuildContext context, GoRouterState state) {
                final String barcode = state.pathParameters['productId']!;
                return AddNewProductPage.fromBarcode(barcode);
              },
            ),
            GoRoute(
              path: '${_InternalAppRoutes.PREFERENCES_PAGE}/:preferenceType',
              builder: (BuildContext context, GoRouterState state) {
                final String? type = state.pathParameters['preferenceType'];
                final PreferencePageType? pageType = PreferencePageType.values
                    .firstWhereOrNull((PreferencePageType e) => e.name == type);
                if (pageType == null) {
                  throw Exception('Unsupported preference page type: $type');
                }
                return UserPreferencesPage(type: pageType);
              },
            ),
            GoRoute(
              path: _InternalAppRoutes.SEARCH_PAGE,
              builder: (_, GoRouterState state) {
                if (state.extra != null) {
                  return SearchPage.fromExtra(state.extra! as SearchPageExtra);
                } else {
                  return SearchPage(SearchProductHelper());
                }
              },
            ),
            GoRoute(
              path: _InternalAppRoutes._GUIDES,
              routes: <GoRoute>[
                GoRoute(
                  path: _InternalAppRoutes.GUIDE_NUTRISCORE_V2_PAGE,
                  builder: (_, _) => const GuideNutriscoreV2(),
                ),
              ],
              redirect: (_, GoRouterState state) {
                if (state.uri.pathSegments.last !=
                    _InternalAppRoutes.GUIDE_NUTRISCORE_V2_PAGE) {
                  return AppRoutes.EXTERNAL(state.path ?? '');
                } else {
                  return null;
                }
              },
            ),
            GoRoute(
              path: _InternalAppRoutes.SIGNUP_PAGE,
              builder: (_, _) => const SignUpPage(),
            ),
            GoRoute(
              path: _InternalAppRoutes.LOGIN_PAGE,
              builder: (_, __) => const LoginPage(),
            ),
            GoRoute(
              path: _InternalAppRoutes.PREMIUM_PAGE,
              builder: (_, __) => const PremiumPage(),
            ),
            GoRoute(
              path: _InternalAppRoutes.NEW_PRODUCT_SUBMISSION_PAGE,
              builder: (_, __) => const NewProductSubmissionPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/${_InternalAppRoutes.EXTERNAL_PAGE}',
          builder: (BuildContext context, GoRouterState state) {
            return ExternalPage(
              path: _decodePath(state.uri.queryParameters['path']!),
            );
          },
        ),
        GoRoute(
          path: '/${_InternalAppRoutes.EXTERNAL_WEBVIEW_PAGE}',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return OpenUpwardsPage.getTransition<void>(
              key: state.pageKey,
              child: ExternalPageInAWebView(
                path: _decodePath(state.uri.queryParameters['path']!),
                pageName: state.uri.queryParameters['title'],
              ),
            );
          },
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        // JULES' DEBUG PRINT
        debugPrint(
          '--- JULES DEBUG: Running new redirect logic. Current location: ${state.uri.toString()} ---',
        );

        final bool loggedIn = ProductQuery.isLoggedIn();
        debugPrint('--- JULES DEBUG: User is logged in: $loggedIn ---');

        final bool onLoginRoute = state.matchedLocation == AppRoutes.LOGIN;
        final bool onSignupRoute = state.matchedLocation == AppRoutes.SIGNUP;
        final bool onAuthRoute = onLoginRoute || onSignupRoute;

        // 1. If user is not logged in
        if (!loggedIn) {
          // If they are not trying to access an auth route, force them to the login page.
          if (!onAuthRoute) {
            debugPrint(
              '--- JULES DEBUG: Not logged in, redirecting to LOGIN ---',
            );
            return AppRoutes.LOGIN;
          }
          // Otherwise, allow them to stay on the login/signup page.
          debugPrint(
            '--- JULES DEBUG: Not logged in, but on auth route. Allowing. ---',
          );
          return null;
        }

        // 2. If user IS logged in
        // If they are trying to access an auth page, redirect them to home.
        if (onAuthRoute) {
          debugPrint(
            '--- JULES DEBUG: Logged in, but on auth route. Redirecting to HOME. ---',
          );
          return AppRoutes.HOME();
        }

        // 3. If user is logged in and not on an auth route, handle onboarding.
        if (!_isOnboardingComplete(context)) {
          if (state.matchedLocation != AppRoutes.HOME()) {
            debugPrint(
              '--- JULES DEBUG: Logged in, but onboarding not complete. Redirecting to HOME. ---',
            );
            return AppRoutes.HOME();
          }
        }

        debugPrint(
          '--- JULES DEBUG: Proceeding with original deep link logic. ---',
        );
        // 4. Handle deep links and other cases for logged-in, onboarded users.
        final String path = state.matchedLocation;
        if (_isAnInternalRoute(path)) {
          return null;
        }

        bool externalLink = false;

        if (path.isNotEmpty) {
          final int subPaths = path.count('/');
          if (subPaths > 1) {
            final String? barcode = _extractProductBarcode(path);
            if (barcode != null) {
              AnalyticsHelper.trackEvent(
                AnalyticsEvent.productDeepLink,
                barcode: barcode,
              );
              if (state.extra is Product) {
                return AppRoutes.PRODUCT(barcode, useHeroAnimation: false);
              } else {
                return AppRoutes.PRODUCT_LOADER(barcode);
              }
            } else if (path == _ExternalRoutes.PRODUCT_EDITION) {
              final String? barcode = state.uri.queryParameters['code'];
              if (barcode != null &&
                  state.uri.queryParameters['type'] == 'edit') {
                return AppRoutes.PRODUCT_LOADER(barcode, edit: true);
              } else {
                externalLink = true;
              }
            } else {
              externalLink = true;
            }
          } else if (path == _ExternalRoutes.MOBILE_APP_DOWNLOAD) {
            return AppRoutes.HOME();
          } else if (path == _ExternalRoutes.GUIDE_NUTRISCORE_V2) {
            return AppRoutes.GUIDE_NUTRISCORE_V2;
          } else if (path == _ExternalRoutes.SIGNUP) {
            return AppRoutes.SIGNUP;
          } else if (path != _InternalAppRoutes.HOME_PAGE) {
            externalLink = true;
          }
        }

        if (externalLink) {
          return _openExternalLink(state.uri.toString());
        } else if (path.isEmpty) {
          return _InternalAppRoutes.HOME_PAGE;
        } else {
          return state.uri.toString();
        }
      },
      errorBuilder: (_, GoRouterState state) =>
          ErrorPage(url: state.uri.toString()),
    );
  }

  bool _appLanguageInitialized = false;

  Future<void> _initAppLanguage(BuildContext context) {
    _appLanguageInitialized = true;
    ProductQuery.setLanguage(context, context.read<UserPreferences>());
    context.read<AppNewsProvider>().loadLatestNews();
    return context.read<ProductPreferences>().refresh();
  }

  String _openExternalLink(String path) {
    AnalyticsHelper.trackEvent(AnalyticsEvent.genericDeepLink);
    return AppRoutes.EXTERNAL(path[0] == '/' ? path.substring(1) : path);
  }

  static _SmoothGoRouter? _singleton;
  late GoRouter router;

  String? _extractProductBarcode(String path) {
    if (path.isEmpty) {
      return null;
    }
    final List<String> pathParams = path.split('/').sublist(1);
    if (pathParams.length > 1) {
      final String barcode = pathParams[1];
      if (int.tryParse(barcode) != null && barcode.length >= 8) {
        return barcode;
      }
    }
    return null;
  }

  bool _isAnInternalRoute(String path) {
    if (path == _InternalAppRoutes.HOME_PAGE) {
      return true;
    } else {
      return path.startsWith('/_');
    }
  }

  bool _isOnboardingComplete(BuildContext context) {
    return _getCurrentOnboardingPage(context).isOnboardingComplete();
  }

  Widget _findLastOnboardingPage(BuildContext context) {
    return _getCurrentOnboardingPage(context).getPageWidget(context);
  }

  OnboardingPage _getCurrentOnboardingPage(BuildContext context) {
    final UserPreferences userPreferences = context.read<UserPreferences>();
    final OnboardingPage lastVisitedOnboardingPage =
        userPreferences.lastVisitedOnboardingPage;
    return lastVisitedOnboardingPage;
  }
}

class _InternalAppRoutes {
  static const String HOME_PAGE = '/';
  static const String PRODUCT_DETAILS_PAGE = '_product';
  static const String PRODUCT_LOADER_PAGE = '_product_loader';
  static const String PRODUCT_CREATOR_PAGE = '_product_creator';
  static const String PRODUCT_EDITOR_PAGE = '_product_editor';
  static const String NEW_PRODUCT_SUBMISSION_PAGE = '_new_product_submission';
  static const String PREFERENCES_PAGE = '_preferences';
  static const String SEARCH_PAGE = '_search';
  static const String EXTERNAL_PAGE = '_external';
  static const String EXTERNAL_WEBVIEW_PAGE = '_external_webview';
  static const String SIGNUP_PAGE = '_signup';
  static const String LOGIN_PAGE = '_login';
  static const String PREMIUM_PAGE = '_premium';
  static const String _GUIDES = '_guides';
  static const String GUIDE_NUTRISCORE_V2_PAGE = '_nutriscore-v2';
}

class _ExternalRoutes {
  static const String MOBILE_APP_DOWNLOAD = '/open-food-facts-mobile-app';
  static const String PRODUCT_EDITION = '/cgi/product.pl';
  static const String GUIDE_NUTRISCORE_V2 = '/nutriscore-v2';
  static const String SIGNUP = '/signup';
}

class AppRoutes {
  AppRoutes._();

  static String HOME({bool redraw = false}) =>
      '${_InternalAppRoutes.HOME_PAGE}?redraw:$redraw';

  static String PRODUCT(
    String barcode, {
    bool useHeroAnimation = true,
    String? heroTag = '',
    ProductPageBackButton? backButtonType,
    ProductPageTransition? transition = ProductPageTransition.standard,
  }) =>
      '/${_InternalAppRoutes.PRODUCT_DETAILS_PAGE}/$barcode'
      '?heroAnimation=$useHeroAnimation'
      '&heroTag=$heroTag'
      '&backButtonType=${backButtonType?.name}'
      '&transition=${transition?.name}';

  static String PRODUCT_LOADER(String barcode, {bool edit = false}) =>
      '/${_InternalAppRoutes.PRODUCT_LOADER_PAGE}/$barcode?edit=$edit';

  static String PRODUCT_CREATOR(String barcode) =>
      '/${_InternalAppRoutes.PRODUCT_CREATOR_PAGE}/$barcode';

  static String PRODUCT_EDITOR(String barcode) =>
      '/${_InternalAppRoutes.PRODUCT_EDITOR_PAGE}/$barcode';

  static String PREFERENCES(PreferencePageType type) =>
      '/${_InternalAppRoutes.PREFERENCES_PAGE}/${type.name}';

  static String get SEARCH => '/${_InternalAppRoutes.SEARCH_PAGE}';

  static String get GUIDE_NUTRISCORE_V2 =>
      '/${_InternalAppRoutes._GUIDES}/${_InternalAppRoutes.GUIDE_NUTRISCORE_V2_PAGE}';

  static String get SIGNUP => '/${_InternalAppRoutes.SIGNUP_PAGE}';

  static String get LOGIN => '/${_InternalAppRoutes.LOGIN_PAGE}';

  static String get PREMIUM => '/${_InternalAppRoutes.PREMIUM_PAGE}';

  static String get NEW_PRODUCT_SUBMISSION =>
      '/${_InternalAppRoutes.NEW_PRODUCT_SUBMISSION_PAGE}';

  static String EXTERNAL(String path) =>
      '/${_InternalAppRoutes.EXTERNAL_PAGE}?path=${_encodePath(path)}';

  static String EXTERNAL_WEBVIEW(String path, {String? pageTitle}) =>
      '/${_InternalAppRoutes.EXTERNAL_WEBVIEW_PAGE}?title=$pageTitle&path=${_encodePath(path)}';
}

String _encodePath(String path) => base64Encode(utf8.encode(path));
String _decodePath(String path) => utf8.decode(base64Decode(path));
