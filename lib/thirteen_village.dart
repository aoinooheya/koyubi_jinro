import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:myapp/timer.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'signaling.dart';

class JinroPlayer {
  JinroPlayer({         // Constructor
    required this.playerName,
    required this.thumbnail,
    required this.voice
  });
  String playerName;    // Player name
  String thumbnail;     // File path of player thumbnail
  String voice;         // File path of player voice
  late RTCVideoView view;   // Own video
  // Index for switching icon view (0 is thumbnail, 1 is video)
  int iconIndex = 0;
  final _audio = AudioCache();

  void setView({required RTCVideoView view}){
    this.view = view;
  }

  void changeIconIndex(){ // Increment iconIndex
    if (iconIndex == 1) {iconIndex = 0;}
    else {iconIndex++;}
  }

  Container createIcon(){
    return Container(
      width: 100, height: 100, margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Stack(
        children: <Widget>[
          IndexedStack(
            index: iconIndex,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(thumbnail),
              ),
              view,
            ],
          ),
          Column(
            // Print player's name
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: double.infinity,
                color: Colors.black.withOpacity(0.4),
                child: Text(
                  playerName,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8.0),
              onTap: (){
                _audio.play(voice);
              }
            ),
          ),
        ]
      ),
    );
  }
}

class ThirteenVillage extends StatefulWidget {
  const ThirteenVillage({Key? key}) : super(key: key);
  @override
  _ThirteenVillage createState() => _ThirteenVillage();
}

class _ThirteenVillage extends State<ThirteenVillage> {
  bool micOn = false;
  bool cameraOn = false;
  final _audio = AudioCache();
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
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');
  // WebRTC End

  void _changeMicIcon(){
    setState(() {micOn = !micOn;});
  }
  void _changeCameraIcon(){
    setState(() {cameraOn = !cameraOn;});
  }

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    aoi.setView(view: RTCVideoView(_localRenderer, mirror: true));
    masyu.setView(view: RTCVideoView(_remoteRenderer));
    sokushichan.setView(view: RTCVideoView(_remoteRenderer));
    signaling.activateUserMedia(_localRenderer, _remoteRenderer);
    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
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
                    roomId = await signaling.createRoom(_remoteRenderer);
                    textEditingController.text = roomId!;
                    setState(() {});
                  },
                  child: const Text("Create room"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add roomId
                    signaling.joinRoom(
                      textEditingController.text,
                      _remoteRenderer,
                    );
                  },
                  child: const Text("Join room"),
                ),
              ],
            ),
            Row(
              children: [
                const Text("Join the following Room: "),
                Flexible(
                  child: TextFormField(
                    controller: textEditingController,
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
              onPressed: (){
                // signaling.openMic(_localRenderer, _remoteRenderer);
                _changeMicIcon();
                _audio.play('sounds/kaihatsuchu.mp3');
              },
            ),
          if (micOn==true)
            FloatingActionButton(
              heroTag: "micOn",
              child: const Icon(Icons.mic),
              onPressed: (){
                _changeMicIcon();
                _audio.play('sounds/kaihatsuchu.mp3');
              },
            ),
          // Mic End
          const SizedBox(height: 5),
          // Camera
          if (cameraOn==false)
            FloatingActionButton(
              heroTag: "cameraOff",
              child: const Icon(Icons.videocam_off),
              onPressed: (){
                signaling.openUserMedia(_localRenderer, _remoteRenderer);
                aoi.changeIconIndex();
                _changeCameraIcon();
              },
            ),
          if (cameraOn==true)
            FloatingActionButton(
              heroTag: "cameraOn",
              child: const Icon(Icons.videocam),
              onPressed: (){
                // signaling.hangUp(_localRenderer);
                signaling.stopCamera(_localRenderer);
                aoi.changeIconIndex();
                _changeCameraIcon();
              },
            ),
          // Camera End
        ],
      ),
    );
  }
}