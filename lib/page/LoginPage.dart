import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_foreign/service/GraphqlService.dart';

class LoginPage extends StatefulWidget {
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<LoginPage> {
  //facebook login end

  //googlelogin start

  void dispose() {
    print("dispose() of LoginPage");
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          )),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 200, 0, 100),
                    child: Text(
                      "Welcome",
                      style: TextStyle(color: Colors.white, fontSize: 48),
                    ),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 100),
                  GoogleSignInButton(onPressed: () {
                    GraphqlService.googleLogin(context);
                  }),
                  FacebookSignInButton(onPressed: () {
                    GraphqlService.facebookLogin(context);
                  }),
                ],
              )
            ],
          )),
    );
  }
}
