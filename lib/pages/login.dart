import 'dart:developer';
import 'dart:io';

import 'package:gallery/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:openid_client/openid_client_browser.dart';

class Credentials {
  final String username;
  final String password;

  Credentials(this.username, this.password);
}

class LoginPage extends StatefulWidget {
  // final ValueChanged<Credentials> onSignIn;

  const LoginPage({
    // required this.onSignIn,
    super.key,
  });

  @override
  State<LoginPage> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LoginPage> {
  String _clientId = AppConfig.asgardeoClientId;
  final String _issuerUrl = AppConfig.asgardeoTokenEndpoint;

  final List<String> _scopes = <String>[
    'openid',
    'profile',
    'email',
    'groups',
    'address',
    'phone'
  ];

  @override
  Widget build(BuildContext context) {
    log("in signin build -- asgardeoClientId is :" +
        AppConfig.asgardeoClientId);
    int count = 0;
    while (_clientId.isEmpty && count < 10) {
      log(count.toString() + " in Auth -- asgardeoClientId is empty");
      count++;
      if (count > 10) {
        break;
      }
      sleep(Duration(seconds: 1));
      _clientId = AppConfig.asgardeoClientId;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign in"),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Container(
                    alignment: Alignment.center,
                    child: Wrap(children: [
                      Column(children: [
                        Text(
                          "Avinya Academy Apps Portal",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Google Sans",
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          """To proceed to the Apps Portal, please sign in.""",
                          style: TextStyle(
                            fontFamily: "Google Sans",
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          "Once you sign in, you will be directed to the Apps Portal",
                          style: TextStyle(
                            fontFamily: "Google Sans",
                          ),
                        ),
                        SizedBox(height: 10.0),
                      ]),
                    ]),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.yellowAccent),
                    shadowColor: MaterialStateProperty.all(Colors.lightBlue),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/login.png',
                        fit: BoxFit.contain,
                        width: 40,
                      ),
                      Text(
                        "Login with Asgardeo",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Google Sans",
                        ),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    await authenticate(
                        Uri.parse(_issuerUrl), _clientId, _scopes);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  authenticate(Uri uri, String clientId, List<String> scopes) async {
    log("signin authenticate - Client ID :: " + clientId);
    // create the client
    var issuer = await Issuer.discover(uri);
    var client = new Client(issuer, clientId);

    // create an authenticator
    var authenticator = new Authenticator(client, scopes: scopes);

    // starts the authentication
    authenticator.authorize();
  }
}
