import 'package:flutter/material.dart';
import 'package:myapp/timer.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../signaling.dart';
import '../jinro_player.dart';

class ThirteenVillage extends StatefulWidget {
  const ThirteenVillage({Key? key}) : super(key: key);
  @override
  _ThirteenVillage createState() => _ThirteenVillage();
}

class _ThirteenVillage extends State<ThirteenVillage> {
  bool micOn = false;
  bool cameraOn = false;
  JinroPlayer aoi = JinroPlayer(
    playerName: '葵',
    thumbnail:  'assets/images/aoi.jpg',
    voice:      'sounds/hiiteiku.mp3'
  );
  JinroPlayer masyu = JinroPlayer(
    playerName: 'masyu',
    thumbnail:  'assets/images/masyu.jpg',
    voice:      'sounds/shake.mp3',
  );
  JinroPlayer sokushichan = JinroPlayer(
    playerName: '即死ちゃん',
    thumbnail:  'assets/images/sokushichan.jpg',
    voice:      'sounds/onegaishimasusokushichan.mp3',
  );
  // WebRTC
  Signaling signaling = Signaling();
  String? roomId;
  TextEditingController textEditingControllerCreate = TextEditingController(text: '');
  TextEditingController textEditingControllerJoin = TextEditingController(text: '');
  // WebRTC End

  void _changeMicIcon(){
    setState(() {micOn = !micOn;});
  }
  void _changeCameraIcon(){
    setState(() {cameraOn = !cameraOn;});
  }

  @override
  void initState() {
    signaling.activateUserMedia(aoi.renderer, masyu.renderer);
    // Set remote stream to onAddRemoteStream??
    signaling.onAddRemoteStream = ((stream) {
      masyu.renderer.srcObject = stream;
      setState(() {});
    });
    // Mirror the view
    aoi.setView(view: RTCVideoView(aoi.renderer, mirror: true));

    super.initState();
  }

  @override
  void dispose() {
    aoi.renderer.dispose();
    masyu.renderer.dispose();
    super.dispose();
  } // WebRTC End

  @override
  Widget build(BuildContext context) {
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
                aoi.createIcon(),
                masyu.createIcon(),
                sokushichan.createIcon(),
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
                    setState(() {
                      masyu.setIconIndex(iconIndex: 1);
                    });
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
                    setState(() {
                      masyu.setIconIndex(iconIndex: 1);
                    });
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
          if (cameraOn==false)
            FloatingActionButton(
              heroTag: "cameraOff",
              child: const Icon(Icons.videocam_off),
              // Turn on the camera
              onPressed: (){
                signaling.localStream?.getVideoTracks()[0].enabled = true;
                aoi.setIconIndex(iconIndex: 1);
                _changeCameraIcon();
              },
            ),
          if (cameraOn==true)
            FloatingActionButton(
              heroTag: "cameraOn",
              child: const Icon(Icons.videocam),
              // Turn off the camera
              onPressed: (){
                signaling.localStream?.getVideoTracks()[0].enabled = false;
                aoi.setIconIndex(iconIndex: 0);
                _changeCameraIcon();
              },
            ),
          // Camera End
        ],
      ),
    );
  }
}