import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/player_model.dart';

class PlayerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createPlayer(PlayerModel player) async {
    await _firestore.collection('players').doc(player.id).set(player.toMap());
  }

  Stream<List<PlayerModel>> getPlayers(String teamId) {
    return _firestore
        .collection('players')
        .where('teamId', isEqualTo: teamId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PlayerModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> updatePlayer(PlayerModel player) async {
    await _firestore
        .collection('players')
        .doc(player.id)
        .update(player.toMap());
  }

  Future<void> deletePlayer(String playerId) async {
    await _firestore.collection('players').doc(playerId).delete();
  }
}
