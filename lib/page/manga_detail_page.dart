import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:ta_123210111_123210164/model/manga.dart';
import 'dart:convert' as convert;

import 'package:ta_123210111_123210164/model/manga_list.dart';
import 'package:ta_123210111_123210164/model/url_builder.dart';
import 'package:ta_123210111_123210164/page/chapter_list_page.dart';
import 'package:ta_123210111_123210164/page/home_page.dart';

class MangaDetailPage extends StatefulWidget {
  final String mangaId;
  const MangaDetailPage({super.key, required this.mangaId});

  @override
  State<MangaDetailPage> createState() => _MangaDetailPageState();
}

class _MangaDetailPageState extends State<MangaDetailPage> {
  Future<Manga>? manga;

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

    List<String> includes = ['cover_art','artist','author'];

    urlBuilder.addArrayParam('includes[]', includes);

    var url = urlBuilder.build();
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return Manga.fromJson(convert.jsonDecode(response.body));
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
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<Manga>(
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
                  // print(manga.id);
                  // print(manga.attributes!.getEnAltTitle());
                  return Card.outlined(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Image.network(
                                        'https://uploads.mangadex.org/covers/${manga.id}/${manga.getCoverId()?.attributes?.fileName}.256.jpg',
                                        fit: BoxFit.contain),
                                  ),
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        // mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text("${manga.attributes!.title?.titles['en']}"),
                                          Text('${manga.attributes!.getEnAltTitle()}'),
                                          Text('${manga.getAuthor()?.attributes?.name}, ${manga.getArtist()?.attributes?.name}'),

                                        ],
                                      ),
                                    )),
                                // Container(
                                //   child: Image.network(
                                //       'https://uploads.mangadex.org/covers/${manga.id}/${manga.getCoverId()?.attributes?.fileName}.256.jpg',
                                //       fit: BoxFit.contain),
                                //   height: MediaQuery.of(context).size.height / 6,
                                //   alignment: Alignment.center,
                                // ),
                                // Column(
                                //   children: [
                                //     Text("${manga.attributes!.title?.titles['en']}"),
                                //
                                //     // OverflowBox(
                                //     //   child: Text("${manga.attributes!.title?.titles['en']}"),
                                //     // )
                                //   ],
                                // ),
                                // Text("${manga.attributes!.title?.titles['en']}"),
                              ],
                            ),
                            ListTile(
                              title: Text(
                                  "${manga.attributes!.title?.titles['en']}"),
                              // title: Text(
                              //   manga.?.title?.titles['en'] ??
                              //       (manga.attributes?.title?.titles.isNotEmpty == true
                              //           ? manga.attributes?.title?.titles.values.first : '')
                              //       ?? '',
                              //   style: const TextStyle(
                              //       fontSize: 18,
                              //       fontWeight: FontWeight.bold),
                              // ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Text(manga.attributes?.description?.en ??
                                      (manga
                                                  .attributes
                                                  ?.description
                                                  ?.descriptions
                                                  .values
                                                  .isNotEmpty ==
                                              true
                                          ? manga.attributes?.description
                                              ?.descriptions.values.first
                                          : '') ??
                                      ''),
                                  Text('Year: ${manga.attributes?.year ?? ''}'),
                                ],
                              ),
                              // trailing: const Icon(Icons.keyboard_arrow_right),
                              // onTap: () {
                              //   // Navigator.pop(context);
                              //   // Navigator.push(
                              //   //   context,
                              //   //   MaterialPageRoute(
                              //   //     builder: (context) => ChapterListPage(
                              //   //         mangaId: manga.id ?? ''),
                              //   //   ),
                              //   // );
                              // },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
