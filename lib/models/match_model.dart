class MatchModel {
  final String id;
  final String teamId;
  final String opponent;
  final String location;
  final DateTime matchDate;
  final int teamScore;
  final int opponentScore;
  final String status;

  MatchModel({
    required this.id,
    required this.teamId,
    required this.opponent,
    required this.location,
    required this.matchDate,
    required this.teamScore,
    required this.opponentScore,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teamId': teamId,
      'opponent': opponent,
      'location': location,
      'matchDate': matchDate.toIso8601String(),
      'teamScore': teamScore,
      'opponentScore': opponentScore,
      'status': status,
    };
  }

  factory MatchModel.fromMap(Map<String, dynamic> map) {
    return MatchModel(
      id: map['id'] ?? '',
      teamId: map['teamId'] ?? '',
      opponent: map['opponent'] ?? '',
      location: map['location'] ?? '',
      matchDate: DateTime.parse(
        map['matchDate'] ?? DateTime.now().toIso8601String(),
      ),
      teamScore: map['teamScore'] ?? 0,
      opponentScore: map['opponentScore'] ?? 0,
      status: map['status'] ?? 'Scheduled',
    );
  }
}
