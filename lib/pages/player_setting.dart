import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../jinro_player.dart';

class PlayerSetting extends StatefulWidget{
  const PlayerSetting({Key? key, required this.user}) : super(key: key);
  final User user;
  @override
  _PlayerSetting createState() => _PlayerSetting();
}

class _PlayerSetting extends State<PlayerSetting> {
  JinroPlayer guest = JinroPlayer();
  TextEditingController nameField = TextEditingController(text: '');

  @override
  void initState(){
    guest.setView(view: RTCVideoView(guest.renderer, mirror: true));
    guest.setName(playerName: widget.user.displayName);
    guest.setThumbnail(thumbnail: widget.user.photoURL);
    super.initState();
  }

  @override
  Widget build(BuildContext context){
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
                controller: nameField,
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
                      guest.setName(playerName: nameField.text);
                    });
                  },
                  child: const Text('名前変更')),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: (){
                  Navigator.pop(context);
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