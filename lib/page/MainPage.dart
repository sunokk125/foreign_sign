import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_foreign/page/HomePage.dart';
import 'package:flutter_foreign/page/PlacePage.dart';
import 'package:flutter_foreign/service/GraphqlService.dart';

class MainPage extends StatefulWidget {
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<MainPage> {
  final List<Widget> _children = [PlacePage(), HomePage()];
  int _currentIndex = 1;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  String email;

  void _onItemTapped(int index) {
    index == 2
        ? _drawerKey.currentState.openEndDrawer()
        : setState(() {
            _currentIndex = index;
          });
  }

  void dispose() {
    print("dispose() of LoginPage");
    super.dispose();
  }

  void initState() {
    super.initState();
    if (!mounted) {
      return;
    }
    setState(() {
      email = GraphqlService.getEmail();
      print("email:" + email);
    });
  }

  @override
  Widget build(BuildContext context) {
    return (email != null)
        ? Scaffold(
            key: _drawerKey,
            body: _children.elementAt(_currentIndex),
            endDrawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    child: Row(
                      children: <Widget>[Icon(Icons.person), Text(email)],
                    ),
                  ),
                  ListTile(
                      title: Text('Logout'),
                      onTap: () async {
                        GraphqlService.logout();
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/', (route) => false);
                      }),
                  ListTile(
                      title: Text('Close'),
                      onTap: () {
                        Navigator.pop(context);
                      })
                ],
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                onTap: _onItemTapped,
                selectedItemColor: Color.fromRGBO(52, 73, 94, 1),
                currentIndex: _currentIndex,
                items: [
                  new BottomNavigationBarItem(
                      icon: Icon(Icons.place), label: "Place"),
                  new BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: "Home"),
                  new BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: "MyPage",
                  ),
                ]),
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                Text("loading ...."),
              ],
            ),
          );
  }
}
