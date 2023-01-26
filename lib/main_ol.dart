// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:developer';
import 'dart:io';

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
import 'package:gallery/themes/gallery_theme_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_strategy/url_strategy.dart';
import 'config/app_config.dart';
import 'app.dart';
import 'routing.dart';
import 'pages/navigator.dart';

// import 'auth.dart';

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

  WidgetsFlutterBinding.ensureInitialized();

  await AppConfig.forEnvironment('dev');

  // GoogleFonts.config.allowRuntimeFetching = false;

  // // GalleryApp galleryApp = GalleryApp();
  // final _auth = CampusAppsPortalAuth();

  // campusAppsPortalInstance.setAuth(_auth);

  // bool signedIn = await campusAppsPortalInstance.getSignedIn();

  // log('signedIn 1: $signedIn! ');

  // campusAppsPortalInstance.setSignedIn(signedIn);

  // _auth.getSignedIn().then((value) => signedIn = value);

  log('signedIn 2: ');

  runApp(GalleryApp());
}

class GalleryApp extends StatefulWidget {
  // const GalleryApp({super.key});
  GalleryApp({
    super.key,
    this.initialRoute,
    this.isTestMode = false,
  });

  final String? initialRoute;
  final bool isTestMode;

  @override
  State<GalleryApp> createState() => _GalleryAppSystemState();
}

class _GalleryAppSystemState extends State<GalleryApp> {
  final _auth = CampusAppsPortalAuth();
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final RouteState _routeState;
  late final SimpleRouterDelegate _routerDelegate;
  late final TemplateRouteParser _routeParser;

  get initialRoute => null;

  get isTestMode => null;

  @override
  void initState() {
    log('signedIn 1:uuuuu');

    /// Configure the parser with all of the app's allowed path templates.
    _routeParser = TemplateRouteParser(
      allowedPaths: [
        '/signin',
        '/#access_token',
      ],
      guard: _guard,
      initialRoute: '/signin',
    );

    _routeState = RouteState(_routeParser);

    _routerDelegate = SimpleRouterDelegate(
      routeState: _routeState,
      navigatorKey: _navigatorKey,
      builder: (context) => SMSNavigator(
        navigatorKey: _navigatorKey,
      ),
    );

    // Listen for when the user logs out and display the signin screen.
    _auth.addListener(_handleAuthStateChanged);

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
            title: 'Avinya Academy Apps Portal',
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
            initialRoute: this.initialRoute,
            supportedLocales: GalleryLocalizations.supportedLocales,
            locale: options.locale,
            localeListResolutionCallback: (locales, supportedLocales) {
              deviceLocale = locales?.first;
              return basicLocaleListResolution(locales, supportedLocales);
            },
            onGenerateRoute: RouteConfiguration.onGenerateRoute,
          );
        },
      ),
    );
  }

  Future<ParsedRoute> _guard(ParsedRoute from) async {
    final signedIn = await _auth.getSignedIn();
    // String? jwt_sub = admissionSystemInstance.getJWTSub();

    final signInRoute = ParsedRoute('/signin', '/signin', {}, {});
    final galleryRoute = ParsedRoute('/gallery', '/gallery', {}, {});

    // Go to /apply if the user is not signed in
    log("_guard signed in $signedIn");
    // log("_guard JWT sub ${jwt_sub}");
    log("_guard from ${from.toString()}\n");
    if (!signedIn && from != signInRoute) {
      // Go to /signin if the user is not signed in
      return signInRoute;
    }
    // Go to /application if the user is signed in and tries to go to /signin.
    else if (signedIn && from == galleryRoute) {
      return ParsedRoute('/gallery', '/gallery', {}, {});
    }
    return from;
  }

  void _handleAuthStateChanged() async {
    bool signedIn = await _auth.getSignedIn();
    if (!signedIn) {
      _routeState.go('/signin');
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_handleAuthStateChanged);
    _routeState.dispose();
    _routerDelegate.dispose();
    super.dispose();
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
