import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../jinro_player.dart';
import '../util_firebase.dart';

class PlayerSetting extends HookConsumerWidget{
  PlayerSetting({Key? key}) : super(key: key);
  final TextEditingController nameField = TextEditingController(text: '');
  UtilFirebase utilFirebase = UtilFirebase();

  @override
  Widget build(BuildContext context, WidgetRef ref){
    final jinroPlayerList = ref.watch(jinroPlayerListNotifierProvider);
    final jinroPlayerListNotifier = ref.watch(jinroPlayerListNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プレイヤー設定＾ー＾'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            jinroPlayerList[0].playerIcon,
            /// Change player's name
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
              width: 120,
              child: ElevatedButton(
                onPressed: (){
                  jinroPlayerListNotifier.copyWith(
                    jinroPlayerState: jinroPlayerList[0], playerName: nameField.text
                  );
                  /// Update Firestore
                  utilFirebase.updateFirestore(
                      jinroPlayer: jinroPlayerList[0],
                      playeName: nameField.text,
                  );
                },
                child: const Text('名前変更')),
            ),
            const SizedBox(height: 8),
            /// Change thumbnail
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: () async {
                  Reference thumbnailRef = FirebaseStorage.instance.
                    ref('thumbnail/${FirebaseAuth.instance.currentUser!.uid}.png');
                  /// Pick thumbnail
                  XFile? pickerFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickerFile != null) {
                    try {
                      /// Upload thumbnail
                      await thumbnailRef.putData(await pickerFile.readAsBytes());
                    } catch (e) {
                      print(e);
                    }
                  }
                  /// copyWith
                  String thumbnailUrl = await thumbnailRef.getDownloadURL();
                  jinroPlayerListNotifier.copyWith(jinroPlayerState: jinroPlayerList[0], thumbnail: thumbnailUrl);
                  /// Update Firestore
                  utilFirebase.updateFirestore(
                    jinroPlayer: jinroPlayerList[0],
                    thumbnail: thumbnailUrl,
                  );
                },
                  child: const Text('サムネ変更')),
            ),
          ],
        ),
      ),
    );
  }
}