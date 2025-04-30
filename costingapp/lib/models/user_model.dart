enum UserRole { admin, operator }

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLogin': lastLogin?.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] == 'admin' ? UserRole.admin : UserRole.operator,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      lastLogin:
          map['lastLogin'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['lastLogin'])
              : null,
    );
  }
}
