import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:ta_123210111_123210164/model/manga.dart';
import 'dart:convert' as convert;

import 'package:ta_123210111_123210164/model/manga_list.dart';
import 'package:ta_123210111_123210164/model/url_builder.dart';
import 'package:ta_123210111_123210164/page/chapter_read_page.dart';
import 'package:ta_123210111_123210164/page/home_page.dart';
import 'package:ta_123210111_123210164/model/chapter_list.dart';


class MangaDetailPage extends StatefulWidget {
  final String mangaId;
  const MangaDetailPage({super.key, required this.mangaId});

  @override
  State<MangaDetailPage> createState() => _MangaDetailPageState();
}

class _MangaDetailPageState extends State<MangaDetailPage> {
  bool isChapter = false;
  Future<Manga>? manga;
  Future<ChapterList>? chapters;
  int initialOffset = 0;
  int limit = 5;


  @override
  void initState() {
    super.initState();
    manga = getManga();
  }

  // TODO: bikin search manga
  // TODO: bikin favorit
  // TODO: filters

  Future<Manga> getManga() async {
    UrlBuilder urlBuilder = UrlBuilder('manga/${widget.mangaId}');

    List<String> includes = ['cover_art', 'artist', 'author'];

    urlBuilder.addArrayParam('includes[]', includes);

    var url = urlBuilder.build();
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return Manga.fromJson(convert.jsonDecode(response.body));
    } else {
      throw Exception('Failed to load manga images, ${response.statusCode}');
    }
  }

  Future<ChapterList> getChapters(offset) async {
    UrlBuilder urlBuilder = UrlBuilder('manga/${widget.mangaId}/feed');

    Map<String, String> parameter = {
      'chapter': 'asc',
    };
    Map<String, String> finalOrderQuery = {};
    parameter.forEach((key, value) {
      finalOrderQuery['order[$key]'] = value;
    });

    List<String> languages = ['en', 'id'];
    // todo: pilih language
    urlBuilder
        .addParams(finalOrderQuery)
        .addArrayParam('translatedLanguage[]', languages)
        .addParam('limit', '$limit')
        .addParam('offset', '$offset');

    var url = urlBuilder.build();
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return ChapterList.fromJson(convert.jsonDecode(response.body));
    } else {
      throw Exception('Failed to load manga images, ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manga Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<Manga>(
        future: manga,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available'));
          } else {
            var manga = snapshot.data!.data!;
            return ListView(
              padding: const EdgeInsets.all(10),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Image.network(
                        'https://uploads.mangadex.org/covers/${manga.id}/${manga.getCoverId()?.attributes?.fileName}.256.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(manga.attributes!.title?.titles['en'] ?? '', style: TextStyle(fontSize: 25),),
                          Text(manga.attributes!.getEnAltTitle() ?? ''),
                          SizedBox(height: 12,),
                          Text('${manga.getAuthor()?.attributes?.name ?? ''}, ${manga.getArtist()?.attributes?.name ?? ''}'),
                        ],
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    // Your code to handle the tap event
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        "Favorite",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  // title: Text(manga.attributes!.title?.titles['en'] ?? 'Unknown Title'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(manga.attributes?.description?.en ??
                          (manga.attributes?.description?.descriptions.values.isNotEmpty == true
                              ? manga.attributes?.description?.descriptions.values.first
                              : '') ??
                          ''),
                      Text('Year: ${manga.attributes?.year ?? ''}'),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (!isChapter) {
                              isChapter = true;
                              chapters = getChapters(initialOffset);
                            } else {
                              isChapter = false;
                            }
                          });
                        },
                        child: Container(
                          height: 55,
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              "Chapters",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Your code to handle the tap event
                        },
                        child: Container(
                          height: 55,
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              "Settings",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isChapter)
                  FutureBuilder<ChapterList>(
                    future: chapters,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Center(child: Text('No data available'));
                      } else {
                        print(groupChaptersByVolume(snapshot.data?.data)['chapter']);
                        return Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.data!.length,
                              itemBuilder: (context, index) {
                                var chapter = snapshot.data!.data![index];
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: ListTile(
                                      title: Text('Chapter ${chapter.attributes?.chapter ?? ' '}'
                                        ,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 5),
                                          Text('Volume: ${chapter.attributes?.volume ?? ''}'),
                                          Text('Chapter: ${chapter.attributes?.chapter ?? ''}'),
                                          Text('Language: ${chapter.attributes?.translatedLanguage ?? ''}'),
                                        ],
                                      ),
                                      trailing: const Icon(Icons.keyboard_arrow_right),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChapterReadPage(chapterId: chapter.id ?? ''),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: snapshot.data!.offset! > 0
                                      ? () {
                                    setState(() {
                                      chapters = previousPage(snapshot.data!.offset!);
                                    });
                                  }
                                      : null,
                                  child: const Text('Previous'),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text('Page'),
                                ),
                                ElevatedButton(
                                  onPressed: snapshot.data!.offset! + 6 < snapshot.data!.total!
                                      ? () {
                                    setState(() {
                                      chapters = nextPage(snapshot.data!.offset!);
                                    });
                                  }
                                      : null,
                                  child: const Text('Next'),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    },
                  ),
              ],
            );
          }
        },
      ),
    );
  }

  Map<String, List<ChapterData>> groupChaptersByVolume(List<ChapterData>? chapters) {
    var groupedChapters = <String, List<ChapterData>>{};
    for (var chapter in chapters!) {
      var volume = chapter.attributes?.volume ?? 'Unknown Volume';
      if (!groupedChapters.containsKey(volume)) {
        groupedChapters[volume] = [];
      }
      groupedChapters[volume]!.add(chapter);
    }
    return groupedChapters;
  }

  // Map<String, List<String>> mapVolumeChapter(List<ChapterData> chapters) {
  //   Map<String, List<String>> volumeChapterMap = {};
  //
  //   for (ChapterData chapter in chapters) {
  //     String volume = chapter.attributes?.volume ?? 'Unknown Volume';
  //     String chapterNumber = chapter.attributes?.chapter ?? 'Unknown Chapter';
  //
  //     if (!volumeChapterMap.containsKey(volume)) {
  //       volumeChapterMap[volume] = [];
  //     }
  //
  //     volumeChapterMap[volume]!.add(chapterNumber);
  //   }
  //
  //   return volumeChapterMap;
  // }

  Future<ChapterList> nextPage(var offset) {
    offset = offset + 5;
    return getChapters(offset);
  }

  Future<ChapterList> previousPage(var offset) {
    offset = offset - 5;
    if(offset < 0) return getChapters(0);
    return getChapters(offset);
  }
}


