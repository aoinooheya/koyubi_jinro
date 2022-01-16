import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Index for switching icon view (0 is thumbnail, 1 is video)
enum iconView {
  thumbnail,  /// index = 0
  video,      /// index = 1
}

/// Riverpod (List of JinroPlayerState)
final jinroPlayerListNotifierProvider =
  StateNotifierProvider<JinroPlayerListNotifier, List<JinroPlayerState>>(
  (ref) => JinroPlayerListNotifier());

class JinroPlayerListNotifier extends StateNotifier<List<JinroPlayerState>>{
  JinroPlayerListNotifier(): super([
    JinroPlayerState(), /// It's you! (id=0)
    JinroPlayerState(
      playerId: '1',
      playerName: 'masyu',
      thumbnail:  'https://firebasestorage.googleapis.com/v0/b/koyubijinro.appspot.com/o/thumbnail%2Fmasyu.jpg?alt=media&token=ec5458bf-946d-4dce-bbcf-a6586a2c19fa',
      voice:      'sounds/shake.mp3',
    ), // masyu (id=1)
    JinroPlayerState(
      playerId: '2',
      playerName: '即死ちゃん',
      thumbnail:  'https://firebasestorage.googleapis.com/v0/b/koyubijinro.appspot.com/o/thumbnail%2Fsokushichan.jpg?alt=media&token=36fc09b4-8e53-4b8f-a13f-0e8caa5afa2b',
      voice:      'sounds/onegaishimasusokushichan.mp3',
    ), // sokushi (id=2)
    JinroPlayerState(
      playerId: '3',
      playerName: '葵',
      thumbnail:  'https://firebasestorage.googleapis.com/v0/b/koyubijinro.appspot.com/o/thumbnail%2Faoi.jpg?alt=media&token=63b39e1e-a6ae-46c6-8fa3-41678d1a9299',
      voice:      'sounds/hiiteiku.mp3'
    ), // aoi (id=3)
  ]);

  void initialize(JinroPlayerState jinroPlayerState) {
    state = [
      for (final jinroPlayer in state)
        if (jinroPlayer.playerId == jinroPlayerState.playerId)
          JinroPlayerState()
        else
          jinroPlayer,
    ];
  }

  void copyWith({
    required JinroPlayerState jinroPlayerState,
    String? playerId,
    String? playerName,
    String? thumbnail,
    String? voice,
    MediaStream? stream,
    RTCVideoRenderer? renderer,
    RTCVideoView? view,
    int? iconIndex,
    bool? isMute,
  }) async {
    playerId ??= jinroPlayerState.playerId;
    playerName ??= jinroPlayerState.playerName;
    thumbnail ??= jinroPlayerState.thumbnail;
    voice ??= jinroPlayerState.voice;
    stream ??= jinroPlayerState.stream;
    renderer ??= jinroPlayerState.renderer;
    view ??= jinroPlayerState.view;  /// Used for mirror the view
    iconIndex ??= jinroPlayerState.iconIndex;
    isMute ??= jinroPlayerState.isMute;
    state = [
      for (final jinroPlayer in state)
        if (jinroPlayer.playerId == jinroPlayerState.playerId)
          JinroPlayerState(
            playerId: playerId,
            playerName: playerName,
            thumbnail: thumbnail,
            voice: voice,
            stream: stream,
            renderer: renderer,
            view: view,
            iconIndex: iconIndex,
            isMute: isMute,
          )
        else
          jinroPlayer,
    ];
  }

  void add(JinroPlayerState jinroPlayerState){
    state = [...state, jinroPlayerState];
  }
}

class JinroPlayerState{
  JinroPlayerState({      /// Constructor
    this.playerId = '0',  /// Updated with uid
    this.playerName = 'ゲスト',
    this.thumbnail = 'https://firebasestorage.googleapis.com/v0/b/koyubijinro.appspot.com/o/thumbnail%2Fboshuchu.jpg?alt=media&token=55a579d1-d3be-4b1c-b377-909226b10981',
    this.voice = 'sounds/wakoyubi.mp3',
    this.stream,
    RTCVideoRenderer? renderer,
    RTCVideoView? view,
    this.iconIndex = 0,   /// iconView = thumbnail
    this.isMute = true,
  }){
    renderer == null ? this.renderer.initialize() : this.renderer = renderer;
    if (stream != null) {
      this.renderer.srcObject = stream;
    }
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
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(thumbnail),
                ),
              ),
              this.view,
            ],
          ),
          Column(
            /// Print player's name
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
  String playerId;    /// uid
  String playerName;  /// Player name
  String thumbnail;   /// File path of player thumbnail
  String voice;       /// File path of player voice
  MediaStream? stream;
  RTCVideoRenderer renderer = RTCVideoRenderer();
  late RTCVideoView view; /// Own video
  int iconIndex;  /// Index for switching icon view (0 is thumbnail, 1 is video)
  bool isMute;

  final _audio = AudioCache();
  late Container playerIcon;
}