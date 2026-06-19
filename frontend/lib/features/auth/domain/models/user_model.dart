class UserModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? profilePicture;
  final String? accessToken;
  final String? refreshToken;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.profilePicture,
    this.accessToken,
    this.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      profilePicture: json['profilePicture'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'username': username,
      'email': email,
      'profilePicture': profilePicture,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}
