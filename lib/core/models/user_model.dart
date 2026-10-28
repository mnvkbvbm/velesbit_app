class UserModel {
  final String id;
  String fullName;
  String email;
  String phone;
  String bloodGroup;
  List<String> bikeTypes;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.bloodGroup,
    required this.bikeTypes,
  });

  static const List<String> availableBloodGroups = [
    'A Rh+',
    'A Rh-',
    'B Rh+',
    'B Rh-',
    'AB Rh+',
    'AB Rh-',
    '0 Rh+',
    '0 Rh-',
  ];

  static const List<String> availableBikeTypes = [
    'MTB (Dağ Bisikleti)',
    'Yol (Road)',
    'Gravel',
    'E-Bike',
    'E-Gravel',
    'Şehir (City)',
    'Katlanır (Folding)',
    'Tur (Trekking)',
  ];

  UserModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? bloodGroup,
    List<String>? bikeTypes,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      bikeTypes: bikeTypes ?? List.from(this.bikeTypes),
    );
  }
}
