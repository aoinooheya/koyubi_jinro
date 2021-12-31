import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:myapp/next_page.dart';
import 'jinro_player.dart';

class PlayerSetting extends StatefulWidget{
  const PlayerSetting({Key? key, this.user}) : super(key: key);
  final User? user;
  @override
  _PlayerSetting createState() => _PlayerSetting();
}

class _PlayerSetting extends State<PlayerSetting> {
  JinroPlayer guest = JinroPlayer();
  TextEditingController textEditingControllerName = TextEditingController(text: '');

  @override
  Widget build(BuildContext context){
    guest.setView(view: RTCVideoView(guest.renderer, mirror: true));
    return Scaffold(
      appBar: AppBar(
        title: const Text('プレイヤー設定＾ー＾'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            guest.createIcon(),
            // Set player's name
            SizedBox(
              width: 130,
              child: TextFormField(
                controller: textEditingControllerName,
                decoration: const InputDecoration(
                  hintText: '名前を入力してね',
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                  onPressed: (){
                    setState(() {
                      guest.setName(playerName: textEditingControllerName.text);
                    });
                  },
                  child: const Text('名前変更')),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NextPage())
                  );
                },
                child: const Text('決定')),
            ),
            Text('ログイン情報： ${widget.user}'),
          ],
        ),
      ),
    );
  }
}