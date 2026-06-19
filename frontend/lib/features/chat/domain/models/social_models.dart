import 'chat_model.dart';

class SocialMember {
  final String id;
  final String name;
  final String avatar;

  SocialMember({
    required this.id,
    required this.name,
    required this.avatar,
  });
}

class GroupModel {
  final String id;
  final String name;
  final String description;
  final String? image;
  final List<SocialMember> members;
  final DateTime createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    required this.members,
    required this.createdAt,
  });
}

class CommunityModel {
  final String id;
  final String name;
  final String description;
  final String? image;
  final List<SocialMember> members;
  final DateTime createdAt;

  CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    required this.members,
    required this.createdAt,
  });
}
