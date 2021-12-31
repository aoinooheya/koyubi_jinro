import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:myapp/next_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyC2NMnW6VHDEBjdr1y7-F-MBLu2iv8kd9E",
        appId: "1:420630967339:web:b3f404144679c775b9e66e",
        messagingSenderId: "G-LWJ1LB946C",
        projectId: "koyubijinro"
    )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Koyubi Jinro',
      theme:
      // ThemeData.dark(),
      ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _audio = AudioCache();
  // Register&Login
  String email = "test@test.com";
  String password = "TESTTEST";
  String infoText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('こゆび人狼（仮）'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('ネット対面人狼アプリ'),
            Text(
              'こゆび人狼（仮）',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              '※音量注意',
              style: Theme.of(context).textTheme.headline5,
            ),
            ElevatedButton(
              onPressed: (){
                _audio.play('sounds/wakoyubi.mp3');
                Navigator.push(context, MaterialPageRoute(builder: (context) => NextPage()));
              },
              child: const Text('はじめる')
            ),
            const SizedBox(height: 8),
            // Register by email&password
            ElevatedButton(
              onPressed: () async {
                try {
                  final FirebaseAuth auth = FirebaseAuth.instance;
                  await auth.createUserWithEmailAndPassword(
                    email: email,
                    password: password
                  );
                  // If success
                  setState(() {
                    infoText = 'Ragistration Success';
                  });
                } catch (e) {
                  // If not success
                  setState(() {
                    infoText = 'Registration Not Success';
                  });
                }
              },
              child: const Text('新規登録')
            ),
            // Login by email&password
            ElevatedButton(
              onPressed: () async {
                try {
                  final FirebaseAuth auth = FirebaseAuth.instance;
                  await auth.signInWithEmailAndPassword(
                    email: email,
                    password: password
                  );
                  // If success
                  setState(() {
                    infoText = 'Login Success';
                  });
                } catch (e) {
                  setState(() {
                    infoText = 'Login Not Success';
                  });
                }
              },
              child: const Text('ログイン')
            ),
            Text(infoText),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////
// Debug RTCVideoview
// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
//
// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Debug RTCVideoview',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const MyHomePage(),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
//
//   Future<void> openUserMedia(RTCVideoRenderer localVideo) async {
//     // Obtain access to UserMedia (Video)
//     var stream = await navigator.mediaDevices.getUserMedia({'video': true});
//     // Open localVideo
//     localVideo.srcObject = stream;
//   }
//
//   @override
//   void initState() {
//     _localRenderer.initialize();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Container(
//             width: 100, height: 100,
//             color: Colors.blue.withOpacity(0.5),
//             child: RTCVideoView(_localRenderer, mirror: true),
//           ),
//           Container(
//             width: 100, height: 100,
//             color: Colors.orange.withOpacity(0.5),
//             child: RTCVideoView(_localRenderer, mirror: true),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: const Icon(Icons.videocam),
//         onPressed: (){
//           openUserMedia(_localRenderer);
//         },
//       ),
//     );
//   }
// }
// Debug RTCVideoview End
