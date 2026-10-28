enum GroupType {
  takim('Takım'),
  dernek('Dernek'),
  ekip('Ekip'),
  topluluk('Topluluk');

  final String label;
  const GroupType(this.label);
}

class GroupModel {
  final String id;
  final String name;
  final GroupType type;
  final String description;
  final String city;
  int memberCount;
  bool isJoined;
  final String creatorName;
  final String createdDate;

  GroupModel({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.city,
    required this.memberCount,
    this.isJoined = false,
    required this.creatorName,
    required this.createdDate,
  });

  GroupModel copyWith({
    String? name,
    GroupType? type,
    String? description,
    String? city,
    int? memberCount,
    bool? isJoined,
  }) {
    return GroupModel(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      city: city ?? this.city,
      memberCount: memberCount ?? this.memberCount,
      isJoined: isJoined ?? this.isJoined,
      creatorName: creatorName,
      createdDate: createdDate,
    );
  }
}
