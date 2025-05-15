class MyUserEntity {
  String userId;
  String email;
  String name;
  String? profilePicture;

  MyUserEntity({
    required this.userId,
    required this.email,
    required this.name,
    this.profilePicture,
  });

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'profilePicture': profilePicture,
    };
  }

  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
    return MyUserEntity(
      userId: doc['userId'],
      email: doc['email'],
      name: doc['name'],
      profilePicture: doc['profilePicture'],
    );
  }
}
