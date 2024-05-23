import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:ta_123210111_123210164/model/manga_list.dart';
import 'package:ta_123210111_123210164/page/chapter_list_page.dart';
import 'package:ta_123210111_123210164/model/url_builder.dart';
import 'package:ta_123210111_123210164/page/manga_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePagePageState();
}

class _HomePagePageState extends State<HomePage> {
  Future<MangaList>? mangas;
  final _searchController = TextEditingController();
  String pageTitle =  'Latest Updates';

  @override
  void initState() {
    super.initState();
    mangas = getManga();
  }

  // TODO: bikin search manga
  // TODO: bikin favorit
  // TODO: filters

  Future<MangaList> getManga([String? title]) async {
    UrlBuilder urlBuilder = UrlBuilder('manga');

    if (title != null && title.isNotEmpty) {
      pageTitle = 'Search Result';
      urlBuilder.addParam('title', title);
    } else {
      pageTitle = 'Latest Updates';
    }

    var url = urlBuilder.build();
    // print(url);
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return MangaList.fromJson(convert.jsonDecode(response.body));
    } else {
      throw Exception('Failed to load manga images, ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(pageTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search manga...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onSubmitted: (title) {
                  setState(() {
                    mangas = getManga(title);
                  });
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<MangaList>(
                future: mangas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text('No data available'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.data!.length,
                      itemBuilder: (context, index) {
                        var manga = snapshot.data!.data![index];
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
                                    manga.attributes?.title?.titles['en'] ??
                                        (manga.attributes?.title?.titles.isNotEmpty == true
                                            ? manga.attributes?.title?.titles.values.first : '')
                                        ?? '',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 5),
                                      Text(manga.attributes?.description?.en ??
                                          (manga.attributes?.description?.descriptions.values.isNotEmpty == true
                                              ? manga.attributes?.description?.descriptions.values.first : '')
                                          ?? ''),
                                      Text(
                                          'Year: ${manga.attributes?.year ?? ''}'),
                                    ],
                                  ),
                                  trailing:
                                      const Icon(Icons.keyboard_arrow_right),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MangaDetailPage(
                                            mangaId: manga.id ?? ''),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            )
          ],
        ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Nama loe'),
            ),
            ListTile(
              title: const Text('Latest Update'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: const Text('Advanced Search'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: const Text('Random Manga'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: const Text('Favorite Manga'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
    );
  }
}
