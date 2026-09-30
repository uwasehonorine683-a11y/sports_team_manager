// UWASE HONORINE
// 2401000620

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/match_model.dart';

class MatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _matches =>
      _firestore.collection('matches');

  Future<void> createMatch(MatchModel match) async {
    await _matches.doc(match.id).set(match.toMap());
  }

  Stream<List<MatchModel>> getMatches(String teamId) {
    return _matches.where('teamId', isEqualTo: teamId).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => MatchModel.fromMap(doc.data()))
          .toList();
    });
  }

  Future<void> updateMatch(MatchModel match) async {
    await _matches.doc(match.id).update(match.toMap());
  }

  Future<void> deleteMatch(String matchId) async {
    await _matches.doc(matchId).delete();
  }
}
