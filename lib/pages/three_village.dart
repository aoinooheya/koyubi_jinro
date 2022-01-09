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
  late final String? roomId;
  final TextEditingController textEditingControllerCreate = TextEditingController(text: '');
  final TextEditingController textEditingControllerJoin = TextEditingController(text: '');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jinroPlayer = ref.watch(jinroPlayerProvider);
    final jinroPlayerNotifier = ref.watch(jinroPlayerProvider.notifier);
    useEffect((){
      signaling.initializeRemoteStream(jinroPlayer[1].renderer);

      // When we get remote stream, set to masyu??
      signaling.onAddRemoteStream = ((stream) {
        jinroPlayerNotifier.copyWith(
          jinroPlayerState: jinroPlayer[1], stream: stream, iconIndex: iconView.video.index,
        );
        print('masyu = onAddRemoteStream');
        print('masyu.renderer.srcObject = ${jinroPlayer[1].renderer.srcObject}');
      });
      return null;
    }, const []);
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
                for (final jinroPlayer in jinroPlayer)
                  jinroPlayer.playerIcon,
              ]
            ),
            Wrap(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    roomId = await signaling.createRoom(
                      textEditingControllerCreate.text,
                      jinroPlayer[0].stream!,
                      jinroPlayer[1].renderer
                    );
                    textEditingControllerCreate.text = roomId!;
                  },
                  child: const Text("Create room"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add roomId
                    signaling.joinRoom(
                      textEditingControllerJoin.text,
                      jinroPlayer[0].stream!,
                      jinroPlayer[1].renderer,
                    );
                    // Temporarily switch here.
                    // Originally wanted to switch
                    // when the other side video's on/off was changed
                    jinroPlayerNotifier.copyWith(jinroPlayerState: jinroPlayer[1], iconIndex: 1);
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
              jinroPlayer[0].isMute == true ?
                Icons.mic_off : Icons.mic
            ),
            // Switch the mic on/off
            onPressed: () {
              if (jinroPlayer[0].isMute == true){
                jinroPlayer[0].stream?.getAudioTracks()[0].enabled = true;
                jinroPlayerNotifier.copyWith(
                    jinroPlayerState: jinroPlayer[0],
                    stream: jinroPlayer[0].stream,
                    isMute: false,
                );
              } else {  // isMute == false
                jinroPlayer[0].stream?.getAudioTracks()[0].enabled = false;
                jinroPlayerNotifier.copyWith(
                    jinroPlayerState: jinroPlayer[0],
                    stream: jinroPlayer[0].stream,
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
              jinroPlayer[0].iconIndex == iconView.thumbnail.index ?
                Icons.videocam_off : Icons.videocam
            ),
            // Switch the camera on/off
            onPressed: (){
              if (jinroPlayer[0].iconIndex == iconView.thumbnail.index){
                jinroPlayer[0].stream?.getVideoTracks()[0].enabled = true;
                jinroPlayerNotifier.copyWith(
                  jinroPlayerState: jinroPlayer[0],
                  stream: jinroPlayer[0].stream,
                  iconIndex: iconView.video.index
                );
              } else if (jinroPlayer[0].iconIndex == iconView.video.index) {
                jinroPlayer[0].stream?.getVideoTracks()[0].enabled = false;
                jinroPlayerNotifier.copyWith(
                  jinroPlayerState: jinroPlayer[0],
                  stream: jinroPlayer[0].stream,
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