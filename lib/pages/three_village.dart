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
  final JinroPlayerState aoi = JinroPlayerState(
    playerName: '葵',
    thumbnail:  'assets/images/aoi.jpg',
    voice:      'sounds/hiiteiku.mp3'
  );
  final JinroPlayerState masyu = JinroPlayerState(
    playerName: 'masyu',
    thumbnail:  'assets/images/masyu.jpg',
    voice:      'sounds/shake.mp3',
  );
  final JinroPlayerState sokushichan = JinroPlayerState(
    playerName: '即死ちゃん',
    thumbnail:  'assets/images/sokushichan.jpg',
    voice:      'sounds/onegaishimasusokushichan.mp3',
  );
  // WebRTC
  final Signaling signaling = Signaling();
  late final String? roomId;
  final TextEditingController textEditingControllerCreate = TextEditingController(text: '');
  final TextEditingController textEditingControllerJoin = TextEditingController(text: '');
  // WebRTC End

  void _changeMicIcon(){
    // setState(() {micOn = !micOn;});
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jinroPlayer = ref.watch(jinroPlayerProvider);
    final jinroPlayerNotifier = ref.watch(jinroPlayerProvider.notifier);
    useEffect((){
      signaling.activateUserMedia(jinroPlayer.renderer, masyu.renderer);
      // Set remote stream to onAddRemoteStream??
      signaling.onAddRemoteStream = ((stream) {
        masyu.renderer.srcObject = stream;
        // setState(() {});
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
                jinroPlayer.playerIcon,
                aoi.playerIcon,
                masyu.playerIcon,
                sokushichan.playerIcon,
              ]
            ),
            Wrap(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    roomId = await signaling.createRoom(
                      textEditingControllerCreate.text,
                      masyu.renderer
                    );
                    textEditingControllerCreate.text = roomId!;
                    // Temporarily switch here.
                    // Originally wanted to switch
                    // when the other side video's on/off was changed
                    // setState(() {
                    //   masyu.iconIndex = 1;
                    // });
                  },
                  child: const Text("Create room"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add roomId
                    signaling.joinRoom(
                      textEditingControllerJoin.text,
                      masyu.renderer,
                    );
                    // Temporarily switch here.
                    // Originally wanted to switch
                    // when the other side video's on/off was changed
                    // setState(() {
                    //   masyu.iconIndex = 1;
                    // });
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
          if (micOn==false)
            FloatingActionButton(
              heroTag: "micOff",
              child: const Icon(Icons.mic_off),
              // Turn on the mic
              onPressed: (){
                signaling.localStream?.getAudioTracks()[0].enabled = true;
                _changeMicIcon();
              },
            ),
          if (micOn==true)
            FloatingActionButton(
              heroTag: "micOn",
              child: const Icon(Icons.mic),
              // Turn off the mic
              onPressed: (){
                signaling.localStream?.getAudioTracks()[0].enabled = false;
                _changeMicIcon();
              },
            ),
          // Mic End
          const SizedBox(height: 5),
          // Camera
          FloatingActionButton(
            child: Icon(jinroPlayer.iconIndex == 0 ? Icons.videocam_off : Icons.videocam),
            // Switch the camera on/off
            onPressed: (){
              if (jinroPlayer.iconIndex == 0){
                jinroPlayer.localStream?.getVideoTracks()[0].enabled = true;
                jinroPlayerNotifier.copyWith(localStream: jinroPlayer.localStream, iconIndex: 1);
              } else if (jinroPlayer.iconIndex == 1) {
                jinroPlayer.localStream?.getVideoTracks()[0].enabled = false;
                jinroPlayerNotifier.copyWith(localStream: jinroPlayer.localStream, iconIndex: 0);
              }
            },
          ),
          // Camera End
        ],
      ),
    );
  }
}