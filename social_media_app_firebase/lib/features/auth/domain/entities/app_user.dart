class AppUser {
  final String uid;
  final String email;
  final String name;

  // Constructor
  AppUser({
    required this.uid,
    required this.email,
    required this.name,
  });

  // Convert AppUser object to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
    };
  }

  // Create AppUser object from JSON
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
    );
  }
}