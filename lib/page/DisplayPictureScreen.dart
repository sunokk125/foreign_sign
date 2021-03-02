import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_foreign/service/GraphqlService.dart';
import 'package:flutter_foreign/graphql/QueryMutation.dart';
import 'package:geocoder/geocoder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import "package:http/http.dart" as http;
// 사용자가 촬영한 사진을 보여주는 위젯

class DisplayPictureScreen extends StatefulWidget {
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<DisplayPictureScreen> {
  Position position;
  String description;
  bool isPlaying = false;
  final FlutterTts _flutterTts = FlutterTts();
  String translation;
  File file;
  final String nodeEndPoint = 'http://10.1.78.245:3000/image';

  bool loading = false;

  void dispose() {
    print("dispose() of PlacePage");
    super.dispose();
  }

  void initState() {
    super.initState();
    if (!mounted) {
      return;
    }
  }

  Future<int> createRest(address) async {
    var result = await GraphqlService.futureMutation(
        QueryMutation.createRest(translation, address));
    return result.data['createRest']["resultCount"];
  }

  getAddress() async {
    final coordinates = new Coordinates(position.latitude, position.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    print("Address:${addresses.first.addressLine}");
    await createRest(addresses.first.addressLine).then((value) => {
          if (value == 1)
            {
              Fluttertoast.showToast(
                  msg: "Created address!!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0)
            }
          else if (value == null)
            {
              Fluttertoast.showToast(
                  msg: "Didn't create address!!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0)
            }
        });
  }

  Future<void> translate_eng() async {
    final translator = GoogleTranslator();
    print(description);
    var result = await translator.translate(description, from: 'ko', to: 'en');

    setState(() {
      translation = result.toString();
    });
    // prints Dart jest bardzo fajny!
  }

  Future<void> upload(file, nodeEndPoint) async {
    await Future.delayed(Duration(seconds: 2));
    if (file == null) return;
    String base64Img = base64Encode(file.readAsBytesSync());

    var response = await http.post(nodeEndPoint, body: {
      "image": base64Img,
    });
    var responseBody = json.decode(response.body);
    // print(responseBody[0]);

    setState(() {
      description = responseBody[0];
    });

    // for (var i = 0; i < responseBody.length; i++) {
    //   setState(() {
    //     description += responseBody[i];
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;

    String imagePath = args['path'];
    position = args['position'];
    file = File(imagePath);

    Future _speak() async {
      await _flutterTts.setLanguage("en_US");
      await _flutterTts.setPitch(1);
      await _flutterTts.setVoice({"name": "Karen", "locale": "en-US"});
      await _flutterTts.speak(translation);
    }

    return Scaffold(
        appBar: AppBar(title: Text('Display the Picture')),
        // 이미지는 디바이스에 파일로 저장됩니다. 이미지를 보여주기 위해 주어진
        // 경로로 `Image.file`을 생성하세요.
        body: SafeArea(
            child: SingleChildScrollView(
          child: translation != null
              ? Column(children: <Widget>[
                  Image.file(File(imagePath)),
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: Text(
                        "Korea : " + description,
                        style: TextStyle(fontSize: 16),
                      )),
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: Text(
                        "Eng : " + translation,
                        style: TextStyle(fontSize: 16),
                      )),
                  FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [Icon(Icons.record_voice_over), Text("Speak")],
                    ),
                    onPressed: () => _speak(),
                  ),
                  FlatButton(
                    child: Text("Add Shop"),
                    onPressed: () async {
                      await getAddress();
                    },
                  ),
                ])
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image.file(File(imagePath)),
                      loading != true
                          ? FlatButton(
                              child: Text("tranlate"),
                              onPressed: () {
                                setState(() {
                                  loading = true;
                                });
                                upload(file, nodeEndPoint)
                                    .then((value) => translate_eng());
                              },
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                CircularProgressIndicator(),
                                Text("loading ...."),
                              ],
                            )
                    ],
                  ),
                ),
        )));
  }
}
