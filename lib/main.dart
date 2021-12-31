import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/player_setting.dart';
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
  // Email Registration&Login
  String email = "test@test.com";
  String password = "TESTTEST";
  String infoText = "";

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
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: (){
                _audio.play('sounds/wakoyubi.mp3');
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PlayerSetting()));
              },
              child: const Text('ゲストではじめる')
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
              child: const Text('メアドで新規登録')
            ),
            const SizedBox(height: 8),
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
                    final result = await FirebaseAuth.instance.signInWithCredential(credential);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerSetting(user: result.user)));
                  } catch (e) {
                    setState(() {
                      infoText = "登録に失敗しました：${e.toString()}";
                    });
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