class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'student' or 'teacher'
  final int age;
  final String password;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.age,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'age': age,
      'password': password,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'student',
      age: map['age'] ?? 0,
      password: map['password'] ?? '',
    );
  }
}
