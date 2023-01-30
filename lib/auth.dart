import 'dart:convert';
import 'dart:developer';
import 'dart:html';

import 'package:gallery/data/campus_apps_portal.dart';
import 'package:flutter/widgets.dart';

import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import 'package:http/http.dart' as http;
import './config/app_config.dart';

import 'package:jwt_decoder/jwt_decoder.dart';

/// A mock authentication service
class CampusAppsPortalAuth extends ChangeNotifier {
  bool _signedIn = false;
  var _openid_tokens;

  Future<bool> getSignedIn() async {
    log("_guard signed in uuuuuu");
    if (_signedIn)
      return _signedIn; // already signed in -- todo - remove before production release
    var tokens = window.localStorage['openid_client:tokens'];
    log("_guard signed in $tokens");
    if (tokens != null) {
      log("_guard signed in truetrue");
      _openid_tokens = json.decode(tokens);

      if (_openid_tokens != null && _openid_tokens['access_token'] != null) {
        _signedIn = true;
        print('OpenID tokens ##################');
        _openid_tokens.forEach((key, value) =>
            print("Access token -- Key : $key, Value : $value"));
        Map<String, dynamic> decodedAccessToken =
            JwtDecoder.decode(_openid_tokens["access_token"]);
        decodedAccessToken.forEach((key, value) =>
            print("access_token -- Key : $key, Value : $value"));

        // capture token information to help map the sing in user to Avinya person
        campusAppsPortalInstance.setJWTSub(decodedAccessToken["sub"]);
        campusAppsPortalInstance.setJWTEmail(decodedAccessToken["email"]);

        bool isTokenExpired = JwtDecoder.isExpired(_openid_tokens["id_token"]);
        print("Open ID token is expired $isTokenExpired");

        Map<String, dynamic> decodedIDToken =
            JwtDecoder.decode(_openid_tokens["id_token"]);
        decodedIDToken.forEach(
            (key, value) => print("id_token -- Key : $key, Value : $value"));
        print('email :: ' + decodedIDToken["email"]);

        if (isTokenExpired) {
          window.localStorage.remove('openid_client:tokens');
          window.localStorage.clear();
          _signedIn = false;
          return _signedIn;
        }

        if (AppConfig.apiTokens != null) {
          //use refresh token
          // however when app reloads, apiTokens will be null
          // should refresh token when calling APIs
        } else {
          log("in Auth -- choreoSTSClientID is :" +
              AppConfig.choreoSTSClientID);
          int count = 0;
          while (AppConfig.choreoSTSClientID.isEmpty && count < 10) {
            log(count.toString() + " in Auth -- choreoSTSClientID is empty");
            count++;
            if (count > 10) {
              break;
            }
            await Future.delayed(Duration(seconds: 1));
          }
          final response = await http.post(
            Uri.parse(AppConfig.choreoSTSEndpoint),
            headers: <String, String>{
              //'Content-Type': 'application/x-www-form-urlencoded',
              //'Authorization': 'Bearer ${_openid_tokens["access_token"]}',
              //'Authorization': 'Bearer ' + AppConfig.admissionsApplicationBffApiKey,
            },
            encoding: Encoding.getByName('utf-8'),
            body: {
              "client_id": AppConfig.choreoSTSClientID,
              "subject_token_type": "urn:ietf:params:oauth:token-type:jwt",
              "grant_type": "urn:ietf:params:oauth:grant-type:token-exchange",
              "subject_token": _openid_tokens["id_token"],
            },
          );
          if (response.statusCode == 200) {
            print(response.body.toString());
            var _api_tokens = json.decode(response.body);
            AppConfig.apiTokens = _api_tokens;
            print('API tokens ##################');
            _api_tokens
              ..forEach((key, value) =>
                  print("API tokens Key : $key, Value : $value"));
            AppConfig.campusAttendanceBffApiKey = _api_tokens["access_token"];
            print('Fetch API tokens success');
          } else {
            print('Failed to fetch API key');
            print('Fetch API tokens error :: ' + response.body.toString());
            print(response.statusCode);
            _signedIn = false;
          }
        }
      }
    } else {
      log("_guard _signedIn_signedIn in");
      _signedIn = false;
      window.localStorage.clear();
    }

    if (_signedIn) {
      campusAppsPortalInstance.fetchPersonForUser();
    }

    return _signedIn;
  }

  Future<void> logout() async {
    String logoutUrl = "https://api.asgardeo.io/t/avinyatest/oidc/logout";
    if (await canLaunchUrl(Uri.parse(logoutUrl))) {
      await launchUrl(Uri.parse(logoutUrl), mode: LaunchMode.platformDefault);
    } else {
      throw 'Could not launch $logoutUrl';
    }
    await Future.delayed(Duration(seconds: 3));
  }

  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    // Sign out.
    window.localStorage.clear();
    _signedIn = false;
    try {
      await logout();
    } catch (error) {
      log(error.toString());
    }
    notifyListeners();
  }

  Future<bool> signIn(String username, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Sign in. Allow any password.
    _signedIn = true;
    notifyListeners();
    return _signedIn;
  }

  @override
  bool operator ==(Object other) =>
      other is CampusAppsPortalAuth && other._signedIn == _signedIn;

  @override
  int get hashCode => _signedIn.hashCode;
}

class SMSAuthScope extends InheritedNotifier<CampusAppsPortalAuth> {
  const SMSAuthScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static CampusAppsPortalAuth of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SMSAuthScope>()!.notifier!;
}
