class UserModel {
  String id;
  String name;
  String email;
  String profileImage;
  double budgetLimit;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.budgetLimit,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'budgetLimit': budgetLimit,
    };
  }

  // Convert from JSON when loading data
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'] ?? '',
      budgetLimit: (json['budgetLimit'] ?? 0).toDouble(),
    );
  }
}
