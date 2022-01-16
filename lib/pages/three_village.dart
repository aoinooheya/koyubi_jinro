import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:myapp/timer.dart';
import '../signaling.dart';
import '../jinro_player.dart';
import '../util_firebase.dart';

class ThreeVillage extends HookConsumerWidget {
  ThreeVillage({Key? key}) : super(key: key);

  final Signaling signaling = Signaling();
  late final String? roomId;
  final TextEditingController textEditingControllerCreate = TextEditingController(text: '');
  final TextEditingController textEditingControllerJoin = TextEditingController(text: '');
  final UtilFirebase utilFirebase = UtilFirebase();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jinroPlayerList = ref.watch(jinroPlayerListNotifierProvider);
    final jinroPlayerListNotifier = ref.watch(jinroPlayerListNotifierProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        /// Hang up
        leading: IconButton(
          icon: const Icon(Icons.call_end),
          onPressed: (){
            signaling.hangUp(jinroPlayerList, jinroPlayerListNotifier);
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: const <Widget>[
            Text('13人村・。・　残り時間：'),
            ClockTimer(),
          ],
        )
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              children: <Widget>[
                /// Display player icons
                for (final jinroPlayer in jinroPlayerList)
                  jinroPlayer.playerIcon,
              ]
            ),
            Wrap(
              children: <Widget>[
                /// Create room
                ElevatedButton(
                  onPressed: () async {
                    roomId = await signaling.createRoom(
                      textEditingControllerCreate.text,
                      jinroPlayerList,
                      jinroPlayerListNotifier
                    );
                    textEditingControllerCreate.text = roomId!;
                  },
                  child: const Text("部屋を作成"),
                ),
                /// Join room
                ElevatedButton(
                  onPressed: () {
                    signaling.joinRoom(
                      textEditingControllerJoin.text,
                      jinroPlayerList,
                      jinroPlayerListNotifier,
                    );
                  },
                  child: const Text("部屋に参加"),
                ),
              ],
            ),
            Row(
              children: [
                const Text("次の部屋を作成 (入力任意): "),
                Flexible(
                  child: TextFormField(
                    controller: textEditingControllerCreate,
                  ),
                )
              ],
            ),
            Row(
              children: [
                const Text("次の部屋に参加: "),
                Flexible(
                  child: TextFormField(
                    controller: textEditingControllerJoin,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        verticalDirection: VerticalDirection.up,
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Mic
          FloatingActionButton(
            heroTag: "mic",
            child: Icon(
              jinroPlayerList[0].isMute == true ?
                Icons.mic_off : Icons.mic
            ),
            /// Switch the mic on/off
            onPressed: () {
              if (jinroPlayerList[0].isMute == true){
                jinroPlayerList[0].stream?.getAudioTracks()[0].enabled = true;
                jinroPlayerListNotifier.copyWith(
                    jinroPlayerState: jinroPlayerList[0],
                    stream: jinroPlayerList[0].stream,
                    isMute: false,
                );
              } else {  /// isMute == false
                jinroPlayerList[0].stream?.getAudioTracks()[0].enabled = false;
                jinroPlayerListNotifier.copyWith(
                    jinroPlayerState: jinroPlayerList[0],
                    stream: jinroPlayerList[0].stream,
                    isMute: true,
                );
              }
            }
          ),
          const SizedBox(height: 5),
          /// Video
          FloatingActionButton(
            heroTag: "video",
            child: Icon(
              jinroPlayerList[0].iconIndex == iconView.thumbnail.index ?
                Icons.videocam_off : Icons.videocam
            ),
            /// Switch the camera on/off
            onPressed: (){
              if (jinroPlayerList[0].iconIndex == iconView.thumbnail.index){
                jinroPlayerList[0].stream?.getVideoTracks()[0].enabled = true;
                jinroPlayerListNotifier.copyWith(
                  jinroPlayerState: jinroPlayerList[0],
                  stream: jinroPlayerList[0].stream,
                  iconIndex: iconView.video.index
                );
                utilFirebase.updateFirestore(jinroPlayer: jinroPlayerList[0], iconIndex: iconView.video.index);
              } else if (jinroPlayerList[0].iconIndex == iconView.video.index) {
                jinroPlayerList[0].stream?.getVideoTracks()[0].enabled = false;
                jinroPlayerListNotifier.copyWith(
                  jinroPlayerState: jinroPlayerList[0],
                  stream: jinroPlayerList[0].stream,
                  iconIndex: iconView.thumbnail.index
                );
                utilFirebase.updateFirestore(jinroPlayer: jinroPlayerList[0], iconIndex: iconView.thumbnail.index);
              }
            },
          ),
          const SizedBox(height: 5),
          /// Refresh
          FloatingActionButton(
            heroTag: "refresh",
            child: const Icon(Icons.refresh),
            onPressed: (){
              /// Listen for Firestore iconIndex
              for (final jinroPlayer in jinroPlayerList){
                FirebaseFirestore.instance.collection('users').
                  doc(jinroPlayer.playerId).snapshots().listen((snapshot) {
                    Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
                    int iconIndex = userData['iconIndex'];
                    jinroPlayerListNotifier.copyWith(
                      jinroPlayerState: jinroPlayer,
                      iconIndex: iconIndex,
                    );
                });
              }
            },
          ),
        ],
      ),
    );
  }
}