// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:myapp/timer.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'signaling_test.dart';
//
// class JinroPlayer{
//   late String playerName;       // Player name
//   late String thumbnail;  // File path of player thumbnail
//   late String voice;      // File path of player voice
//   RTCVideoView? view; // Own video
//   late Container icon;    // Player icon
//   final _audio = AudioCache();
//
//   void initialize({       // Create icon
//     String? playerName,
//     String? thumbnail,
//     String? voice,
//     RTCVideoView? view
//   }){
//     this.playerName = playerName!;
//     this.thumbnail = thumbnail!;
//     this.voice = voice!;
//     this.view = view;
//     icon = Container(
//       width: 100, height: 100, margin: const EdgeInsets.all(5),
//       decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey, width: 2.0),
//           borderRadius: BorderRadius.circular(8.0),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.5),
//               spreadRadius: 5,
//               blurRadius: 7,
//               offset: const Offset(0, 3),
//             )
//           ],
//           image: DecorationImage(
//               image: AssetImage(this.thumbnail)
//           )
//       ),
//       child: Stack(
//           children: <Widget>[
//             Container(
//                 child: this.view
//             ),
//             Column(
//               // Print player's name
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: <Widget>[
//                 Container(
//                   width: double.infinity,
//                   color: Colors.black.withOpacity(0.4),
//                   child: Text(
//                     this.playerName,
//                     style: const TextStyle(color: Colors.white),
//                     textAlign: TextAlign.center,
//                   ),
//                 )
//               ],
//             ),
//             Material(
//               color: Colors.transparent,
//               child: InkWell(
//                   borderRadius: BorderRadius.circular(8.0),
//                   onTap: (){
//                     _audio.play(this.voice);
//                   }
//               ),
//             ),
//           ]
//       ),
//     );
//   }
// }
//
// class ThirteenVillage extends StatefulWidget {
//   const ThirteenVillage({Key? key}) : super(key: key);
//
//   @override
//   _ThirteenVillage createState() => _ThirteenVillage();
// }
//
// class _ThirteenVillage extends State<ThirteenVillage> {
//   bool micOn = false;
//   bool cameraOn = false;
//   final _audio = AudioCache();
//   JinroPlayer aoi = JinroPlayer();
//   JinroPlayer masyu = JinroPlayer();
//   // JinroPlayer sokushichan = JinroPlayer();
//   // WebRTC
//   Signaling signaling = Signaling();
//   RTCVideoRenderer _localRenderer = RTCVideoRenderer();
//   RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
//   String? roomId;
//   TextEditingController textEditingController = TextEditingController(text: '');
//   // WebRTC End
//
//   void _changeMicIcon(){
//     setState(() {
//       micOn = !micOn;
//     });
//   }
//   void _changeCameraIcon(){
//     setState(() {
//       cameraOn = !cameraOn;
//     });
//   }
//
//   @override
//   void initState() {
//     _localRenderer.initialize();
//     _remoteRenderer.initialize();
//     aoi.initialize(
//       playerName: '葵',
//       thumbnail:  'assets/images/aoi.jpg',
//       voice:      'sounds/hiiteiku.mp3',
//       view:       RTCVideoView(_localRenderer, mirror: true),
//     );
//     masyu.initialize(
//       playerName: 'masyu',
//       thumbnail:  'assets/images/masyu.jpg',
//       voice:      'sounds/shake.mp3',
//       view:       RTCVideoView(_remoteRenderer),
//     );
//     // sokushichan.initialize(
//     //     playerName: '即死ちゃん',
//     //     thumbnail:  'assets/images/sokushichan.jpg',
//     //     voice:      'sounds/onegaishimasusokushichan.mp3'
//     // );
//     signaling.activateUserMedia(_localRenderer, _remoteRenderer);
//     signaling.onAddRemoteStream = ((stream) {
//       _remoteRenderer.srcObject = stream;
//       setState(() {});
//     });
//
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//     super.dispose();
//   } // WebRTC End
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           title: Row(
//             children: <Widget>[
//               const Text('13人村・。・　残り時間：'),
//               ClockTimer(),
//             ],
//           )
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Wrap(
//                 children: <Widget>[
//                   aoi.icon,
//                   masyu.icon,
//                   // sokushichan.icon,
//                 ]
//             ),
//             // Wrap(
//             //   children: <Widget>[
//             //     ElevatedButton(
//             //       onPressed: () async {
//             //         roomId = await signaling.createRoom(_remoteRenderer);
//             //         textEditingController.text = roomId!;
//             //         setState(() {});
//             //       },
//             //       child: Text("Create room"),
//             //     ),
//             //     ElevatedButton(
//             //       onPressed: () {
//             //         // Add roomId
//             //         signaling.joinRoom(
//             //           textEditingController.text,
//             //           _remoteRenderer,
//             //         );
//             //       },
//             //       child: Text("Join room"),
//             //     ),
//             //   ],
//             // ),
//             // Row(
//             //   children: [
//             //     Text("Join the following Room: "),
//             //     Flexible(
//             //       child: TextFormField(
//             //         controller: textEditingController,
//             //       ),
//             //     )
//             //   ],
//             // )
//           ],
//         ),
//       ),
//       floatingActionButton: Column(
//         verticalDirection: VerticalDirection.up,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Mic
//           // if (micOn==false)
//           //   FloatingActionButton(
//           //     child: const Icon(Icons.mic_off),
//           //     onPressed: (){
//           //       // signaling.openMic(_localRenderer, _remoteRenderer);
//           //       _changeMicIcon();
//           //       _audio.play('sounds/kaihatsuchu.mp3');
//           //     },
//           //   ),
//           // if (micOn==true)
//           //   FloatingActionButton(
//           //     child: const Icon(Icons.mic),
//           //     onPressed: (){
//           //       _changeMicIcon();
//           //       _audio.play('sounds/kaihatsuchu.mp3');
//           //     },
//           //   ),
//           // Mic End
//           // const SizedBox(height: 5),
//           // Camera
//           if (cameraOn==false)
//             FloatingActionButton(
//               child: const Icon(Icons.videocam_off),
//               onPressed: (){
//                 signaling.openUserMedia(_localRenderer, _remoteRenderer);
//                 _changeCameraIcon();
//               },
//             ),
//           if (cameraOn==true)
//             FloatingActionButton(
//               child: const Icon(Icons.videocam),
//               onPressed: (){
//                 // signaling.hangUp(_localRenderer);
//                 signaling.stopCamera(_localRenderer);
//                 _changeCameraIcon();
//               },
//             ),
//           // Camera End
//         ],
//       ),
//     );
//   }
// }