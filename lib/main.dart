import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/jinro_player.dart';
import 'package:myapp/pages/next_page.dart';
import 'package:twitter_login/twitter_login.dart';

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
  // Email Registration&Login
  final String email = "test@test.com";
  final String password = "TESTTEST";
  final String infoText = "";

  // Twitter login
  Future<UserCredential> signInWithTwitter() async {
    // Create a TwitterLogin instance
    final twitterLogin = TwitterLogin(
        apiKey: 'td7SDUJWIAlaABijo0ejc3S12',
        apiSecretKey:'VqJawqTJkK9GxN4RTP9LLLblToaWaXAf8jXYSDzzf2Di3UZt2v',
        redirectURI: 'koyubijinro://'
    );
    // Trigger the sign-in flow
    final authResult = await twitterLogin.login();
    // Create a credential from the access token
    final twitterAuthCredential = TwitterAuthProvider.credential(
      accessToken: authResult.authToken!,
      secret: authResult.authTokenSecret!,
    );
    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(twitterAuthCredential);
  }

  Future<void> createIconByLoginWithMediaAccess(
    JinroPlayerState jinroPlayer,
    JinroPlayerNotifier jinroPlayerNotifier
  ) async {
    // Couldn't use initialize() because the view wasn't displayed properly.
    // Undesirable when switching the player's account.
    // jinroPlayerNotifier.initialize();

    // Obtain access to UserMedia (Video & Audio)
    var stream = await navigator.mediaDevices
        .getUserMedia({'video': true, 'audio': true});
    // Initially localStream is disabled
    stream.getAudioTracks()[0].enabled = false;
    stream.getVideoTracks()[0].enabled = false;

    jinroPlayerNotifier.copyWith(
      playerName: FirebaseAuth.instance.currentUser!.displayName,
      thumbnail: FirebaseAuth.instance.currentUser!.photoURL,
      localStream: stream,
      view: RTCVideoView(jinroPlayer.renderer, mirror: true),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jinroPlayer = ref.read(jinroPlayerProvider);
    final jinroPlayerNotifier = ref.read(jinroPlayerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('こゆび人狼（仮）'),
      ),
      body:
      // const TodoWidget(),
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
                createIconByLoginWithMediaAccess(jinroPlayer, jinroPlayerNotifier);
                Navigator.push(context, MaterialPageRoute(builder: (context) => NextPage()));
              },
              child: const Text('ゲストではじめる')
            ),
            const SizedBox(height: 8),
            // Register by email&password
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: email,
                    password: password
                  );
                  // If success
                  // setState(() {
                  //   infoText = 'Ragistration Success';
                  // });
                } catch (e) {
                  // If not success
                  // setState(() {
                  //   infoText = 'Registration Not Success';
                  // });
                }
              },
              child: const Text('メアドで新規登録')
            ),
            const SizedBox(height: 8),
            // Login by email&password
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email,
                    password: password
                  );
                  // If success
                  // setState(() {
                  //   infoText = 'Login Success';
                  // });
                } catch (e) {
                  // setState(() {
                  //   infoText = 'Login Not Success';
                  // });
                }
              },
              child: const Text('メアドでログイン')
            ),
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
                    createIconByLoginWithMediaAccess(jinroPlayer, jinroPlayerNotifier);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NextPage()));
                  } catch (e) {
                    // setState(() {
                    //   infoText = "登録に失敗しました：${e.toString()}";
                    // });
                  }
                },
                child: const Text('Googleでログイン')
            ),
            const SizedBox(height: 8),
            // Twitter login
            ElevatedButton(
                onPressed: () async {
                  signInWithTwitter();
                },
                child: const Text('Twitterでログイン')
            ),
            const SizedBox(height: 8),
            Text(infoText),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////
// final playerProvider = StateNotifierProvider<PlayerStateNotifier, PlayerState>((ref) => PlayerStateNotifier());
//
// class PlayerStateNotifier extends StateNotifier<PlayerState>{
//   PlayerStateNotifier(): super(PlayerState());
//
//   // void initialize(){
//   //   state = PlayerState();
//   // }
//
//   void copyWith({
//     MediaStream? localStream,
//     RTCVideoRenderer? renderer,
//     RTCVideoView? view,
//   }){
//     localStream ??= state.localStream;
//     renderer ??= state.renderer;
//     view ??= state.view;  // Used for mirror the view
//     state = PlayerState(
//       localStream: localStream,
//       renderer: renderer,
//       view: view,
//     );
//   }
// }
//
// class PlayerState {
//   PlayerState({
//     this.localStream,
//     RTCVideoRenderer? renderer,
//     RTCVideoView? view,
//   }){
//     print('localStream = $localStream');
//     renderer == null ? this.renderer.initialize() : this.renderer = renderer;
//     this.renderer.srcObject = localStream;
//     print('renderer.srcObject = ${renderer?.srcObject}');
//     view == null ? this.view = RTCVideoView(this.renderer) : this.view = view;
//     print('view = $view');
//
//     icon = Container(
//         width: 100, height: 100,
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey, width: 2.0),
//         ),
//         child: this.view,
//       );
//   }
//
//   MediaStream? localStream;
//   RTCVideoRenderer renderer = RTCVideoRenderer();
//   late RTCVideoView view;
//
//   late Container icon;
// }
//
// class View extends HookConsumerWidget{
//   const View({Key? key}) : super(key: key);
//
//   Future<void> mediaAccess(
//     PlayerState player,
//     PlayerStateNotifier playerNotifier
//   ) async {
//     // playerNotifier.initialize();
//     var stream = await navigator.mediaDevices.getUserMedia({'video': true, 'audio': true});
//     print('stream = $stream');
//     playerNotifier.copyWith(
//       localStream: stream,
//       view: RTCVideoView(player.renderer, mirror: true)
//     );
//   }
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final player = ref.watch(playerProvider);
//     final playerNotifier = ref.watch(playerProvider.notifier);
//     return ElevatedButton(
//       onPressed: () async {
//         mediaAccess(player, playerNotifier);
//       },
//       child: player.icon
//     );
//   }
// }