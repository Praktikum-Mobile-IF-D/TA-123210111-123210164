class MangaList {
  final String? result;
  final String? response;
  final List<Data>? data;
  final int? limit;
  final int? offset;
  final int? total;

  MangaList({
    this.result,
    this.response,
    this.data,
    this.limit,
    this.offset,
    this.total,
  });

  MangaList.fromJson(Map<String, dynamic> json)
      : result = json['result'] as String?,
        response = json['response'] as String?,
        data = (json['data'] as List?)?.map((dynamic e) => Data.fromJson(e as Map<String,dynamic>)).toList(),
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

class Data {
  final String? id;
  final String? type;
  final Attributes? attributes;
  final List<Relationships>? relationships;

  Data({
    this.id,
    this.type,
    this.attributes,
    this.relationships,
  });

  Data.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String?,
        type = json['type'] as String?,
        attributes = (json['attributes'] as Map<String,dynamic>?) != null ? Attributes.fromJson(json['attributes'] as Map<String,dynamic>) : null,
        relationships = (json['relationships'] as List?)?.map((dynamic e) => Relationships.fromJson(e as Map<String,dynamic>)).toList();

  Map<String, dynamic> toJson() => {
    'id' : id,
    'type' : type,
    'attributes' : attributes?.toJson(),
    'relationships' : relationships?.map((e) => e.toJson()).toList()
  };

  Relationships? getCoverId() {
    return relationships?.firstWhere(
            (relationship) => relationship.type == 'cover_art');
  }
  Relationships? getArtist() {
    return relationships?.firstWhere(
            (relationship) => relationship.type == 'artist');
  }
  Relationships? getAuthor() {
    return relationships?.firstWhere(
            (relationship) => relationship.type == 'author');
  }
}

class Attributes {
  final Title? title;
  final List<AltTitles>? altTitles;
  final Description? description;
  final bool? isLocked;
  final Links? links;
  final String? originalLanguage;
  final String? lastVolume;
  final String? lastChapter;
  final dynamic publicationDemographic;
  final String? status;
  final int? year;
  final String? contentRating;
  final List<Tags>? tags;
  final String? state;
  final bool? chapterNumbersResetOnNewVolume;
  final String? createdAt;
  final String? updatedAt;
  final int? version;
  final List<String>? availableTranslatedLanguages;
  final String? latestUploadedChapter;

  Attributes({
    this.title,
    this.altTitles,
    this.description,
    this.isLocked,
    this.links,
    this.originalLanguage,
    this.lastVolume,
    this.lastChapter,
    this.publicationDemographic,
    this.status,
    this.year,
    this.contentRating,
    this.tags,
    this.state,
    this.chapterNumbersResetOnNewVolume,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.availableTranslatedLanguages,
    this.latestUploadedChapter,
  });

  Attributes.fromJson(Map<String, dynamic> json)
      : title = (json['title'] as Map<String,dynamic>?) != null ? Title.fromJson(json['title'] as Map<String,dynamic>) : null,
        altTitles = (json['altTitles'] as List?)?.map((dynamic e) => AltTitles.fromJson(e as Map<String,dynamic>)).toList(),
        description = (json['description'] as Map<String,dynamic>?) != null ? Description.fromJson(json['description'] as Map<String,dynamic>) : null,
        isLocked = json['isLocked'] as bool?,
        links = (json['links'] as Map<String,dynamic>?) != null ? Links.fromJson(json['links'] as Map<String,dynamic>) : null,
        originalLanguage = json['originalLanguage'] as String?,
        lastVolume = json['lastVolume'] as String?,
        lastChapter = json['lastChapter'] as String?,
        publicationDemographic = json['publicationDemographic'],
        status = json['status'] as String?,
        year = json['year'] as int?,
        contentRating = json['contentRating'] as String?,
        tags = (json['tags'] as List?)?.map((dynamic e) => Tags.fromJson(e as Map<String,dynamic>)).toList(),
        state = json['state'] as String?,
        chapterNumbersResetOnNewVolume = json['chapterNumbersResetOnNewVolume'] as bool?,
        createdAt = json['createdAt'] as String?,
        updatedAt = json['updatedAt'] as String?,
        version = json['version'] as int?,
        availableTranslatedLanguages = (json['availableTranslatedLanguages'] as List?)?.map((dynamic e) => e as String).toList(),
        latestUploadedChapter = json['latestUploadedChapter'] as String?;

  Map<String, dynamic> toJson() => {
    'title' : title?.toJson(),
    'altTitles' : altTitles?.map((e) => e.toJson()).toList(),
    'description' : description?.toJson(),
    'isLocked' : isLocked,
    'links' : links?.toJson(),
    'originalLanguage' : originalLanguage,
    'lastVolume' : lastVolume,
    'lastChapter' : lastChapter,
    'publicationDemographic' : publicationDemographic,
    'status' : status,
    'year' : year,
    'contentRating' : contentRating,
    'tags' : tags?.map((e) => e.toJson()).toList(),
    'state' : state,
    'chapterNumbersResetOnNewVolume' : chapterNumbersResetOnNewVolume,
    'createdAt' : createdAt,
    'updatedAt' : updatedAt,
    'version' : version,
    'availableTranslatedLanguages' : availableTranslatedLanguages,
    'latestUploadedChapter' : latestUploadedChapter
  };

  String? getEnAltTitle() {
    if (altTitles == null) return null;
    for (var altTitle in altTitles!) {
      if (altTitle.altNames.containsKey('en')) {
        return altTitle.altNames['en'];
      }
    }
    for (var altTitle in altTitles!) {
      if (altTitle.altNames.containsKey('ja')) {
        return altTitle.altNames['ja'];
      }
    }
    return null;
  }
}

class Title {
  final Map<String, String?> titles;

  Title({
    required this.titles,
  });

  // Title.fromJson(Map<String, dynamic> json)
  //     : en = json['en'] as String?;

  Title.fromJson(Map<String, dynamic> json)
      : titles = {
    for (var key in json.keys) key: json[key] as String?
  };

  // Map<String, dynamic> toJson() => {
  //   'en' : en
  // };
  Map<String, dynamic> toJson() => titles;
}

class AltTitles {
  // final String? en;
  final Map<String, String?> altNames;


  AltTitles({
    // this.en,
    required this.altNames,
  });

  AltTitles.fromJson(Map<String, dynamic> json)
      : altNames = {
    for (var key in json.keys) key: json[key] as String?
  };

  // Map<String, dynamic> toJson() => {
  //   'en' : en
  // };

  Map<String, dynamic> toJson() => altNames;

}

class Description {
  final Map<String, String?> descriptions;

  Description({
    required this.descriptions,
  });

  // Named constructor to create a Description from JSON
  Description.fromJson(Map<String, dynamic> json)
      : descriptions = {
    for (var key in json.keys) key: json[key] as String?
  };

  // Method to convert Description object to JSON
  Map<String, dynamic> toJson() => descriptions;

  // Optional: Convenience getters for specific languages
  String? get en => descriptions['en'];
  String? get es => descriptions['es'];
  String? get fr => descriptions['fr'];
  String? get id => descriptions['id'];
  String? get it => descriptions['it'];
  String? get th => descriptions['th'];
}


class Links {
  final Map<String, String?> links;

  Links({
    required this.links,
    // this.al,
    // this.ap,
    // this.kt,
    // this.mu,
    // this.nu,
    // this.mal,
    // this.raw,
    // this.engtl,
  });

  Links.fromJson(Map<String, dynamic> json)
      : links = {
    for (var key in json.keys) key: json[key] as String?
  };

  // Links.fromJson(Map<String, dynamic> json)
  //     : al = json['al'] as String?,
  //       ap = json['ap'] as String?,
  //       kt = json['kt'] as String?,
  //       mu = json['mu'] as String?,
  //       nu = json['nu'] as String?,
  //       mal = json['mal'] as String?,
  //       raw = json['raw'] as String?,
  //       engtl = json['engtl'] as String?;
  Map<String, dynamic> toJson() => links;


// Map<String, dynamic> toJson() => {
//   'al' : al,
//   'ap' : ap,
//   'kt' : kt,
//   'mu' : mu,
//   'nu' : nu,
//   'mal' : mal,
//   'raw' : raw,
//   'engtl' : engtl
// };
}

class Tags {
  final String? id;
  final String? type;
  final TagsAttributes? attributes;
  final List<dynamic>? relationships;

  Tags({
    this.id,
    this.type,
    this.attributes,
    this.relationships,
  });

  Tags.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String?,
        type = json['type'] as String?,
        attributes = (json['attributes'] as Map<String,dynamic>?) != null ? TagsAttributes.fromJson(json['attributes'] as Map<String,dynamic>) : null,
        relationships = json['relationships'] as List?;

  Map<String, dynamic> toJson() => {
    'id' : id,
    'type' : type,
    'attributes' : attributes?.toJson(),
    'relationships' : relationships
  };
}

class TagsAttributes {
  final Name? name;
  final Description? description;
  final String? group;
  final int? version;

  TagsAttributes({
    this.name,
    this.description,
    this.group,
    this.version,
  });

  TagsAttributes.fromJson(Map<String, dynamic> json)
      : name = (json['name'] as Map<String,dynamic>?) != null ? Name.fromJson(json['name'] as Map<String,dynamic>) : null,
        description = (json['description'] as Map<String,dynamic>?) != null ? Description.fromJson(json['description'] as Map<String,dynamic>) : null,
        group = json['group'] as String?,
        version = json['version'] as int?;

  Map<String, dynamic> toJson() => {
    'name' : name?.toJson(),
    'description' : description?.toJson(),
    'group' : group,
    'version' : version
  };
}

class Name {
  final Map<String, String?> names;
  // final String? en;

  Name({
    required this.names,
    // this.en,
  });

  Name.fromJson(Map<String, dynamic> json)
      : names = {
    for (var key in json.keys) key: json[key] as String?
  };
  Map<String, dynamic> toJson() => names;

// Name.fromJson(Map<String, dynamic> json)
//     : en = json['en'] as String?;
//
// Map<String, dynamic> toJson() => {
//   'en' : en
// };
}

class Relationships {
  final String? id;
  final String? type;
  final CoverAttributes? attributes;

  Relationships.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String?,
        type = json['type'] as String?,
        attributes = (json['attributes'] as Map<String,dynamic>?) != null ? CoverAttributes.fromJson(json['attributes'] as Map<String,dynamic>) : null;

  Map<String, dynamic> toJson() => {
    'id' : id,
    'type' : type,
    'attributes' : attributes?.toJson()
  };
}

class CoverAttributes {
  final String? description;
  final String? volume;
  final String? fileName;
  final String? locale;
  final String? createdAt;
  final String? updatedAt;
  final int? version;

  final String? name;
  final dynamic imageUrl;
  final String? twitter;
  final dynamic pixiv;
  final dynamic melonBook;
  final dynamic fanBox;
  final dynamic booth;
  final dynamic namicomi;
  final dynamic nicoVideo;
  final dynamic skeb;
  final dynamic fantia;
  final dynamic tumblr;
  final dynamic youtube;
  final dynamic weibo;
  final dynamic naver;
  final String? website;

  CoverAttributes({
    this.description,
    this.volume,
    this.fileName,
    this.locale,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.name,
    this.imageUrl,
    this.twitter,
    this.pixiv,
    this.melonBook,
    this.fanBox,
    this.booth,
    this.namicomi,
    this.nicoVideo,
    this.skeb,
    this.fantia,
    this.tumblr,
    this.youtube,
    this.weibo,
    this.naver,
    this.website,
  });

  CoverAttributes.fromJson(Map<String, dynamic> json)
      : description = json['description'] as String?,
        volume = json['volume'] as String?,
        fileName = json['fileName'] as String?,
        locale = json['locale'] as String?,
        createdAt = json['createdAt'] as String?,
        updatedAt = json['updatedAt'] as String?,
        version = json['version'] as int?,
        name = json['name'] as String?,
        imageUrl = json['imageUrl'],
        twitter = json['twitter'] as String?,
        pixiv = json['pixiv'],
        melonBook = json['melonBook'],
        fanBox = json['fanBox'],
        booth = json['booth'],
        namicomi = json['namicomi'],
        nicoVideo = json['nicoVideo'],
        skeb = json['skeb'],
        fantia = json['fantia'],
        tumblr = json['tumblr'],
        youtube = json['youtube'],
        weibo = json['weibo'],
        naver = json['naver'],
        website = json['website'] as String?;

  Map<String, dynamic> toJson() => {
    'description' : description,
    'volume' : volume,
    'fileName' : fileName,
    'locale' : locale,
    'createdAt' : createdAt,
    'updatedAt' : updatedAt,
    'version' : version,
    'name' : name,
    'imageUrl' : imageUrl,
    'twitter' : twitter,
    'pixiv' : pixiv,
    'melonBook' : melonBook,
    'fanBox' : fanBox,
    'booth' : booth,
    'namicomi' : namicomi,
    'nicoVideo' : nicoVideo,
    'skeb' : skeb,
    'fantia' : fantia,
    'tumblr' : tumblr,
    'youtube' : youtube,
    'weibo' : weibo,
    'naver' : naver,
    'website' : website
  };
}

// class ArtistAttributes {
//   final String? name;
//   final dynamic imageUrl;
//   final String? twitter;
//   final dynamic pixiv;
//   final dynamic melonBook;
//   final dynamic fanBox;
//   final dynamic booth;
//   final dynamic namicomi;
//   final dynamic nicoVideo;
//   final dynamic skeb;
//   final dynamic fantia;
//   final dynamic tumblr;
//   final dynamic youtube;
//   final dynamic weibo;
//   final dynamic naver;
//   final String? website;
//
//   ArtistAttributes({
//     this.name,
//     this.imageUrl,
//     this.twitter,
//     this.pixiv,
//     this.melonBook,
//     this.fanBox,
//     this.booth,
//     this.namicomi,
//     this.nicoVideo,
//     this.skeb,
//     this.fantia,
//     this.tumblr,
//     this.youtube,
//     this.weibo,
//     this.naver,
//     this.website,
//     this.createdAt,
//     this.updatedAt,
//     this.version,
//   });
//
//   ArtistAttributes.fromJson(Map<String, dynamic> json)
//       : name = json['name'] as String?,
//         imageUrl = json['imageUrl'],
//         twitter = json['twitter'] as String?,
//         pixiv = json['pixiv'],
//         melonBook = json['melonBook'],
//         fanBox = json['fanBox'],
//         booth = json['booth'],
//         namicomi = json['namicomi'],
//         nicoVideo = json['nicoVideo'],
//         skeb = json['skeb'],
//         fantia = json['fantia'],
//         tumblr = json['tumblr'],
//         youtube = json['youtube'],
//         weibo = json['weibo'],
//         naver = json['naver'],
//         website = json['website'] as String?,
//         createdAt = json['createdAt'] as String?,
//         updatedAt = json['updatedAt'] as String?,
//         version = json['version'] as int?;
//
//   Map<String, dynamic> toJson() => {
//     'name' : name,
//     'imageUrl' : imageUrl,
//     'twitter' : twitter,
//     'pixiv' : pixiv,
//     'melonBook' : melonBook,
//     'fanBox' : fanBox,
//     'booth' : booth,
//     'namicomi' : namicomi,
//     'nicoVideo' : nicoVideo,
//     'skeb' : skeb,
//     'fantia' : fantia,
//     'tumblr' : tumblr,
//     'youtube' : youtube,
//     'weibo' : weibo,
//     'naver' : naver,
//     'website' : website,
//     'createdAt' : createdAt,
//     'updatedAt' : updatedAt,
//     'version' : version
//   };
// }