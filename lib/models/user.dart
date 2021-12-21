class UserModel {
  final String id;
  String? profileImageUrl = '';
  String? bannerImageUrl = '';
  final String? name;
  final String? email;

  UserModel({
    required this.id,
    this.profileImageUrl,
    this.bannerImageUrl,
    this.name,
    this.email,
  });
}
