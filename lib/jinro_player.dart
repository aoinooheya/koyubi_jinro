import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

// Riverpod
final jinroPlayerProvider = StateNotifierProvider<JinroPlayerNotifier, JinroPlayerState>((ref) => JinroPlayerNotifier());

class JinroPlayerNotifier extends StateNotifier<JinroPlayerState>{
  JinroPlayerNotifier(): super(JinroPlayerState());

  // Couldn't use initialize() because the view wasn't displayed properly.
  // Undesirable when switching the player's account.
  // void initialize(){
  //   state = JinroPlayerState();
  // }

  void copyWith({
    String? playerName,
    String? thumbnail,
    String? voice,
    MediaStream? localStream,
    RTCVideoRenderer? renderer,
    RTCVideoView? view,
    int? iconIndex,
  }){
    playerName ??= state.playerName;
    thumbnail ??= state.thumbnail;
    voice ??= state.voice;
    localStream ??= state.localStream;
    renderer ??= state.renderer;
    view ??= state.view;  // Used for mirror the view
    iconIndex ??= state.iconIndex;
    state = JinroPlayerState(
      playerName: playerName,
      thumbnail: thumbnail,
      voice: voice,
      localStream: localStream,
      renderer: renderer,
      view: view,
      iconIndex: iconIndex,
    );
  }
}

class JinroPlayerState{
  JinroPlayerState({  // Constructor
    this.playerName = 'ゲスト',
    this.thumbnail = 'assets/images/boshuchu.jpg',
    this.voice = 'sounds/wakoyubi.mp3',
    this.localStream,
    RTCVideoRenderer? renderer,
    RTCVideoView? view,
    this.iconIndex = 0,
  }){
    renderer == null ? this.renderer.initialize() : this.renderer = renderer;
    this.renderer.srcObject = localStream;
    view == null ? this.view = RTCVideoView(this.renderer) : this.view = view;
    playerIcon = Container(
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
                child: Image.network(thumbnail),
              ),
              this.view,
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
  String playerName;  // Player name
  String thumbnail;   // File path of player thumbnail
  String voice;       // File path of player voice
  MediaStream? localStream;
  RTCVideoRenderer renderer = RTCVideoRenderer();
  late RTCVideoView view; // Own video
  int iconIndex;  // Index for switching icon view (0 is thumbnail, 1 is video)

  final _audio = AudioCache();
  late Container playerIcon;
}