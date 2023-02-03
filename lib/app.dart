// import 'dart:developer';

// // import 'package:gallery/data/admission_system.dart';
// import 'package:flutter/material.dart';
// import 'package:gallery/routing/route_state_new.dart';

// import 'auth.dart';
// import 'routing.dart';
// import 'pages/navigator.dart';

// class AppsPortal extends StatefulWidget {
//   const AppsPortal({super.key});

//   @override
//   State<AppsPortal> createState() => _AppsPortalState();
// }

// class _AppsPortalState extends State<AppsPortal> {
//   final _auth = CampusAppsPortalAuth();
//   final _navigatorKey = GlobalKey<NavigatorState>();
//   late final RouteState _routeState;
//   late final SimpleRouterDelegate _routerDelegate;
//   late final TemplateRouteParser _routeParser;

//   @override
//   void initState() {
//     log('signedIn 1:uuuuu');

//     /// Configure the parser with all of the app's allowed path templates.
//     // _routeParser = TemplateRouteParser(
//     //   allowedPaths: [
//     //     '/signin',
//     //     '/#access_token',
//     //   ],
//     //   guard: _guard,
//     //   initialRoute: '/signin',
//     // );

//     _routeState = RouteState(_routeParser);

//     _routerDelegate = SimpleRouterDelegate(
//       routeState: _routeState,
//       navigatorKey: _navigatorKey,
//       builder: (context) => SMSNavigator(
//         navigatorKey: _navigatorKey,
//       ),
//     );

//     // Listen for when the user logs out and display the signin screen.
//     _auth.addListener(_handleAuthStateChanged);

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) => RouteStateScope(
//         notifier: _routeState,
//         child: SMSAuthScope(
//           notifier: _auth,
//           child: MaterialApp.router(
//             routerDelegate: _routerDelegate,
//             routeInformationParser: _routeParser,
//             // Revert back to pre-Flutter-2.5 transition behavior:
//             // https://github.com/flutter/flutter/issues/82053
//             theme: ThemeData(
//               pageTransitionsTheme: const PageTransitionsTheme(
//                 builders: {
//                   TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
//                   TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
//                   TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
//                   TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
//                   TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
//                 },
//               ),
//             ),
//           ),
//         ),
//       );

//   Future<ParsedRoute> _guard(ParsedRoute from) async {
//     final signedIn = await _auth.getSignedIn();
//     // String? jwt_sub = admissionSystemInstance.getJWTSub();

//     final signInRoute = ParsedRoute('/signin', '/signin', {}, {});

//     // Go to /apply if the user is not signed in
//     log("_guard signed in $signedIn");
//     // log("_guard JWT sub ${jwt_sub}");
//     log("_guard from ${from.toString()}\n");
//     if (!signedIn && from != signInRoute) {
//       // Go to /signin if the user is not signed in
//       return signInRoute;
//     }
//     // Go to /application if the user is signed in and tries to go to /signin.
//     else if (signedIn && from == signInRoute) {
//       return ParsedRoute('/application', '/application', {}, {});
//     }
//     return from;
//   }

//   void _handleAuthStateChanged() async {
//     bool signedIn = await _auth.getSignedIn();
//     if (!signedIn) {
//       _routeState.go('/subscribe');
//     }
//   }

//   @override
//   void dispose() {
//     _auth.removeListener(_handleAuthStateChanged);
//     _routeState.dispose();
//     _routerDelegate.dispose();
//     super.dispose();
//   }
// }
