import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:myapp/next_page.dart';
import 'package:firebase_core/firebase_core.dart';

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
            )
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

/////////////////////////////////////////////////////////////
// Debug IndexedStack
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
//       title: 'Debug IndexedStack',
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
//   JinroPlayerDebug aoi = JinroPlayerDebug();
//   // Index for switching icon view (0 is thumbnail, 1 is video)
//   int _iconIndex = 0;
//   void _changeIconIndex({required JinroPlayerDebug jinroplayer}){
//     setState(() {
//       jinroplayer.iconIndexDebug = 1;
//     });
//   }
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
//     // aoi.initialize(view: RTCVideoView(_localRenderer, mirror: true));
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
//             child: IndexedStack(
//               index: _iconIndex,
//               children: [
//                 Image.asset('assets/images/aoi.jpg'),
//                 RTCVideoView(_localRenderer, mirror: true),
//               ],
//             )
//           ),
//           aoi.createIconContainer(view: RTCVideoView(_localRenderer, mirror: true)),
//           Text(aoi.iconIndexDebug.toString())
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: const Icon(Icons.videocam),
//         onPressed: (){
//           openUserMedia(_localRenderer);
//           setState(() {
//             _iconIndex = 1; // For first icon
//             _changeIconIndex(jinroplayer: aoi);
//           });
//         },
//       ),
//     );
//   }
// }
//
// class JinroPlayerDebug{
//   late Container iconDebug;
//   late RTCVideoView viewDebug;
//   int iconIndexDebug = 0;
//
//   Container createIconContainer({required RTCVideoView view}) {
//     viewDebug = view;
//     return Container(
//         width: 100, height: 100,
//         child: IndexedStack(
//           index: iconIndexDebug,
//           children: [
//             Image.asset('assets/images/aoi.jpg'),
//             viewDebug,
//           ],
//         )
//     );
//   }
// }
// Debug IndexedStack End