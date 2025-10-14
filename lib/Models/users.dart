class UserModel {
  final int? id;
  final String? name;
  final String email;
  final String password;


  UserModel({
    this.id,
    this.name,
    required this.email,
    required this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0'),
      name: json['name']?.toString(),
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
    };
  }

 
}