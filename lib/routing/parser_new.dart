import 'dart:developer';
import 'dart:html';

import 'package:flutter/widgets.dart';
import 'package:path_to_regexp/path_to_regexp.dart';

import 'parsed_route.dart';

/// Used by [TemplateRouteParser] to guard access to routes.
typedef RouteGuard<T> = Future<T> Function(T from);

/// Parses the URI path into a [RouteSettings].
class TemplateRouteParser extends RouteInformationParser<RouteSettings> {
  final List<String> _pathTemplates;
  final RouteGuard<RouteSettings>? guard;
  final RouteSettings initialRoute;

  TemplateRouteParser({
    /// The list of allowed path templates (['/', '/users/:id'])
    required List<String> allowedPaths,

    /// The initial route
    String initialRoute = '/',

    ///  [RouteGuard] used to redirect.
    this.guard,
  })  : initialRoute = RouteSettings(name: '/', arguments: null),
        _pathTemplates = [
          ...allowedPaths,
        ],
        assert(allowedPaths.contains(initialRoute));

  @override
  Future<RouteSettings> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    log("mypath :  ");
    final path = routeInformation.location!;

    String mypath = '';
    if (routeInformation.location != null) {
      mypath = routeInformation.location!;
    }
    if (mypath.contains('access_token')) {
      log("mypath :  $mypath");
      log(window.location.href);
      var uri = Uri.dataFromString(window.location.href);
      log('query params ' + uri.queryParameters.toString());
      log(_pathTemplates.toString());
    }

    final queryParams = Uri.parse(path).queryParameters;
    var parsedRoute = initialRoute;

    for (var pathTemplate in _pathTemplates) {
      final parameters = <String>[];
      var pathRegExp = pathToRegExp(pathTemplate, parameters: parameters);
      if (pathRegExp.hasMatch(path)) {
        final match = pathRegExp.matchAsPrefix(path);
        if (match == null) continue;
        final params = extract(parameters, match);
        parsedRoute = RouteSettings(name: path, arguments: pathTemplate);
      }
    }

    log(parsedRoute.toString());

    // Redirect if a guard is present
    var guard = this.guard;
    if (guard != null) {
      return guard(parsedRoute);
    }

    return parsedRoute;
  }

  @override
  RouteInformation restoreRouteInformation(RouteSettings configuration) =>
      RouteInformation(location: configuration.name);
}
