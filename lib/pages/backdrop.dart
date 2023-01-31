// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/gallery_localizations.dart';
import 'package:gallery/auth.dart';
import 'package:gallery/constants.dart';
import 'package:gallery/data/gallery_options.dart';
import 'package:gallery/layout/adaptive.dart';
import 'package:gallery/pages/home.dart';
import 'package:gallery/pages/login.dart';
import 'package:gallery/pages/settings.dart';
import 'package:gallery/pages/settings_icon/icon.dart' as settings_icon;
import 'package:gallery/routing/parsed_route.dart';
import 'package:gallery/routing/parser.dart';
import 'package:gallery/routing/route_state.dart';

import '../data/campus_apps_portal.dart';

const double _settingsButtonWidth = 64;
const double _settingsButtonHeightDesktop = 56;
const double _settingsButtonHeightMobile = 40;

class Backdrop extends StatefulWidget {
  const Backdrop({super.key, this.settingsPage, this.homePage, this.loginPage});

  final Widget? settingsPage;
  final Widget? homePage;
  final Widget? loginPage;

  @override
  State<Backdrop> createState() => _BackdropState();
}

class _BackdropState extends State<Backdrop> with TickerProviderStateMixin {
  late AnimationController _settingsPanelController;
  late AnimationController _iconController;
  late FocusNode _settingsPageFocusNode;
  late ValueNotifier<bool> _isSettingsOpenNotifier;
  late Widget _settingsPage;
  late Widget _homePage;
  late Widget _loginPage;
  final _auth = CampusAppsPortalAuth();

  late final RouteState _routeState;
  // late final SimpleRouterDelegate _routerDelegate;
  // late final TemplateRouteParser _routeParser;

  @override
  void initState() {
    super.initState();
    _settingsPanelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _settingsPageFocusNode = FocusNode();
    _isSettingsOpenNotifier = ValueNotifier(false);
    _settingsPage = widget.settingsPage ??
        SettingsPage(
          animationController: _settingsPanelController,
        );
    _homePage = widget.homePage ?? const HomePage();
    // _loginPage = widget.loginPage ?? const LoginPage();
    var _routeParser = TemplateRouteParser(
      allowedPaths: [
        '/subscribe',
        '/signin',
        '/#access_token',
      ],
      guard: _guard,
      initialRoute: '/signin',
    );
    _routeState = RouteState(_routeParser);
    // Listen for when the user logs out and display the signin screen.
    _auth.addListener(_handleAuthStateChanged);

    // initState();
  }

  @override
  void dispose() {
    _settingsPanelController.dispose();
    _iconController.dispose();
    _settingsPageFocusNode.dispose();
    _isSettingsOpenNotifier.dispose();
    super.dispose();
  }

  void _toggleSettings() {
    // Animate the settings panel to open or close.
    if (_isSettingsOpenNotifier.value) {
      _settingsPanelController.reverse();
      _iconController.reverse();
    } else {
      _settingsPanelController.forward();
      _iconController.forward();
    }
    _isSettingsOpenNotifier.value = !_isSettingsOpenNotifier.value;
  }

  Animation<RelativeRect> _slideDownSettingsPageAnimation(
      BoxConstraints constraints) {
    return RelativeRectTween(
      begin: RelativeRect.fromLTRB(0, -constraints.maxHeight, 0, 0),
      end: const RelativeRect.fromLTRB(0, 0, 0, 0),
    ).animate(
      CurvedAnimation(
        parent: _settingsPanelController,
        curve: const Interval(
          0.0,
          0.4,
          curve: Curves.ease,
        ),
      ),
    );
  }

  Animation<RelativeRect> _slideDownHomePageAnimation(
      BoxConstraints constraints) {
    return RelativeRectTween(
      begin: const RelativeRect.fromLTRB(0, 0, 0, 0),
      end: RelativeRect.fromLTRB(
        0,
        constraints.biggest.height - galleryHeaderHeight,
        0,
        -galleryHeaderHeight,
      ),
    ).animate(
      CurvedAnimation(
        parent: _settingsPanelController,
        curve: const Interval(
          0.0,
          0.4,
          curve: Curves.ease,
        ),
      ),
    );
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    final isDesktop = isDisplayDesktop(context);

    bool signedIn = campusAppsPortalInstance.getSignedIn();

    log('signedIn: $signedIn! ');
    print('signedIn: $signedIn!');

    log('is decktop $isDesktop');

    final Widget settingsPage = ValueListenableBuilder<bool>(
      valueListenable: _isSettingsOpenNotifier,
      builder: (context, isSettingsOpen, child) {
        return ExcludeSemantics(
          excluding: !isSettingsOpen,
          child: isSettingsOpen
              ? RawKeyboardListener(
                  includeSemantics: false,
                  focusNode: _settingsPageFocusNode,
                  onKey: (event) {
                    if (event.logicalKey == LogicalKeyboardKey.escape) {
                      _toggleSettings();
                    }
                  },
                  child: FocusScope(child: _settingsPage),
                )
              : ExcludeFocus(child: _settingsPage),
        );
      },
    );

    final Widget homePage = ValueListenableBuilder<bool>(
      valueListenable: _isSettingsOpenNotifier,
      builder: (context, isSettingsOpen, child) {
        return ExcludeSemantics(
          excluding: isSettingsOpen,
          child: FocusTraversalGroup(child: _homePage),
        );
      },
    );

    final Widget loginPage = ValueListenableBuilder<bool>(
      valueListenable: _isSettingsOpenNotifier,
      builder: (context, isSettingsOpen, child) {
        log('loginPageloginPage: ! ');
        return ExcludeSemantics(
          excluding: isSettingsOpen,
          child: FocusTraversalGroup(
            child: LoginPage(
                // onSignIn: (credentials) async {
                //   var signedIn = await authState.signIn(
                //       credentials.username, credentials.password);
                //   if (signedIn) {
                //     await routeState.go('/gallery');
                //   }
                // },
                ),
          ),
        );
      },
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: GalleryOptions.of(context).resolvedSystemUiOverlayStyle(),
      child: Stack(
        children: [
          if (!isDesktop) ...[
            // Slides the settings page up and down from the top of the
            // screen.
            PositionedTransition(
              rect: _slideDownSettingsPageAnimation(constraints),
              child: settingsPage,
            ),
            // Slides the home page up and down below the bottom of the
            // screen.
            PositionedTransition(
              rect: _slideDownHomePageAnimation(constraints),
              child: homePage,
            ),
            PositionedTransition(
              rect: _slideDownHomePageAnimation(constraints),
              child: loginPage,
            ),
          ],
          if (isDesktop && signedIn) ...[
            Semantics(sortKey: const OrdinalSortKey(2), child: homePage),
            ValueListenableBuilder<bool>(
              valueListenable: _isSettingsOpenNotifier,
              builder: (context, isSettingsOpen, child) {
                if (isSettingsOpen) {
                  return ExcludeSemantics(
                    child: Listener(
                      onPointerDown: (_) => _toggleSettings(),
                      child: const ModalBarrier(dismissible: false),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
            Semantics(
              sortKey: const OrdinalSortKey(3),
              child: ScaleTransition(
                alignment: Directionality.of(context) == TextDirection.ltr
                    ? Alignment.topRight
                    : Alignment.topLeft,
                scale: CurvedAnimation(
                  parent: _settingsPanelController,
                  curve: Curves.easeIn,
                  reverseCurve: Curves.easeOut,
                ),
                child: Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Material(
                    elevation: 7,
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(40),
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 560,
                        maxWidth: desktopSettingsWidth,
                        minWidth: desktopSettingsWidth,
                      ),
                      child: settingsPage,
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (isDesktop && !signedIn) ...[
            Semantics(sortKey: const OrdinalSortKey(2), child: loginPage),
            ValueListenableBuilder<bool>(
              valueListenable: _isSettingsOpenNotifier,
              builder: (context, isSettingsOpen, child) {
                if (isSettingsOpen) {
                  return ExcludeSemantics(
                    child: Listener(
                      onPointerDown: (_) => _toggleSettings(),
                      child: const ModalBarrier(dismissible: false),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
            Semantics(
              sortKey: const OrdinalSortKey(3),
              child: ScaleTransition(
                alignment: Directionality.of(context) == TextDirection.ltr
                    ? Alignment.topRight
                    : Alignment.topLeft,
                scale: CurvedAnimation(
                  parent: _settingsPanelController,
                  curve: Curves.easeIn,
                  reverseCurve: Curves.easeOut,
                ),
                child: Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Material(
                    elevation: 7,
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(40),
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 560,
                        maxWidth: desktopSettingsWidth,
                        minWidth: desktopSettingsWidth,
                      ),
                      child: settingsPage,
                    ),
                  ),
                ),
              ),
            ),
          ],
          _SettingsIcon(
            animationController: _iconController,
            toggleSettings: _toggleSettings,
            isSettingsOpenNotifier: _isSettingsOpenNotifier,
          ),
        ],
      ),
    );
  }

  Future<ParsedRoute> _guard(ParsedRoute from) async {
    final _auth = CampusAppsPortalAuth();
    final signedIn = await _auth.getSignedIn();
    // String? jwt_sub = admissionSystemInstance.getJWTSub();
    // const String signInRoute = '/signin';
    final signInRoute = ParsedRoute('/signin', '/signin', {}, {});
    final baseRoute = ParsedRoute('/demo', '/demo', {}, {});
    // const String baseRoute = DemoPage.baseRoute;
    // final signInRoute = ParsedRoute('/signin', '/signin', {}, {});

    // Go to /apply if the user is not signed in
    log("_guard signed in $from");
    // log("_guard JWT sub ${jwt_sub}");
    log("_guard from ${from.toString()}\n");
    if (!signedIn && from != signInRoute) {
      // Go to /signin if the user is not signed in
      return signInRoute;
    }
    // Go to /application if the user is signed in and tries to go to /signin.
    else if (signedIn && from == signInRoute) {
      return baseRoute;
    }
    return from;
  }

  void _handleAuthStateChanged() async {
    bool signedIn = await _auth.getSignedIn();
    log("_guard signed in _handleAuthStateChanged $signedIn");
    if (!signedIn) {
      _routeState.go('/subscribe');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: _buildStack,
    );
  }
}

class _SettingsIcon extends AnimatedWidget {
  const _SettingsIcon({
    required this.animationController,
    required this.toggleSettings,
    required this.isSettingsOpenNotifier,
  }) : super(listenable: animationController);

  final AnimationController animationController;
  final VoidCallback toggleSettings;
  final ValueNotifier<bool> isSettingsOpenNotifier;

  String _settingsSemanticLabel(bool isOpen, BuildContext context) {
    return isOpen
        ? GalleryLocalizations.of(context)!.settingsButtonCloseLabel
        : GalleryLocalizations.of(context)!.settingsButtonLabel;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    final safeAreaTopPadding = MediaQuery.of(context).padding.top;

    return Align(
      alignment: AlignmentDirectional.topEnd,
      child: Semantics(
        sortKey: const OrdinalSortKey(1),
        button: true,
        enabled: true,
        label: _settingsSemanticLabel(isSettingsOpenNotifier.value, context),
        child: SizedBox(
          width: _settingsButtonWidth,
          height: isDesktop
              ? _settingsButtonHeightDesktop
              : _settingsButtonHeightMobile + safeAreaTopPadding,
          child: Material(
            borderRadius: const BorderRadiusDirectional.only(
              bottomStart: Radius.circular(10),
            ),
            color:
                isSettingsOpenNotifier.value & !animationController.isAnimating
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.secondaryContainer,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                toggleSettings();
                SemanticsService.announce(
                  _settingsSemanticLabel(isSettingsOpenNotifier.value, context),
                  GalleryOptions.of(context).resolvedTextDirection()!,
                );
              },
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 3, end: 18),
                child: settings_icon.SettingsIcon(animationController.value),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
