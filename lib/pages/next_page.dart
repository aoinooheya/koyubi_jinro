import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/jinro_player.dart';
import 'package:myapp/pages/player_setting.dart';
import 'package:myapp/pages/thirteen_village.dart';
import 'package:myapp/pages/three_village.dart';

class NextPage extends StatelessWidget{
  NextPage({Key? key, required this.user}) : super(key: key);
  final User user;
  final _audio = AudioCache();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('やりたい村を選択してね＾ー＾'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 80,
              child: ElevatedButton(
                  onPressed: (){
                    _audio.play('sounds/onegaishimasu.mp3');
                    // Temporarily moves to ThirteenVillage
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ThirteenVillage()));
                  },
                  child: const Text('3人村')),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 80,
              child: ElevatedButton(
                  onPressed: (){
                    _audio.play('sounds/kaihatsuchu.mp3');
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => ThirteenVillage()));
                  },
                  child: const Text('13人村')),
            ),
            const SizedBox(height: 8),
            SizedBox(
              // width: 80,
              child: ElevatedButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerSetting(user: user)));
                  },
                  child: const Text('アカウント編集')),
            ),
          ],
        ),
      ),
    );
  }
}