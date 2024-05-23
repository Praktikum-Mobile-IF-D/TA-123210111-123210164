import 'package:ta_123210111_123210164/model/manga_list.dart';

class ChapterList {
  final String? result;
  final String? response;
  final List<ChapterData>? data;
  final int? limit;
  final int? offset;
  final int? total;

  ChapterList({
    this.result,
    this.response,
    this.data,
    this.limit,
    this.offset,
    this.total,
  });

  ChapterList.fromJson(Map<String, dynamic> json)
      : result = json['result'] as String?,
        response = json['response'] as String?,
        data = (json['data'] as List?)?.map((dynamic e) => ChapterData.fromJson(e as Map<String,dynamic>)).toList(),
        limit = json['limit'] as int?,
        offset = json['offset'] as int?,
        total = json['total'] as int?;

  Map<String, dynamic> toJson() => {
    'result' : result,
    'response' : response,
    'data' : data?.map((e) => e.toJson()).toList(),
    'limit' : limit,
    'offset' : offset,
    'total' : total
  };
}

class ChapterData {
  final String? id;
  final String? type;
  final ChapterAttributes? attributes;
  final List<Relationships>? relationships;

  ChapterData({
    this.id,
    this.type,
    this.attributes,
    this.relationships,
  });

  ChapterData.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String?,
        type = json['type'] as String?,
        attributes = (json['attributes'] as Map<String,dynamic>?) != null ? ChapterAttributes.fromJson(json['attributes'] as Map<String,dynamic>) : null,
        relationships = (json['relationships'] as List?)?.map((dynamic e) => Relationships.fromJson(e as Map<String,dynamic>)).toList();

  Map<String, dynamic> toJson() => {
    'id' : id,
    'type' : type,
    'attributes' : attributes?.toJson(),
    'relationships' : relationships?.map((e) => e.toJson()).toList()
  };
}

class ChapterAttributes {
  final String? volume;
  final String? chapter;
  final dynamic title;
  final String? translatedLanguage;
  final dynamic externalUrl;
  final String? publishAt;
  final String? readableAt;
  final String? createdAt;
  final String? updatedAt;
  final int? pages;
  final int? version;

  ChapterAttributes({
    this.volume,
    this.chapter,
    this.title,
    this.translatedLanguage,
    this.externalUrl,
    this.publishAt,
    this.readableAt,
    this.createdAt,
    this.updatedAt,
    this.pages,
    this.version,
  });

  ChapterAttributes.fromJson(Map<String, dynamic> json)
      : volume = json['volume'] as String?,
        chapter = json['chapter'] as String?,
        title = json['title'],
        translatedLanguage = json['translatedLanguage'] as String?,
        externalUrl = json['externalUrl'],
        publishAt = json['publishAt'] as String?,
        readableAt = json['readableAt'] as String?,
        createdAt = json['createdAt'] as String?,
        updatedAt = json['updatedAt'] as String?,
        pages = json['pages'] as int?,
        version = json['version'] as int?;

  Map<String, dynamic> toJson() => {
    'volume' : volume,
    'chapter' : chapter,
    'title' : title,
    'translatedLanguage' : translatedLanguage,
    'externalUrl' : externalUrl,
    'publishAt' : publishAt,
    'readableAt' : readableAt,
    'createdAt' : createdAt,
    'updatedAt' : updatedAt,
    'pages' : pages,
    'version' : version
  };
}

// class Relationships {
//   final String? id;
//   final String? type;
//
//   Relationships({
//     this.id,
//     this.type,
//   });
//
//   Relationships.fromJson(Map<String, dynamic> json)
//       : id = json['id'] as String?,
//         type = json['type'] as String?;
//
//   Map<String, dynamic> toJson() => {
//     'id' : id,
//     'type' : type
//   };
// }