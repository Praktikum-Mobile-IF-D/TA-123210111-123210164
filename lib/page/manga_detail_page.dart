import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:ta_123210111_123210164/model/language.dart';
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
  final _pageController = TextEditingController();

  final List<String> selectedLanguages = [];

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

  Future<ChapterList> getChapters(offset, List<String> selectedLanguages) async {
    UrlBuilder urlBuilder = UrlBuilder('manga/${widget.mangaId}/feed');

    Map<String, String> parameter = {
      'chapter': 'asc',
    };
    Map<String, String> finalOrderQuery = {};
    parameter.forEach((key, value) {
      finalOrderQuery['order[$key]'] = value;
    });

    // List<String> languages = ['en', 'id'];
    // todo: pilih language
    urlBuilder
        .addParams(finalOrderQuery)
        // .addArrayParam('translatedLanguage[]', languages)
        .addParam('limit', '$limit')
        .addParam('offset', '$offset');

    if(selectedLanguages.isNotEmpty) urlBuilder.addArrayParam('translatedLanguage[]', selectedLanguages);

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
                          Text(
                            manga.attributes!.title?.titles['en'] ?? '',
                            style: TextStyle(fontSize: 25),
                          ),
                          Text(manga.attributes!.getEnAltTitle() ?? ''),
                          SizedBox(
                            height: 12,
                          ),
                          Text(
                              '${manga.getAuthor()?.attributes?.name ?? ''}, ${manga.getArtist()?.attributes?.name ?? ''}'),
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
                          (manga.attributes?.description?.descriptions.values
                                      .isNotEmpty ==
                                  true
                              ? manga.attributes?.description?.descriptions
                                  .values.first
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
                              chapters = getChapters(initialOffset, selectedLanguages);
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
                          _settingDialogBuilder(context);
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
                        return Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.data!.length,
                              itemBuilder: (context, index) {
                                var chapter = snapshot.data!.data![index];

                                // TODO: iki yo dit
                                // TODO: ambil key, grup value by key
                                // var jono = groupChaptersByVolume(snapshot.data!.data);
                                // List<ChapterData>? chaptersForVolume = jono['1'];
                                // for (var budi in chaptersForVolume!) {
                                //   print(budi.attributes?.chapter);
                                // }

                                // jono.forEach((key, value) {
                                //   // print('key = $key');
                                //   print('key = $key, value = $value');
                                //   // List<ChapterData>? chaptersForVolume = jono['$key'];
                                //   for (var budi in jono['$key']!) {
                                //     print(budi.attributes?.chapter);
                                //   }
                                // });

                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: ListTile(
                                      title: Text(
                                        'Chapter ${chapter.attributes?.chapter ?? ' '}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 5),
                                          Text(
                                              'Volume: ${chapter.attributes?.volume ?? ''}'),
                                          Text(
                                              'Chapter: ${chapter.attributes?.chapter ?? ''}'),
                                          Text(
                                              'Language: ${chapter.attributes?.translatedLanguage ?? ''}'),
                                        ],
                                      ),
                                      trailing: const Icon(
                                          Icons.keyboard_arrow_right),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ChapterReadPage(
                                                    chapterId:
                                                        chapter.id ?? ''),
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
                                            chapters = previousPage(
                                                snapshot.data!.offset!);
                                          });
                                        }
                                      : null,
                                  child: const Text('Previous'),
                                ),
                                ElevatedButton(
                                  onPressed: () => _pageDialogBuilder(context),
                                  child: const Text('Page'),
                                ),
                                ElevatedButton(
                                  onPressed: snapshot.data!.offset! + 6 <
                                          snapshot.data!.total!
                                      ? () {
                                          setState(() {
                                            chapters = nextPage(
                                                snapshot.data!.offset!);
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

  // TODO: karo iki dit.
  // Map<String, List<ChapterData>> groupChaptersByVolume(List<ChapterData>? chapters) {
  //   var groupedChapters = <String, List<ChapterData>>{};
  //   for (var chapter in chapters!) {
  //     var volume = chapter.attributes?.volume ?? 'Unknown Volume';
  //     if (!groupedChapters.containsKey(volume)) {
  //       groupedChapters['$volume'] = [];
  //     }
  //     groupedChapters['$volume']!.add(chapter);
  //   }
  //   return groupedChapters;
  // }

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
    return getChapters(offset, selectedLanguages);
  }

  Future<ChapterList> previousPage(var offset) {
    offset = offset - 5;
    if (offset < 0) return getChapters(0, selectedLanguages);
    return getChapters(offset, selectedLanguages);
  }

  Future<void> _settingDialogBuilder(BuildContext context) {
    Map<String,String> languages = Language().languages;
    var _languagesController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chapter Settings'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Filter Language"),
              Text("Include Languages: "),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SearchAnchor(
                    builder: (BuildContext context, SearchController controller) {
                      return SearchBar(
                        controller: controller,
                        padding: const MaterialStatePropertyAll<EdgeInsets>(
                            EdgeInsets.symmetric(horizontal: 16.0)),
                        onTap: () {
                          controller.openView();
                          },
                        onChanged: (_) {
                          controller.openView();
                          },
                        leading: const Icon(Icons.search),
                      );
                      },
                    suggestionsBuilder: (BuildContext context, SearchController controller) {
                      // Filter the languages based on the search input
                      final query = controller.text.toLowerCase();
                      final filteredLanguages = languages.keys
                          .where((language) => language.toLowerCase().contains(query))
                          .toList();

                      return List<ListTile>.generate(filteredLanguages.length, (int index) {
                        final String language = filteredLanguages[index];
                        return ListTile(
                          title: Text(language),
                          onTap: () {
                            setState(() {
                              selectedLanguages.add(languages[language]!);
                              controller.closeView(language);
                            });
                          },
                        );
                      });
                    }
                    ),
              ),
              // Text(selectedLanguages.join())
              // if(selectedLanguages.isNotEmpty) Expanded(
              //   child: ListView.builder(
              //     itemCount: selectedLanguages.length,
              //     itemBuilder: (BuildContext context, int index) {
              //       print(selectedLanguages);
              //       return ListTile(
              //         title: Text(selectedLanguages.elementAt(index)),
              //       );
              //     },
              //   ),
              // ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Save'),
              onPressed: () {
                chapters = getChapters(initialOffset, selectedLanguages);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pageDialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Page'),
          content: TextFormField(
            controller: _pageController,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                _pageController.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Go'),
              onPressed: () {
                var pageOffset = int.parse(_pageController.text);
                setState(() {
                  chapters = getChapters(5 * pageOffset - 5, selectedLanguages);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
