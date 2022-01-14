import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/jinro_player.dart';

/// Utility for Firebase
class UtilFirebase{
  Future<void> updateFirestore({
    required JinroPlayerState jinroPlayer,
    String? playeName,
    String? thumbnail,
    String? voice,
    int? iconIndex,
  }) async {
    await FirebaseFirestore.instance.
      collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set({
        'playerId' : FirebaseAuth.instance.currentUser!.uid,
        'playerName': playeName ?? jinroPlayer.playerName,
        'thumbnail' : thumbnail ?? jinroPlayer.thumbnail,
        'voice' : voice ?? jinroPlayer.voice,
        'iconIndex' : iconIndex ?? jinroPlayer.iconIndex,
       });
  }
}