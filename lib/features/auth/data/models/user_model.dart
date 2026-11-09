class UserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String image;
  final String address;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.image,
    required this.address,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final first = firstName.isEmpty ? '' : firstName[0];
    final last = lastName.isEmpty ? '' : lastName[0];
    final result = '$first$last'.toUpperCase();
    return result.isEmpty ? '?' : result;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawAddress = json['address'];
    final address = rawAddress is Map
        ? [rawAddress['address'], rawAddress['city'], rawAddress['country']]
              .map((part) => part?.toString() ?? '')
              .where((part) => part.isNotEmpty)
              .join(', ')
        : '';

    return UserModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      address: address,
    );
  }
}
