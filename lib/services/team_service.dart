import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/team_model.dart';

class TeamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createTeam(TeamModel team) async {
    await _firestore.collection('teams').doc(team.id).set(team.toMap());
  }

  Future<TeamModel?> getTeam(String teamId) async {
    final document = await _firestore.collection('teams').doc(teamId).get();

    if (!document.exists) {
      return null;
    }

    return TeamModel.fromMap(document.data()!);
  }

  Stream<List<TeamModel>> getTeams(String ownerId) {
    return _firestore
        .collection('teams')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return TeamModel.fromMap(doc.data());
          }).toList();
        });
  }

  Future<void> updateTeam(TeamModel team) async {
    await _firestore.collection('teams').doc(team.id).update(team.toMap());
  }

  Future<void> deleteTeam(String teamId) async {
    await _firestore.collection('teams').doc(teamId).delete();
  }
}
