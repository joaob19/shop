class UserData {
  String token;
  String email;
  String userId;
  String expireDate;

  UserData(
    this.token,
    this.email,
    this.userId,
    this.expireDate,
  );

  static UserData fromJson(Map<String, dynamic> json) {
    return UserData(
      json['token'] as String,
      json['email'] as String,
      json['userId'] as String,
      json['expireDate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'email': email,
      'userId': userId,
      'expireDate': expireDate,
    };
  }
}
