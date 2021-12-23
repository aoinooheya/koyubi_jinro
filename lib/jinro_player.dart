import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class JinroPlayer{
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

  void setIconIndex({required int iconIndex}){ // Increment iconIndex
    this.iconIndex = iconIndex;
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
