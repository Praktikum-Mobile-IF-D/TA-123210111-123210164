class ChapterImage {
  final String? result;
  final String? baseUrl;
  final Chapter? chapter;

  ChapterImage({
    this.result,
    this.baseUrl,
    this.chapter,
  });

  ChapterImage.fromJson(Map<String, dynamic> json)
      : result = json['result'] as String?,
        baseUrl = json['baseUrl'] as String?,
        chapter = (json['chapter'] as Map<String,dynamic>?) != null ? Chapter.fromJson(json['chapter'] as Map<String,dynamic>) : null;

  Map<String, dynamic> toJson() => {
    'result' : result,
    'baseUrl' : baseUrl,
    'chapter' : chapter?.toJson()
  };
}

class Chapter {
  final String? hash;
  final List<String>? data;
  final List<String>? dataSaver;

  Chapter({
    this.hash,
    this.data,
    this.dataSaver,
  });

  Chapter.fromJson(Map<String, dynamic> json)
      : hash = json['hash'] as String?,
        data = (json['data'] as List?)?.map((dynamic e) => e as String).toList(),
        dataSaver = (json['dataSaver'] as List?)?.map((dynamic e) => e as String).toList();

  Map<String, dynamic> toJson() => {
    'hash' : hash,
    'data' : data,
    'dataSaver' : dataSaver
  };
}