import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/jinro_player.dart';
import 'package:myapp/pages/player_setting.dart';
import 'package:myapp/pages/three_village.dart';

class NextPage extends HookConsumerWidget{
  NextPage({Key? key}) : super(key: key);
  final _audio = AudioCache();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jinroPlayer = ref.watch(jinroPlayerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('やりたい村を選択してね＾ー＾'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            jinroPlayer[0].playerIcon,
            const SizedBox(height: 8),
            SizedBox(
              // width: 80,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.black38),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerSetting()));
                },
                child: const Text('アカウント編集'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 80,
              child: ElevatedButton(
                  onPressed: (){
                    _audio.play('sounds/onegaishimasu.mp3');
                    // Temporarily moves to ThirteenVillage
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ThreeVillage()));
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
          ],
        ),
      ),
    );
  }
}