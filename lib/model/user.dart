import 'dart:io';

class User {
  final int? id;
  final String? username;
  final String? password;
  final String? favorites;
  final File? image;

  User({this.id, this.username, this.password, this.favorites, this.image});

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        username = json['username'] as String?,
        password = json['password'] as String?,
        favorites = json['favorites'] as String?,
        image = json['image'] != null ? File(json['image'] as String) : null;

  Map<String, dynamic> toJson() => {
    'id' : id,
    'username' : username,
    'password' : password,
    'favorites' : favorites,
    'image' : image?.path
  };
}