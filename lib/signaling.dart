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
  RTCPeerConnection? peerConnection;
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
    print('New room created with SDK offer. Room ID: $roomId');

    /// Create PeerConnection
    print('Create PeerConnection with configuration: $configuration');
    peerConnection = await createPeerConnection(configuration);
    registerPeerConnectionListeners(roomId, 'playerIdCallee', jinroPlayerList, jinroPlayerListNotifier);

    /// Add local stream tracks (Audio&Video) to peerConnection
    jinroPlayerList[0].stream!.getTracks().forEach((track) {
      peerConnection?.addTrack(track, jinroPlayerList[0].stream!);
      print('Add local stream track to peerConnection: $track');
    });

    /// Collect ICE candidates
    var callerCandidatesCollection = roomRef.collection('callerCandidates');
    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      // print('Got ICE candidate');
      /// Add ICE candidates to Firebase
      callerCandidatesCollection.add(candidate.toMap());
    };

    /// Create SDP and set to PeerConnection
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    print('Created offer');

    /// Set offer & playerIdCaller to Firestore
    Map<String, dynamic> roomWithOffer = {
      'offer': offer.toMap(),
      'playerIdCaller' : jinroPlayerList[0].playerId
    };
    await roomRef.set(roomWithOffer);

    /// Listening for remote session description (SDP) & playerIdCallee
    roomRef.snapshots().listen((snapshot) async {
      print('Got updated room');
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      /// Get answer
      if (peerConnection?.getRemoteDescription() != null &&
          data['answer'] != null) {
        var answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );
        print("Someone tried to connect");
        /// Set remote SDP to peerConnection
        await peerConnection?.setRemoteDescription(answer);
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

    /// Listen for remote Ice candidates below
    roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          // print('Got new remote ICE candidate');
          // Add remote ICE candidate to peerConnection
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      });
    });

    return roomId;
  }

  Future<void> joinRoom(
    String roomId, List<JinroPlayerState> jinroPlayerList, JinroPlayerListNotifier jinroPlayerListNotifier
  ) async {
    /// Get room
    DocumentReference roomRef = FirebaseFirestore.instance.
      collection('rooms').doc(roomId);
    var roomSnapshot = await roomRef.get();
    print('Got room ${roomSnapshot.exists}');

    /// Create PeerConnection with Google server
    if (roomSnapshot.exists) {
      print('Create PeerConnection with configuration: $configuration');
      peerConnection = await createPeerConnection(configuration);
      registerPeerConnectionListeners(roomId, 'playerIdCaller', jinroPlayerList, jinroPlayerListNotifier);

      /// Send my stream to the other person (Google server?)
      jinroPlayerList[0].stream!.getTracks().forEach((track) {
        peerConnection?.addTrack(track, jinroPlayerList[0].stream!);
      });

      /// Collect ICE candidates
      var calleeCandidatesCollection = roomRef.collection('calleeCandidates');
      peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (candidate == null) {
          print('onIceCandidate: complete!');
          return;
        }
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
      var data = roomSnapshot.data() as Map<String, dynamic>;
      print('Got offer from Firestore');
      var offer = data['offer'];
      await peerConnection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );

      /// Create SDP answer and set to peerConnection
      var answer = await peerConnection!.createAnswer();
      print('Created Answer');
      await peerConnection!.setLocalDescription(answer);

      /// Update Firestore with 'answer' & 'playerIdCallee'
      Map<String, dynamic> roomWithAnswer = {
        'answer': {'type': answer.type, 'sdp': answer.sdp},
        'playerIdCallee' : jinroPlayerList[0].playerId
      };
      await roomRef.update(roomWithAnswer);

      /// Listening for remote ICE candidates
      roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((document) {
          var data = document.doc.data() as Map<String, dynamic>;
          // print(data);
          // print('Got new remote ICE candidate: $data');
          peerConnection!.addCandidate(
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

  Future<void> hangUp(List<JinroPlayerState> jinroPlayerList, JinroPlayerListNotifier jinroPlayerListNotifier) async {
    // List<MediaStreamTrack> tracks = jinroPlayerList[0].renderer.srcObject!.getTracks();
    // tracks.forEach((track) {
    //   track.stop();
    // });
    // jinroPlayerList[0].renderer.srcObject = null;

    // if (remoteStream != null) {
    //   remoteStream!.getTracks().forEach((track) => track.stop());
    // }
    if (peerConnection != null) peerConnection!.close();

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

  void registerPeerConnectionListeners(
    String? roomId,
    String playerIdField,
    List<JinroPlayerState> jinroPlayerList,
    JinroPlayerListNotifier jinroPlayerListNotifier
  ) {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE gathering state changed: $state');
    };
    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state change: $state');
    };
    peerConnection?.onSignalingState = (RTCSignalingState state) {
      print('Signaling state change: $state');
    };
    peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
      print('ICE connection state change: $state');
    };

    /// When peerConnection receives new stream & playerId
    peerConnection?.onAddStream = (MediaStream stream) async {
      print("Add remote stream (signaling peerConnection.onAddStream)");
      /// Get playerId from room
      var roomSnapshot = await FirebaseFirestore.instance.collection('rooms').
        doc(roomId).get();
      Map<String, dynamic> roomData = roomSnapshot.data() as Map<String, dynamic>;
      String playerId = roomData[playerIdField];
      /// Try to get the user
      var userSnapshot = await FirebaseFirestore.instance.collection('users').
        doc(playerId).get();
      /// If the user exists
      if (userSnapshot.exists){
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        String playerName = userData['playerName'];
        String thumbnail = userData['thumbnail'];
        String voice = userData['voice'];
        // jinroPlayerListNotifier.copyWith(
        //   jinroPlayerState: jinroPlayerList[1],
        //   playerId: playerId,
        //   playerName: playerName,
        //   thumbnail: thumbnail,
        //   voice: voice,
        //   stream: stream,
        //   iconIndex: iconView.video.index,
        // );
        jinroPlayerListNotifier.add(JinroPlayerState(
          playerId: playerId,
          playerName: playerName,
          thumbnail: thumbnail,
          voice: voice,
          stream: stream,
          iconIndex: iconView.video.index,
        ));
      }
    };
  }
}