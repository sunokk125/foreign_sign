import 'package:flutter/material.dart';
import 'package:flutter_foreign/page/DetailRestPage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_foreign/page/LoginPage.dart';
import 'package:flutter_foreign/page/MainPage.dart';
import 'package:flutter_foreign/page/DisplayPictureScreen.dart';
import 'package:flutter_foreign/service/GraphqlService.dart';

GraphqlService graphqlService = GraphqlService();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    GraphQLProvider(
      client: GraphqlService.client(),
      child: CacheProvider(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginPage(),
          '/main': (context) => MainPage(),
          '/display': (context) => DisplayPictureScreen(),
          '/detailRest': (context) => DetailRestPage(),
        });
  }
}
