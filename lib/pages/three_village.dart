import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/timer.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../signaling.dart';
import '../jinro_player.dart';

class ThreeVillage extends HookConsumerWidget {
  ThreeVillage({Key? key}) : super(key: key);

  final bool micOn = false;
  final Signaling signaling = Signaling();
  // late Map<String, String> result;
  late final String? roomId;
  final TextEditingController textEditingControllerCreate = TextEditingController(text: '');
  final TextEditingController textEditingControllerJoin = TextEditingController(text: '');
  // late Map<String, dynamic> result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jinroPlayerList = ref.watch(jinroPlayerListNotifierProvider);
    final jinroPlayerListNotifier = ref.watch(jinroPlayerListNotifierProvider.notifier);
    useEffect((){
      signaling.initializeRemoteStream(jinroPlayerList[1].renderer);

      // When we get remote stream, set to masyu??
      signaling.onAddRemoteStream = ((stream) async {
        // Wait for initialization of playerIdRemote (Should use listen??)
        await Future.delayed(const Duration(seconds: 1));
        jinroPlayerListNotifier.copyWith(
          jinroPlayerState: jinroPlayerList[1],
          // playerId: playerIdRemote,
          stream: stream,
          iconIndex: iconView.video.index,
        );
        print('masyu = onAddRemoteStream');
        print('masyu.renderer.srcObject = ${jinroPlayerList[1].renderer.srcObject}');
      });
      return null;
    }, const []);
    print('masyu.playerId@build = ${jinroPlayerList[1].playerId}');
    return Scaffold(
      appBar: AppBar(
          title: Row(
            children: <Widget>[
              const Text('13人村・。・　残り時間：'),
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
                // Display player icons
                for (final jinroPlayer in jinroPlayerList)
                  jinroPlayer.playerIcon,
              ]
            ),
            Wrap(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    // result = await signaling.createRoom(
                    roomId = await signaling.createRoom(
                      textEditingControllerCreate.text,
                      jinroPlayerList,
                      jinroPlayerListNotifier
                    );
                    // roomId = result['roomId'];
                    // playerIdRemote = result['playerIdCallee']!;
                    textEditingControllerCreate.text = roomId!;
                  },
                  // print('playerIdCallee@create = $playerIdRemote');
                  child: const Text("Create room"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add roomId
                    // playerIdRemote = await signaling.joinRoom(
                    signaling.joinRoom(
                      textEditingControllerJoin.text,
                      jinroPlayerList,
                      jinroPlayerListNotifier,
                    );
                    // print('playerIdRemote@return = $playerIdRemote');
                  },
                  child: const Text("Join room"),
                ),
              ],
            ),
            Row(
              children: [
                const Text("Create the following Room (Optional): "),
                Flexible(
                  child: TextFormField(
                    controller: textEditingControllerCreate,
                  ),
                )
              ],
            ),
            Row(
              children: [
                const Text("Join the following Room: "),
                Flexible(
                  child: TextFormField(
                    controller: textEditingControllerJoin,
                  ),
                )
              ],
            )
          ],
        ),
      ),
      floatingActionButton: Column(
        verticalDirection: VerticalDirection.up,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mic
          FloatingActionButton(
            heroTag: "mic",
            child: Icon(
              jinroPlayerList[0].isMute == true ?
                Icons.mic_off : Icons.mic
            ),
            // Switch the mic on/off
            onPressed: () {
              if (jinroPlayerList[0].isMute == true){
                jinroPlayerList[0].stream?.getAudioTracks()[0].enabled = true;
                jinroPlayerListNotifier.copyWith(
                    jinroPlayerState: jinroPlayerList[0],
                    stream: jinroPlayerList[0].stream,
                    isMute: false,
                );
              } else {  // isMute == false
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
          // Video
          FloatingActionButton(
            heroTag: "video",
            child: Icon(
              jinroPlayerList[0].iconIndex == iconView.thumbnail.index ?
                Icons.videocam_off : Icons.videocam
            ),
            // Switch the camera on/off
            onPressed: (){
              if (jinroPlayerList[0].iconIndex == iconView.thumbnail.index){
                jinroPlayerList[0].stream?.getVideoTracks()[0].enabled = true;
                jinroPlayerListNotifier.copyWith(
                  jinroPlayerState: jinroPlayerList[0],
                  stream: jinroPlayerList[0].stream,
                  iconIndex: iconView.video.index
                );
              } else if (jinroPlayerList[0].iconIndex == iconView.video.index) {
                jinroPlayerList[0].stream?.getVideoTracks()[0].enabled = false;
                jinroPlayerListNotifier.copyWith(
                  jinroPlayerState: jinroPlayerList[0],
                  stream: jinroPlayerList[0].stream,
                  iconIndex: iconView.thumbnail.index
                );
              }
            },
          ),
          // Camera End
        ],
      ),
    );
  }
}