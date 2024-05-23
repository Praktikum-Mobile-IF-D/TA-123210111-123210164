class User {
  final int? id;
  final String? username;
  final String? password;
  final String? favorites;

  User({this.id, this.username, this.password, this.favorites});

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        username = json['username'] as String?,
        password = json['password'] as String?,
        favorites = json['favorites'] as String?;

  Map<String, dynamic> toJson() => {
    'id' : id,
    'username' : username,
    'password' : password,
    'favorites' : favorites
  };
}