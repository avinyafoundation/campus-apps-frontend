// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_gen/gen_l10n/gallery_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:gallery/auth.dart';
import 'package:gallery/constants.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:gallery/data/gallery_options.dart';
import 'package:gallery/pages/backdrop.dart';
import 'package:gallery/pages/splash.dart';
import 'package:gallery/routes.dart';
import 'package:gallery/routing/delegate.dart';
import 'package:gallery/routing/parser_new.dart';
import 'package:gallery/routing/route_state_new.dart';
import 'package:gallery/themes/gallery_theme_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_strategy/url_strategy.dart';

export 'package:gallery/data/demos.dart' show pumpDeferredLibraries;

void main() async {
  // Use package:url_strategy until this pull request is released:
  // https://github.com/flutter/flutter/pull/77103

  // Use to setHashUrlStrategy() to use "/#/" in the address bar (default). Use
  // setPathUrlStrategy() to use the path. You may need to configure your web
  // server to redirect all paths to index.html.
  //
  // On mobile platforms, both functions are no-ops.
  setHashUrlStrategy();
  // setPathUrlStrategy();

  // WidgetsFlutterBinding.ensureInitialized();

  // await AppConfig.forEnvironment('dev');

  GoogleFonts.config.allowRuntimeFetching = false;
  GalleryApp galleryApp = GalleryApp();
  campusAppsPortalInstance.setAuth(galleryApp._auth);
  bool signedIn = await campusAppsPortalInstance.getSignedIn();
  log('signedIn 1: $signedIn! ');

  galleryApp._auth.getSignedIn().then((value) => signedIn = value);
  log('signedIn 2: $signedIn! ');
  signedIn = await galleryApp._auth.getSignedIn();
  log('signedIn 3: $signedIn! ');
  campusAppsPortalInstance.setSignedIn(signedIn);
  runApp(GalleryApp());
}

class GalleryApp extends StatefulWidget {
  // GalleryApp({super.key});
  GalleryApp({
    super.key,
    this.initialRoute,
    this.isTestMode = false,
  });
  late final String? initialRoute;
  late final bool isTestMode;
  final _auth = CampusAppsPortalAuth();

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  late final String loginRoute = '/signin';
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final RouteState _routeState;
  // late final SimpleRouterDelegate _routerDelegate;
  late final TemplateRouteParser _routeParser;

  get isTestMode => false;

  get _auth => null;

  get _handleAuthStateChanged => null;
  @override
  void initState() {
    // call guard function
    _guard(RouteSettings(name: '/', arguments: null));
    // var _routeParser = TemplateRouteParser(
    //   allowedPaths: [
    //     '/subscribe',
    //     '/subscribed_thankyou',
    //     '/preconditions',
    //     '/signin',
    //     '/apply',
    //     '/tests/logical',
    //     '/application',
    //     '/authors',
    //     '/settings',
    //     '/books/new',
    //     '/books/all',
    //     '/books/popular',
    //     '/book/:bookId',
    //     '/author/:authorId',
    //     '/employees/new',
    //     '/employees/all',
    //     '/employees/popular',
    //     '/employee/:employeeId',
    //     '/address_types/new',
    //     '/address_types/all',
    //     '/address_types/popular',
    //     '/address_type/:id',
    //     '/address_type/new',
    //     '/address_type/edit',
    //     '/#access_token',
    //   ],
    //   guard: _guard,
    //   initialRoute: '/signin',
    // );

    // _routeState = RouteState(_routeParser);

    // _routerDelegate = SimpleRouterDelegate(
    //   routeState: _routeState,
    //   navigatorKey: _navigatorKey,
    //   builder: (context) => SMSNavigator(
    //     navigatorKey: _navigatorKey,
    //   ),
    // );

    // Listen for when the user logs out and display the signin screen.
    // _auth.addListener(_handleAuthStateChanged);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModelBinding(
      initialModel: GalleryOptions(
        themeMode: ThemeMode.system,
        textScaleFactor: systemTextScaleFactorOption,
        customTextDirection: CustomTextDirection.localeBased,
        locale: null,
        timeDilation: timeDilation,
        platform: defaultTargetPlatform,
        isTestMode: isTestMode,
      ),
      child: Builder(
        builder: (context) {
          final options = GalleryOptions.of(context);
          return MaterialApp(
              restorationScopeId: 'rootGallery',
              title: 'Flutter Gallery',
              debugShowCheckedModeBanner: false,
              themeMode: options.themeMode,
              theme: GalleryThemeData.lightThemeData.copyWith(
                platform: options.platform,
              ),
              darkTheme: GalleryThemeData.darkThemeData.copyWith(
                platform: options.platform,
              ),
              localizationsDelegates: const [
                ...GalleryLocalizations.localizationsDelegates,
                LocaleNamesLocalizationsDelegate()
              ],
              initialRoute: loginRoute,
              supportedLocales: GalleryLocalizations.supportedLocales,
              locale: options.locale,
              localeListResolutionCallback: (locales, supportedLocales) {
                deviceLocale = locales?.first;
                return basicLocaleListResolution(locales, supportedLocales);
              },
              onGenerateRoute: RouteConfiguration.onGenerateRoute,
              onUnknownRoute: (RouteSettings settings) {
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (BuildContext context) =>
                      Scaffold(body: Center(child: Text('Not Found'))),
                );
              });
        },
      ),
    );
  }

  static Future<Object?> _guard(RouteSettings from) async {
    bool signedIn = await campusAppsPortalInstance.getSignedIn();
    // final baseRoute = '/demo';
    log("from ${from.toString()}");
    final signInRoute = RouteSettings(name: '/signin', arguments: null);
    final baseRoute = RouteSettings(name: '/demo', arguments: null);

    //log signInRoute
    log("signInRoute ${signInRoute.toString()}");

    // Go to /apply if the user is not signed in
    log("_guard signed in 222$signedIn");
    // log("_guard JWT sub ${jwt_sub}");
    log("_guard from ${from.toString()}\n");
    if (!signedIn && from.name != signInRoute.name) {
      // Go to /signin if the user is not signed in
      log("_guard signed in 333$from");
      var route = RouteConfiguration.onGenerateRoute(baseRoute);
      return route;
      // return signInRoute;
    }
    // Go to /application if the user is signed in and tries to go to /signin.
    else if (signedIn && from.name == signInRoute.name) {
      log("_guard signed in 444$from");
      // return signInRoute;
      var route = RouteConfiguration.onGenerateRoute(from);
      return route;
    } else {
      log("_guard signed in 555$from");
      // return baseRoute;
      var route = RouteConfiguration.onGenerateRoute(baseRoute);
      return route;
    }
  }
}

class RootPage extends StatelessWidget {
  const RootPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const ApplyTextOptions(
      child: SplashPage(
        child: Backdrop(),
      ),
    );
  }
}
