import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';

var firstCamera;
CameraController _controller;
Future<void> _initializeControllerFuture;
Position position;

Future<void> getCamera() async {
  final cameras = await availableCameras();
  firstCamera = cameras.first;
  _controller = CameraController(
    // 이용 가능한 카메라 목록에서 특정 카메라를 가져옵니다.
    firstCamera,
    // 적용할 해상도를 지정합니다.
    ResolutionPreset.medium,
  );
  // 다음으로 controller를 초기화합니다. 초기화 메서드는 Future를 반환합니다.
  _initializeControllerFuture = _controller.initialize();
}

class HomePage extends StatefulWidget {
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    if (!mounted) {
      return;
    }
    getCamera().then((_) {
      setState(() {});
    });
    getLocation();
    // 카메라의 현재 출력물을 보여주기 위해 CameraController를 생성합니다.
  }

  Future<void> getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {});
  }

  void dispose() {
    print("dispose() of LoginPage");
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.camera),
        backgroundColor: Color.fromRGBO(52, 73, 94, 1),
        onPressed: () async {
          // try / catch 블럭에서 사진을 촬영합니다. 만약 뭔가 잘못된다면 에러에
          // 대응할 수 있습니다.
          try {
            // 카메라 초기화가 완료됐는지 확인합니다.
            await _initializeControllerFuture;

            // path 패키지를 사용하여 이미지가 저장될 경로를 지정합니다.
            final path = join(
              // 본 예제에서는 임시 디렉토리에 이미지를 저장합니다. `path_provider`
              // 플러그인을 사용하여 임시 디렉토리를 찾으세요.
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );

            // 사진 촬영을 시도하고 저장되는 경로를 로그로 남깁니다.
            await _controller.takePicture(path);

            // 사진을 촬영하면, 새로운 화면으로 넘어갑니다.
            Navigator.pushNamed(context, '/display',
                arguments: <String, dynamic>{
                  'path': path,
                  'position': position
                });
          } catch (e) {
            // 만약 에러가 발생하면, 콘솔에 에러 로그를 남깁니다.
            print(e);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Future가 완료되면, 프리뷰를 보여줍니다.
            return CameraPreview(_controller);
          } else {
            // 그렇지 않다면, 진행 표시기를 보여줍니다.
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                TextButton(
                  child: Text("setcamera"),
                  onPressed: () {
                    setState(() {});
                  },
                )
              ],
            ));
          }
        },
      ),
    );
  }
}
