class TeamModel {
  final String id;
  final String ownerId;
  final String name;
  final String sport;
  final String city;
  final String description;
  final String logoUrl;

  TeamModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.sport,
    required this.city,
    required this.description,
    required this.logoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'sport': sport,
      'city': city,
      'description': description,
      'logoUrl': logoUrl,
    };
  }

  factory TeamModel.fromMap(Map<String, dynamic> map) {
    return TeamModel(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      sport: map['sport'] ?? '',
      city: map['city'] ?? '',
      description: map['description'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
    );
  }
}
