import 'dart:async';
import 'dart:convert' show json;

import "package:http/http.dart" as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_foreign/graphql/QueryMutation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:path/path.dart';

class GraphqlService {
  static var _token;
  static var _email;
  static var _userName;
  static var _userIdx;
  static bool _gf;

  static final HttpLink httpLink =
      HttpLink(uri: "http://10.1.78.245:3000/graphql");

  static setToken(
      String token, String userIdx, String email, String name, bool gf) {
    _token = token;
    _email = email;
    _userIdx = userIdx;
    _userName = name;
    _gf = gf;
  }

  static deleteToken() {
    _token = null;
    _email = null;
    _gf = null;
  }

  static bool checkToken() {
    if (_token != null)
      return true;
    else
      return false;
  }

  static String getIdx() {
    print(_userIdx);
    return _userIdx;
  }

  static String getEmail() {
    print(_email);
    return _email;
  }

  static String getName() {
    print(_userName);
    return _userName;
  }

  static bool getGf() {
    print(_gf);
    return _gf;
  }

  static final AuthLink authLink = AuthLink(getToken: () => _token);

  static final Link link = authLink.concat(httpLink);

  static ValueNotifier<GraphQLClient> client() {
    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        cache: OptimisticCache(dataIdFromObject: typenameDataIdFromObject),
        link: link,
      ),
    );
    return client;
  }

  static Future<dynamic> futureQuery(String queryMethod) {
    return new Future.delayed(new Duration(seconds: 0), () async {
      return await client().value.query(QueryOptions(
            // ignore: deprecated_member_use
            document: queryMethod,
          ));
    });
  }

  static Future<dynamic> futureMutation(String mutationMethod) {
    return new Future.delayed(new Duration(seconds: 0), () async {
      return await client().value.mutate(MutationOptions(
            // ignore: deprecated_member_use
            document: mutationMethod,
          ));
    });
  }

  static void facebookLogin(context) async {
    final facebookLogin = FacebookLogin();
    final facebookLoginResult = await facebookLogin.logIn(['email']);

    print(facebookLoginResult.accessToken);
    print(facebookLoginResult.accessToken.token);
    print(facebookLoginResult.accessToken.expires);
    print(facebookLoginResult.accessToken.permissions);
    print(facebookLoginResult.accessToken.userId);
    print(facebookLoginResult.accessToken.isValid());

    print(facebookLoginResult.errorMessage);
    print(facebookLoginResult.status);

    final token = facebookLoginResult.accessToken.token;

    /// for profile details also use the below code
    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
    final profile = json.decode(graphResponse.body);
    print(profile['email']);
    isUser(profile['email'], profile['name'], false, context);
  }

  static void googleLogin(context) async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        // you can add extras if you require
      ],
    );

    _googleSignIn.signIn().then((GoogleSignInAccount acc) async {
      GoogleSignInAuthentication auth = await acc.authentication;
      print(acc.id);
      print(acc.email);
      print(acc.displayName);
      print(acc.photoUrl);

      acc.authentication.then((GoogleSignInAuthentication auth) async {
        print(auth.idToken);
        print(auth.accessToken);
        isUser(acc.email, acc.displayName, true, context);
      });
    });
  }

  static void isUser(
      String email, String name, bool gf, BuildContext context) async {
    var userEmail = email;
    var userName = name;

    var login = await futureMutation(QueryMutation.login(userEmail, userName));
    String jwtToken = login.data['login']['token'];
    String userIdx = login.data['login']['user']['user_idx'];
    setToken(jwtToken, userIdx, userEmail, name, gf);
    Navigator.pushReplacementNamed(context, '/main');
  }

  static void logout() async {
    if (_gf) {
      GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
        ],
      );
      _googleSignIn.disconnect();
    } else {
      final facebookLogin = FacebookLogin();
      await facebookLogin.logOut();
    }
    deleteToken();
    print(_token);
  }
}
