class UserModel {
  final int id;
  final String code;
  final String name;
  final String? email;
  final String mobile;
  final String balance;

  UserModel({
    required this.id,
    required this.code,
    required this.name,
    this.email,
    required this.mobile,
    required this.balance,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json['id'],
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString(),
        mobile: json['mobile']?.toString() ?? '',
        balance: json['balance']?.toString() ?? '0');
  }
}
