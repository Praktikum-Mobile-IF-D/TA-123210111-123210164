import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:ta_123210111_123210164/model/chapter_list.dart';
import 'package:ta_123210111_123210164/page/chapter_read_page.dart';
import 'package:ta_123210111_123210164/model/url_builder.dart';

class ChapterListPage extends StatefulWidget {
  final String mangaId;
  ChapterListPage({required this.mangaId});
  // const ChapterListPage({super.key});

  @override
  State<ChapterListPage> createState() => _ChapterListPageState();
}

class _ChapterListPageState extends State<ChapterListPage> {
  Future<ChapterList>? chapters;
  int initialOffset = 0;

  @override
  void initState() {
    super.initState();
    chapters = fetchCircuits(initialOffset);
  }

  // todo: pilih bahasa

  Future<ChapterList> fetchCircuits(offset) async {
    // String mangaIdSementaraAja = "38179337-1640-4927-8851-9bedd8d19e82";
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
        .addParam('offset', '$offset');

    var url = urlBuilder.build();
    print(url);
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
        title: const Text('Manga List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<ChapterList>(
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
                Expanded(
                    child: ListView.builder(
                  itemCount: snapshot.data!.data!.length,
                  itemBuilder: (context, index) {
                    var chapter = snapshot.data!.data![index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                chapter.id ?? '',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                              trailing: const Icon(Icons.keyboard_arrow_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChapterReadPage(
                                        chapterId: chapter.id ?? ''),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          onPressed: snapshot.data!.offset! > 0 ? () {
                            setState(() {
                              chapters = previousPage(snapshot.data!.offset);
                            });
                          } : null,
                          child: Text('Previous')),
                      ElevatedButton(
                          onPressed: snapshot.data!.offset! + 21 < snapshot.data!.total! ? () {
                            setState(() {
                              chapters = nextPage(snapshot.data!.offset);
                            });
                          } : null,
                          child: Text('Next')),
                    ])
              ],
            );
          }
        },
      ),
      // bottomNavigationBar: BottomAppBar(
      //   child: SizedBox(
      //     height: 50,
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.end,
      //       children: [
      //         IconButton(
      //           icon: const Icon(Icons.exit_to_app),
      //           onPressed: () {},
      //         ),
      //         const SizedBox(width: 16),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }

  Future<ChapterList> nextPage(var offset) {
    offset = offset + 20;
    return fetchCircuits(offset);
  }

  Future<ChapterList> previousPage(var offset) {
    offset = offset - 20;
    if(offset < 0) return fetchCircuits(0);
    return fetchCircuits(offset);
  }

  // child: Row(
  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
  // children: [
  //   ElevatedButton(onPressed: () {}, child: Text('Previous')),
  //   ElevatedButton(onPressed: () {
  //     setState(() {
  //       chapters = nextPage(snapshot.data!.offset);
  //     });
  //   }, child: Text('Next')),
  // ],

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Manga List'),
  //       actions: [
  //         IconButton(
  //           icon: const Icon(Icons.account_circle),
  //           onPressed: () {},
  //         ),
  //       ],
  //     ),
  //     body: FutureBuilder<ChapterList>(
  //       future: chapters,
  //       builder: (context, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return const Center(child: CircularProgressIndicator());
  //         } else if (snapshot.hasError) {
  //           return Center(child: Text('Error: ${snapshot.error}'));
  //         } else if (!snapshot.hasData || snapshot.data == null) {
  //           return const Center(child: Text('No data available'));
  //         } else {
  //           return ListView.builder(
  //             itemCount: snapshot.data!.data!.length,
  //             itemBuilder: (context, index) {
  //               var chapter = snapshot.data!.data![index];
  //               return Card(
  //                 elevation: 2,
  //                 margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(10),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       ListTile(
  //                         title: Text(
  //                           chapter.id ?? '',
  //                           style: const TextStyle(
  //                               fontSize: 18, fontWeight: FontWeight.bold
  //                           ),
  //                         ),
  //                         subtitle: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             const SizedBox(height: 5),
  //                             Text('Volume: ${chapter.attributes?.volume ?? ''}'),
  //                             Text('Chapter: ${chapter.attributes?.chapter ?? ''}'),
  //                             Text('Language: ${chapter.attributes?.translatedLanguage ?? ''}'),
  //                           ],
  //                         ),
  //                         trailing: const Icon(Icons.keyboard_arrow_right),
  //                         onTap: () {
  //                           Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                               builder: (context) => ReadChapter(chapterId: chapter.id ?? ''),
  //                             ),
  //                           );
  //                         },
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               );
  //             },
  //           );
  //         }
  //       },
  //     ),
  //     bottomNavigationBar: BottomAppBar(
  //       child: SizedBox(
  //         height: 50,
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.end,
  //           children: [
  //             IconButton(
  //               icon: const Icon(Icons.exit_to_app),
  //               onPressed: () {},
  //             ),
  //             const SizedBox(width: 16),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
