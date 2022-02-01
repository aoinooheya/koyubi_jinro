import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:myapp/jinro_player.dart';

typedef StreamStateCallback = void Function(MediaStream stream);

class Signaling {
  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };
  // MediaStream? remoteStream;
  // String? roomId;

  Future<String> createRoom(
    String roomIdDefined, List<JinroPlayerState> jinroPlayerList, JinroPlayerListNotifier jinroPlayerListNotifier
  ) async {
    DocumentReference roomRef;

    /// Create room in Firestore
    if(roomIdDefined==''){
      roomRef = FirebaseFirestore.instance.collection('rooms').doc();
    } else {
      roomRef = FirebaseFirestore.instance.collection('rooms').doc(roomIdDefined);
    }
    String roomId = roomRef.id;
    print('New room created. Room ID: $roomId');

    /// Set playerIdCaller to Firestore
    Map<String, dynamic> roomWithOffer = {
      'playerIdCaller' : jinroPlayerList[0].playerId
    };
    await roomRef.set(roomWithOffer);

    /// Register your playerId
    await roomRef.collection('playerIdList').doc(jinroPlayerList[0].playerId).
      set({'playerId' : jinroPlayerList[0].playerId});

    /// Listen for new player
    roomRef.collection('playerIdList').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) async {
        if (change.type == DocumentChangeType.added) {
          /// Get playerId from room
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          String playerId = data['playerId'];
          if (playerId != jinroPlayerList[0].playerId){
            /// Try to get the user
            var userSnapshot = await FirebaseFirestore.instance.collection('users').
            doc(playerId).get();
            /// If the user exists
            if (userSnapshot.exists){
              Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
              String playerName = userData['playerName'];
              String thumbnail = userData['thumbnail'];
              String voice = userData['voice'];
              print('Found playerId: $playerId');

              /// Create PeerConnection
              RTCPeerConnection? peerConnection = await createPeerConnection(configuration);
              print('Create PeerConnection with configuration: $configuration');

              /// Add to JinroPlayerList
              jinroPlayerListNotifier.add(JinroPlayerState(
                playerId: playerId,
                playerName: playerName,
                thumbnail: thumbnail,
                voice: voice,
                peerConnection: peerConnection,
              ));

              /// When peerConnection receives new stream & playerId
              peerConnection.onAddStream = (MediaStream stream) async {
                print("Add remote stream (signaling peerConnection.onAddStream)");
                jinroPlayerListNotifier.copyWith(
                  playerIdCurrent: playerId,
                  stream: stream,
                  iconIndex: iconView.video.index,
                );
              };

              /// Add local stream tracks (Audio&Video) to peerConnection
              jinroPlayerList[0].stream!.getTracks().forEach((track) {
                peerConnection.addTrack(track, jinroPlayerList[0].stream!);
                print('Add local stream track to peerConnection: $track');
              });

              /// Collect ICE candidates
              var callerCandidatesCollection = roomRef.collection('callerCandidates');
              peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
                // print('Got ICE candidate');
                /// Add ICE candidates to Firebase
                callerCandidatesCollection.add(candidate.toMap());
              };

              /// Create SDP and set to PeerConnection
              RTCSessionDescription offer = await peerConnection.createOffer();
              await peerConnection.setLocalDescription(offer);
              print('Created offer');

              /// Update Firestore with offer
              Map<String, dynamic> roomWithOffer = {
                'offer': offer.toMap(),
              };
              await roomRef.collection('playerIdList').doc(playerId).update(roomWithOffer);

              /// Listening for remote session description (SDP) & playerIdCallee
              roomRef.collection('playerIdList').doc(playerId).snapshots().listen((snapshot) async {
                print('Got updated room');
                Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
                /// Get answer
                if (data['answer'] != null) {
                  var answer = RTCSessionDescription(
                    data['answer']['sdp'],
                    data['answer']['type'],
                  );
                  print("Someone tried to connect");
                  /// Set remote SDP to peerConnection
                  await peerConnection.setRemoteDescription(answer);
                }
              });

              /// => peerConnection?.onAddStream ("Add remote stream")

              // /// Get remote track
              // peerConnection?.onTrack = (RTCTrackEvent event) {
              //   print('Got remote track: ${event.streams[0]}');
              //   event.streams[0].getTracks().forEach((track) {
              //     print('Add a track to the remoteStream $track');
              //     remoteStream?.addTrack(track);
              //   });
              // };

              /// Listen for remote Ice candidates
              roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
                snapshot.docChanges.forEach((change) {
                  if (change.type == DocumentChangeType.added) {
                    Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
                    // print('Got new remote ICE candidate');
                    /// Add remote ICE candidate to peerConnection
                    peerConnection.addCandidate(
                      RTCIceCandidate(
                        data['candidate'],
                        data['sdpMid'],
                        data['sdpMLineIndex'],
                      ),
                    );
                  }
                });
              });
            }
          }
        }
      });
    });

    return roomId;
  }

  Future<void> joinRoom(
    String roomId, List<JinroPlayerState> jinroPlayerList, JinroPlayerListNotifier jinroPlayerListNotifier
  ) async {
    /// Get room
    DocumentReference roomRef = FirebaseFirestore.instance.collection('rooms').doc(roomId);
    var roomSnapshot = await roomRef.get();
    print('Got room "$roomId" ${roomSnapshot.exists}');

    if (roomSnapshot.exists) {
      /// Register your playerId
      await roomRef.collection('playerIdList').doc(jinroPlayerList[0].playerId).
       set({'playerId' : jinroPlayerList[0].playerId});

      /// Listen for new player
      roomRef.collection('playerIdList').snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((change) async {
          if (change.type == DocumentChangeType.added) {
            /// Get playerId from room
            Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
            String playerId = data['playerId'];
            if (playerId != jinroPlayerList[0].playerId) {
              /// Try to get the user
              var userSnapshot = await FirebaseFirestore.instance.collection('users').
                doc(playerId).get();
              /// If the user exists
              if (userSnapshot.exists) {
                Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
                String playerName = userData['playerName'];
                String thumbnail = userData['thumbnail'];
                String voice = userData['voice'];
                print('Found playerId: $playerId');

                /// Create PeerConnection
                RTCPeerConnection? peerConnection = await createPeerConnection(configuration);
                print('Create PeerConnection with configuration: $configuration');

                /// Add to JinroPlayerList
                jinroPlayerListNotifier.add(JinroPlayerState(
                  playerId: playerId,
                  playerName: playerName,
                  thumbnail: thumbnail,
                  voice: voice,
                  peerConnection: peerConnection,
                ));

                /// When peerConnection receives new stream & playerId
                peerConnection.onAddStream = (MediaStream stream) async {
                  print("Add remote stream (signaling peerConnection.onAddStream)");
                  jinroPlayerListNotifier.copyWith(
                    playerIdCurrent: playerId,
                    stream: stream,
                    iconIndex: iconView.video.index,
                  );
                };

                /// Send my stream to the other person (Google server?)
                jinroPlayerList[0].stream!.getTracks().forEach((track) {
                  peerConnection.addTrack(track, jinroPlayerList[0].stream!);
                });

                /// Collect ICE candidates
                var calleeCandidatesCollection = roomRef.collection('calleeCandidates');
                peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
                  // print('onIceCandidate: ${candidate.toMap()}');
                  calleeCandidatesCollection.add(candidate.toMap());
                };

                // /// Receiving the other person's stream?
                // peerConnection?.onTrack = (RTCTrackEvent event) {
                //   print('Got remote track: ${event.streams[0]}');
                //   event.streams[0].getTracks().forEach((track) {
                //     print('Add a track to the remoteStream: $track');
                //     remoteStream?.addTrack(track);
                //   });
                // };

                /// Get offer from Firestore and set to peerConnection
                roomRef.collection('playerIdList').doc(jinroPlayerList[0].playerId).snapshots().listen((snapshot) async {
                  var data = snapshot.data() as Map<String, dynamic>;
                  if (data['offer'] != null && data['answer'] == null){
                    var offer = data['offer'];
                    await peerConnection.setRemoteDescription(
                      RTCSessionDescription(offer['sdp'], offer['type']),
                    );
                    print('Got offer from Firestore');

                    /// Create SDP answer and set to peerConnection
                    var answer = await peerConnection.createAnswer();
                    print('Created Answer');
                    await peerConnection.setLocalDescription(answer);

                    /// Update Firestore with 'answer' & 'playerIdCallee'
                    Map<String, dynamic> roomWithAnswer = {
                      'answer': {'type': answer.type, 'sdp': answer.sdp},
                      'playerIdCallee' : jinroPlayerList[0].playerId
                    };
                    await roomRef.collection('playerIdList').doc(jinroPlayerList[0].playerId).update(roomWithAnswer);
                  }
                });

                /// Listening for remote ICE candidates
                roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
                  snapshot.docChanges.forEach((change) {
                    Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
                    // print(data);
                    // print('Got new remote ICE candidate: $data');
                    peerConnection.addCandidate(
                      RTCIceCandidate(
                        data['candidate'],
                        data['sdpMid'],
                        data['sdpMLineIndex'],
                      ),
                    );
                  });
                });
              }
            }
          }
        });
      });
    }
  }

  Future<void> hangUp(List<JinroPlayerState> jinroPlayerList, JinroPlayerListNotifier jinroPlayerListNotifier) async {
    RTCPeerConnection? peerConnection = await createPeerConnection(configuration);
    // List<MediaStreamTrack> tracks = jinroPlayerList[0].renderer.srcObject!.getTracks();
    // tracks.forEach((track) {
    //   track.stop();
    // });
    // jinroPlayerList[0].renderer.srcObject = null;

    // if (remoteStream != null) {
    //   remoteStream!.getTracks().forEach((track) => track.stop());
    // }
    peerConnection.close();

    // if (roomId != null) {
    //   var db = FirebaseFirestore.instance;
    //   var roomRef = db.collection('rooms').doc(roomId);
    //   var calleeCandidates = await roomRef.collection('calleeCandidates').get();
    //   calleeCandidates.docs.forEach((document) => document.reference.delete());
    //
    //   var callerCandidates = await roomRef.collection('callerCandidates').get();
    //   callerCandidates.docs.forEach((document) => document.reference.delete());
    //
    //   await roomRef.delete();
    // }

    // localStream!.dispose();
    // remoteStream?.dispose();
  }
}