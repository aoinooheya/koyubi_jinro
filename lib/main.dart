import 'dart:convert';
// import 'dart:html';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/jinro_player.dart';
import 'package:myapp/pages/next_page.dart';
import 'package:myapp/util_firebase.dart';
import 'package:path_provider/path_provider.dart';
import 'package:twitter_login/twitter_login.dart';

final infoTextProvider = StateProvider((ref) => '');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC2NMnW6VHDEBjdr1y7-F-MBLu2iv8kd9E",
      authDomain: "koyubijinro.firebaseapp.com",
      projectId: "koyubijinro",
      storageBucket: "koyubijinro.appspot.com",
      messagingSenderId: "420630967339",
      appId: "1:420630967339:web:b3f404144679c775b9e66e",
      measurementId: "G-LWJ1LB946C"
    )
  );
  runApp(const ProviderScope(child: MyApp()));
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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends HookConsumerWidget {
  MyHomePage({Key? key}) : super(key: key);
  final _audio = AudioCache();
  final UtilFirebase utilFirebase = UtilFirebase();
  // Email Registration&Login
  // final String email = "test@test.com";
  // final String password = "TESTTEST";

  // Twitter login
  // Future<UserCredential> signInWithTwitter() async {
  //   // Create a TwitterLogin instance
  //   final twitterLogin = TwitterLogin(
  //       apiKey: 'td7SDUJWIAlaABijo0ejc3S12',
  //       apiSecretKey:'VqJawqTJkK9GxN4RTP9LLLblToaWaXAf8jXYSDzzf2Di3UZt2v',
  //       redirectURI: 'koyubijinro://'
  //   );
  //   // Trigger the sign-in flow
  //   final authResult = await twitterLogin.login();
  //   // Create a credential from the access token
  //   final twitterAuthCredential = TwitterAuthProvider.credential(
  //     accessToken: authResult.authToken!,
  //     secret: authResult.authTokenSecret!,
  //   );
  //   // Once signed in, return the UserCredential
  //   return await FirebaseAuth.instance.signInWithCredential(twitterAuthCredential);
  // }

  void updateIconByLoginWithMediaAccess(
    JinroPlayerState jinroPlayer,
    JinroPlayerListNotifier jinroPlayerListNotifier
  ) async {
    String? playerName;
    String? thumbnail;

    // Obtain access to UserMedia (Video & Audio)
    var stream = await navigator.mediaDevices
        .getUserMedia({'video': true, 'audio': true});
    // Initially localStream is disabled
    stream.getAudioTracks()[0].enabled = false;
    stream.getVideoTracks()[0].enabled = false;

    // Try to get the user
    var userSnapshot = await FirebaseFirestore.instance.collection('users').
      doc(FirebaseAuth.instance.currentUser!.uid).get();
    // If the user exists
    if (userSnapshot.exists){
      var userData = userSnapshot.data() as Map<String, dynamic>;
      playerName = userData['playerName'];
      thumbnail = userData['thumbnail'];
    }
    // If the user doesn't exist
    else {
      playerName = FirebaseAuth.instance.currentUser!.displayName;
      thumbnail = FirebaseAuth.instance.currentUser!.photoURL;
    }

    // Update player icon
    jinroPlayerListNotifier.copyWith(
      jinroPlayerState: jinroPlayer,
      playerId: FirebaseAuth.instance.currentUser!.uid,
      playerName: playerName,
      thumbnail: thumbnail,
      stream: stream,
      view: RTCVideoView(jinroPlayer.renderer, mirror: true),
    );
    // Update Firestore
    utilFirebase.updateFirestore(
      jinroPlayer: jinroPlayer,
      playeName: playerName,
      thumbnail: thumbnail,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jinroPlayerList = ref.watch(jinroPlayerListNotifierProvider);
    final jinroPlayerListNotifier = ref.watch(jinroPlayerListNotifierProvider.notifier);
    final infoText = ref.watch(infoTextProvider);
    final infoTextNotifier = ref.watch(infoTextProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('こゆび人狼（仮）'),
      ),
      body:
      Center(
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
            const SizedBox(height: 8),
            // Sign in anonymously
            ElevatedButton(
              onPressed: () async {
                _audio.play('sounds/wakoyubi.mp3');
                await FirebaseAuth.instance.signInAnonymously();
                updateIconByLoginWithMediaAccess(jinroPlayerList[0], jinroPlayerListNotifier);
                Navigator.push(context, MaterialPageRoute(builder: (context) => NextPage()));
              },
              child: const Text('ゲストではじめる')
            ),
            // const SizedBox(height: 8),
            // Register by email&password
            // ElevatedButton(
            //   onPressed: () async {
            //     try {
            //       await FirebaseAuth.instance.createUserWithEmailAndPassword(
            //         email: email,
            //         password: password
            //       );
            //       // If success
            //       // setState(() {
            //       //   infoText = 'Ragistration Success';
            //       // });
            //     } catch (e) {
            //       // If not success
            //       // setState(() {
            //       //   infoText = 'Registration Not Success';
            //       // });
            //     }
            //   },
            //   child: const Text('メアドで新規登録')
            // ),
            // const SizedBox(height: 8),
            // Login by email&password
            // ElevatedButton(
            //   onPressed: () async {
            //     try {
            //       await FirebaseAuth.instance.signInWithEmailAndPassword(
            //         email: email,
            //         password: password
            //       );
            //       // If success
            //       // setState(() {
            //       //   infoText = 'Login Success';
            //       // });
            //     } catch (e) {
            //       // setState(() {
            //       //   infoText = 'Login Not Success';
            //       // });
            //     }
            //   },
            //   child: const Text('メアドでログイン')
            // ),
            const SizedBox(height: 8),
            // Google sign in
            ElevatedButton(
              onPressed: () async {
                try {
                  // Trigger the authentication flow
                  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
                  // Obtain the auth details from the request
                  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
                  // Create a new credential
                  final credential = GoogleAuthProvider.credential(
                    accessToken: googleAuth?.accessToken,
                    idToken: googleAuth?.idToken,
                  );
                  // Once signed in, return the UserCredential
                  await FirebaseAuth.instance.signInWithCredential(credential);
                  updateIconByLoginWithMediaAccess(jinroPlayerList[0], jinroPlayerListNotifier);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NextPage()));
                } catch (e) {
                  infoTextNotifier.update((state) => "登録に失敗しました");
                }
              },
              child: const Text('Googleでログイン')
            ),
            // const SizedBox(height: 8),
            // Twitter login
            // ElevatedButton(
            //     onPressed: () async {
            //       signInWithTwitter();
            //     },
            //     child: const Text('Twitterでログイン')
            // ),
            const SizedBox(height: 8),
            Text(infoText),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////
// // main Firebase
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: const FirebaseOptions(
//         apiKey: "AIzaSyC2NMnW6VHDEBjdr1y7-F-MBLu2iv8kd9E",
//         appId: "1:420630967339:web:b3f404144679c775b9e66e",
//         messagingSenderId: "G-LWJ1LB946C",
//         projectId: "koyubijinro"
//     )
//   );
//   runApp(const ProviderScope(child: MyApp()));
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'debug',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: View(),
//     );
//   }
// }
//
// class View extends HookConsumerWidget{
//   View({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: () {
//               },
//               child: Text('')
//             ) ,
//           ]
//         )
//       )
//     );
//   }
// }
//////////////////////////////////////
// main Image Uplaod
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: const FirebaseOptions(
//       apiKey: "AIzaSyC2NMnW6VHDEBjdr1y7-F-MBLu2iv8kd9E",
//       authDomain: "koyubijinro.firebaseapp.com",
//       projectId: "koyubijinro",
//       storageBucket: "koyubijinro.appspot.com",
//       messagingSenderId: "420630967339",
//       appId: "1:420630967339:web:b3f404144679c775b9e66e",
//       measurementId: "G-LWJ1LB946C"
//     )
//   );
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const MyHomePage(),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   Image? _img;
//   Text? _text;
//
//   Future<void> _download() async {
//     FirebaseStorage storage = FirebaseStorage.instance;
//     print('Here0');
//
//     // テキスト
//     // Reference textRef = storage.ref("DL/hello.txt");
//     // var data = await textRef.getData();
//     // print('Here1');
//
//     // 画像
//     // Reference imageRef = storage.ref("DL/icon.png");
//     Reference imageRef = storage.ref("UL/upload-pic.png");
//     String imageUrl = await imageRef.getDownloadURL();
//     print('Here2');
//
//     // 画面に反映
//     setState(() {
//       _img = Image.network(imageUrl);
//       // _text = Text(ascii.decode(data!));
//     });
//     print('Here3');
//
//     // Save locally
//     // Directory appDocDir = await getApplicationDocumentsDirectory();
//     // File downloadToFile = File("${appDocDir.path}/download-logo.png");
//     // try {
//     //   await imageRef.writeToFile(downloadToFile);
//     // } catch (e) {
//     //   print(e);
//     // }
//   }
//
//   void _upload() async {
//     // imagePickerで画像を選択する
//     XFile? pickerFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickerFile != null) {
//       print('Full path = ${pickerFile.path}');
//       try {
//         await FirebaseStorage.instance.ref("UL/upload-pic.png").putData(await pickerFile.readAsBytes());
//       } catch (e) {
//         print(e);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             if (_text != null) _text!,
//             if (_img != null) _img!,
//           ],
//         ),
//       ),
//       floatingActionButton:
//       Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//         FloatingActionButton(
//           onPressed: _download,
//           child: const Icon(Icons.download_outlined),
//         ),
//         FloatingActionButton(
//           onPressed: _upload,
//           child: const Icon(Icons.upload_outlined),
//         ),
//         FloatingActionButton(
//           onPressed: () async {
//             ListResult result = await FirebaseStorage.instance.ref().listAll();
//             for (var ref in result.prefixes) {
//               print('list = $ref');
//             }
//           },
//           child: const Icon(Icons.upload),
//         ),
//       ])
//     );
//   }
// }