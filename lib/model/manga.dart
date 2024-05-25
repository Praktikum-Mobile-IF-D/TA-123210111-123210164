import 'package:ta_123210111_123210164/model/manga_list.dart';

class Manga {
  final String? result;
  final String? response;
  final Data? data;

  Manga({
    this.result,
    this.response,
    this.data,
  });

  Manga.fromJson(Map<String, dynamic> json)
      : result = json['result'] as String?,
        response = json['response'] as String?,
        data = (json['data'] as Map<String,dynamic>?) != null ? Data.fromJson(json['data'] as Map<String,dynamic>) : null;

  Map<String, dynamic> toJson() => {
    'result' : result,
    'response' : response,
    'data' : data?.toJson()
  };
}