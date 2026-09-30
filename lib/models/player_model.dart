class PlayerModel {
  final String id;
  final String teamId;
  final String name;
  final String position;
  final int jerseyNumber;
  final int age;
  final String phone;

  PlayerModel({
    required this.id,
    required this.teamId,
    required this.name,
    required this.position,
    required this.jerseyNumber,
    required this.age,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teamId': teamId,
      'name': name,
      'position': position,
      'jerseyNumber': jerseyNumber,
      'age': age,
      'phone': phone,
    };
  }

  factory PlayerModel.fromMap(Map<String, dynamic> map) {
    return PlayerModel(
      id: map['id'] ?? '',
      teamId: map['teamId'] ?? '',
      name: map['name'] ?? '',
      position: map['position'] ?? '',
      jerseyNumber: map['jerseyNumber'] ?? 0,
      age: map['age'] ?? 0,
      phone: map['phone'] ?? '',
    );
  }
}
