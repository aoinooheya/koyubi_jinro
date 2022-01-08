import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../jinro_player.dart';

class PlayerSetting extends HookConsumerWidget{
  PlayerSetting({Key? key}) : super(key: key);
  final TextEditingController nameField = TextEditingController(text: '');

  @override
  Widget build(BuildContext context, WidgetRef ref){
    final jinroPlayer = ref.watch(jinroPlayerProvider);
    final jinroPlayerNotifier = ref.watch(jinroPlayerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プレイヤー設定＾ー＾'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            jinroPlayer[0].playerIcon,
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
                  jinroPlayerNotifier.copyWith(
                    jinroPlayerState: jinroPlayer[0], playerName: nameField.text
                  );
                },
                child: const Text('名前変更')),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}