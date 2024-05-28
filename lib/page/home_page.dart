import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_123210111_123210164/handler/DBHelper.dart';
import 'package:ta_123210111_123210164/handler/database_handler.dart';
import 'package:ta_123210111_123210164/model/random_manga.dart';
import 'package:ta_123210111_123210164/model/user.dart';
import 'package:ta_123210111_123210164/page/advanced_search_page.dart';
import 'package:ta_123210111_123210164/page/manga_detail_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:ta_123210111_123210164/model/manga_list.dart';
import 'package:ta_123210111_123210164/model/url_builder.dart';
import 'package:ta_123210111_123210164/page/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<MangaList>? mangas;
  Future<RandomManga>? randomManga;
  final _searchController = TextEditingController();
  String pageTitle = 'Latest Updates';
  bool showFavorites = false;
  bool showRandom = false;
  bool showAdvancedSearch = false;
  Future<User>? currentUser;
  ScrollController _scrollController = ScrollController();
  List<RandomManga> randomMangaList = [];
  int numberOfRequests = 10;

  @override
  void initState() {
    super.initState();
    mangas = getManga();
    currentUser = initUser();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        loadMoreRandomManga();
      }
    });
    loadMoreRandomManga();
  }

  Future<User> initUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? '';
    String password = prefs.getString('password') ?? '';
    List<User> users = await DBHelper().retrieveUsers();
    User user = users.firstWhere((user) => user.username == username && user.password == password, orElse: () => User(username: username, password: password, favorites: ''));
    print('Current user favorites: ${user.favorites}');
    return user;
  }

  Future<void> loadMoreRandomManga() async {
    print('Loading more random manga...');
    List<RandomManga> newRandomMangaList = await getRandomManga();
    setState(() {
      randomMangaList.addAll(newRandomMangaList);
    });
  }

  Future<MangaList> getManga([String? title]) async {
    UrlBuilder urlBuilder = UrlBuilder('manga');

    List<String> includes = ['cover_art', 'artist', 'author'];

    urlBuilder.addArrayParam('includes[]', includes);

    if (title != null && title.isNotEmpty) {
      setState(() {
        pageTitle = 'Search Result';
      });
      urlBuilder.addParam('title', title);
    } else {
      setState(() {
        pageTitle = 'Latest Updates';
      });
    }

    var url = urlBuilder.build();
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return MangaList.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load manga images, ${response.statusCode}');
    }
  }

  Future<List<RandomManga>> getRandomManga() async {
    UrlBuilder urlBuilder = UrlBuilder('manga/random');

    List<Future<http.Response>> requests = List.generate(numberOfRequests, (_) {
      var url = urlBuilder.build();
      return http.get(url);
    });

    List<http.Response> responses = await Future.wait(requests);

    List<RandomManga> mangaList = [];
    for (var response in responses) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['data'] is Map) {
          mangaList.add(RandomManga.fromJson(data['data'] as Map<String, dynamic>));
        } else {
          throw Exception('Unexpected data format');
        }
      } else {
        throw Exception('Failed to load random manga, ${response.statusCode}');
      }
    }
    print('Fetched ${mangaList.length} manga');
    return mangaList;
  }

  Future<Map<String, String>> fetchMangaDetails(String mangaId) async {
    UrlBuilder mangaDetailsUrlBuilder = UrlBuilder('manga/$mangaId');
    var mangaDetailsUrl = mangaDetailsUrlBuilder.build();
    final response = await http.get(mangaDetailsUrl);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var title = data['data']['attributes']['title']['en'] ?? 'Unknown Title';
      var coverArt = data['data']['relationships'].firstWhere(
              (rel) => rel['type'] == 'cover_art',
          orElse: () => null
      );
      if (coverArt != null) {
        final coverId = coverArt['id'];
        UrlBuilder coverDetailsUrlBuilder = UrlBuilder('cover/$coverId');
        var coverDetailsUrl = coverDetailsUrlBuilder.build();
        final coverResponse = await http.get(coverDetailsUrl);

        if (coverResponse.statusCode == 200) {
          var coverData = jsonDecode(coverResponse.body);
          var fileName = coverData['data']['attributes']['fileName'];
          return {'title': title, 'fileName': fileName, 'coverId': coverId};
        } else {
          throw Exception('Failed to load cover filename');
        }
      } else {
        throw Exception('No cover art found');
      }
    } else {
      throw Exception('Failed to load manga data');
    }
  }

  Future<String> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'No username';
  }

  void _addToFavorites(String manga) async {
    User user = await currentUser!;
    List<String> favorites = user.favorites?.split(',').where((manga) => manga.isNotEmpty).toList() ?? [];
    if (!favorites.contains(manga)) {
      favorites.add(manga);
      user.favorites = favorites.join(',');
      await DBHelper().updateUser(user);
      setState(() {
        currentUser = Future.value(user);
      });
      print('Manga added to favorites: ${user.favorites}');
    }
  }

  void _refreshFavorites() {
    setState(() {
      currentUser = initUser();
    });
  }

  Widget buildMangaList() {
    return FutureBuilder<MangaList>(
      future: mangas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No data available'));
        } else {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
            ),
            itemCount: snapshot.data!.data!.length,
            itemBuilder: (context, index) {
              var manga = snapshot.data!.data![index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MangaDetailPage(mangaId: manga.id ?? ''),
                    ),
                  );
                },
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(4.0)),
                            child: Image.network(
                              'https://uploads.mangadex.org/covers/${manga.id}/${manga.getCoverId()?.attributes?.fileName}.256.jpg',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          manga.attributes?.title?.titles['en'] ??
                              (manga.attributes?.title?.titles.isNotEmpty == true
                                  ? manga.attributes?.title?.titles.values.first
                                  : '')
                              ?? '',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget buildFavoriteMangaList() {
    return FutureBuilder<User>(
      future: currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          User user = snapshot.data!;
          List<String> favorites = user.favorites?.split(',').where((manga) => manga.isNotEmpty).toList() ?? [];
          if (favorites.isEmpty) {
            return Center(child: Text('No favorites found'));
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
            ),
            padding: const EdgeInsets.all(10.0),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              var manga = favorites[index];
              var mangaId = manga.replaceAll(' ', '_');
              return FutureBuilder<Map<String, String>>(
                future: fetchMangaDetails(mangaId),
                builder: (context, coverSnapshot) {
                  if (coverSnapshot.connectionState == ConnectionState.waiting) {
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (coverSnapshot.hasError) {
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(child: Icon(Icons.broken_image)),
                    );
                  } else {
                    var details = coverSnapshot.data!;
                    var title = details['title'] ?? 'Unknown Title';
                    var coverFilename = details['fileName'] ?? '';
                    var coverId = details['coverId'] ?? '';

                    String coverUrl = 'https://uploads.mangadex.org/covers/$mangaId/$coverFilename';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MangaDetailPage(mangaId: manga),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                                child: Image.network(
                                  coverUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(child: Icon(Icons.broken_image));
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ButtonBar(
                              alignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.info_outline),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MangaDetailPage(mangaId: manga),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      favorites.removeAt(index);
                                      user.favorites = favorites.join(',');
                                      DBHelper().updateUser(user);
                                      _refreshFavorites();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        } else {
          return Center(child: Text('No user data available'));
        }
      },
    );
  }


  Widget buildRandomMangaCard() {
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
      ),
      itemCount: randomMangaList.length,
      itemBuilder: (context, index) {
        var manga = randomMangaList[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MangaDetailPage(mangaId: manga.id),
              ),
            );
          },
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FutureBuilder<Map<String, String>>(
                    future: fetchMangaDetails(manga.id),
                    builder: (context, coverSnapshot) {
                      if (coverSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (coverSnapshot.hasError) {
                        return Center(child: Icon(Icons.broken_image));
                      } else {
                        var details = coverSnapshot.data!;
                        var coverFilename = details['fileName'] ?? '';
                        var coverId = details['coverId'] ?? '';
                        String coverUrl = 'https://uploads.mangadex.org/covers/${manga.id}/$coverFilename';
                        return ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(4.0)),
                          child: Image.network(
                            coverUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                              return Icon(Icons.broken_image);
                            },
                          ),
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    manga.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildAdvancedSearch() {
    return AdvancedSearchPage(showAppBar: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (!showFavorites && !showRandom && !showAdvancedSearch)
            Padding(
              padding: const EdgeInsets.only(
                top: 5.0,
                bottom: 8.0,
                left: 0.0,
                right: 0.0,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Manga...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.0),
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
            child: showFavorites
                ? buildFavoriteMangaList()
                : showRandom
                ? buildRandomMangaCard()
                : showAdvancedSearch
                ? buildAdvancedSearch()
                : buildMangaList(),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FutureBuilder<String>(
              future: _getUsername(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Selamat datang',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            snapshot.data!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
            ListTile(
              title: const Text('Latest Update'),
              selected: !showFavorites && !showRandom && !showAdvancedSearch,
              selectedTileColor: Colors.blueAccent.withOpacity(0.2),
              onTap: () {
                setState(() {
                  _searchController.clear();
                  showFavorites = false;
                  showRandom = false;
                  showAdvancedSearch = false;
                  pageTitle = 'Latest Updates';
                  mangas = getManga();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Advanced Search'),
              selected: showAdvancedSearch,
              selectedTileColor: Colors.blueAccent.withOpacity(0.2),
              onTap: () {
                setState(() {
                  _searchController.clear();
                  showFavorites = false;
                  showRandom = false;
                  showAdvancedSearch = true;
                  pageTitle = 'Advanced Search';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Random Manga'),
              selected: showRandom,
              selectedTileColor: Colors.blueAccent.withOpacity(0.2),
              onTap: () {
                setState(() {
                  _searchController.clear();
                  showFavorites = false;
                  showRandom = true;
                  showAdvancedSearch = false;
                  pageTitle = 'Random Manga';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Favorite Manga'),
              selected: showFavorites,
              selectedTileColor: Colors.blueAccent.withOpacity(0.2),
              onTap: () {
                setState(() {
                  _searchController.clear();
                  showFavorites = true;
                  showRandom = false;
                  showAdvancedSearch = false;
                  pageTitle = 'Favorite Manga';
                  _refreshFavorites();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
