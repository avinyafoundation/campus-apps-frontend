import 'dart:developer';
import 'package:flutter/material.dart';

import '../../auth.dart';
import '../../routing.dart';
import '../../pages/login.dart';
import '../../main.dart';
import '../../widgets/fade_transition_page.dart';

/// Builds the top-level navigator for the app. The pages to display are based
/// on the `routeState` that was parsed by the TemplateRouteParser.
class SMSNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const SMSNavigator({
    required this.navigatorKey,
    super.key,
  });

  @override
  State<SMSNavigator> createState() => _SMSNavigatorState();
}

class _SMSNavigatorState extends State<SMSNavigator> {
  final _signInKey = const ValueKey('Sign in');
  final _galleryKey = const ValueKey('Gallery');

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final authState = SMSAuthScope.of(context);
    final pathTemplate = routeState.route.pathTemplate;

    if (pathTemplate == '/#access_token') {
      log('Navigator $routeState.route.parameters.toString()');
      log('Navigator $routeState.route.queryParameters.toString()');
    }

    return Navigator(
      key: widget.navigatorKey,
      pages: [
        if (routeState.route.pathTemplate == '/signin')
          // Display the sign in screen.
          FadeTransitionPage<void>(
            key: _signInKey,
            child: LogInScreen(
              onSignIn: (credentials) async {
                var signedIn = await authState.signIn(
                    credentials.username, credentials.password);
                if (signedIn) {
                  await routeState.go('/gallery');
                }
              },
            ),
          )
        else if (routeState.route.pathTemplate == '/gallery')
          // Display the sign in screen.
          FadeTransitionPage<void>(
            key: _galleryKey,
            child: GalleryApp(),
          )
      ],
    );
  }
}
