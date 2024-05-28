import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:ta_123210111_123210164/model/filter.dart';
import 'package:ta_123210111_123210164/model/language.dart';
import 'dart:convert' as convert;


import 'package:ta_123210111_123210164/model/manga_list.dart';
import 'package:ta_123210111_123210164/model/url_builder.dart';
import 'package:ta_123210111_123210164/page/manga_detail_page.dart';

class AdvancedSearchPage extends StatefulWidget {
  final bool showAppBar;

  const AdvancedSearchPage({super.key, this.showAppBar = true});

  @override
  State<AdvancedSearchPage> createState() => _AdvancedSearchPageState();
}

class _AdvancedSearchPageState extends State<AdvancedSearchPage> {
  Future<MangaList>? mangas;
  final _searchController = TextEditingController();
  String pageTitle = 'Advanced Search';
  String _searchTitle = '';

  List<String> availableTranslatedLanguage = [];
  List<String> contentRatingList = [];
  List<String> magazineDemographicList = [];
  List<String> publicationStatusList = [];

  List<ValueItem> selectedLanguages = List.empty();
  List<ValueItem> selectedRatings = List.empty();
  List<ValueItem> selectedDemographics = List.empty();
  List<ValueItem> selectedPublications = List.empty();
  final MultiSelectController _availableTranslatedLanguageController = MultiSelectController();
  final MultiSelectController _contentRatingListController = MultiSelectController();
  final MultiSelectController _magazineDemographicListController = MultiSelectController();
  final MultiSelectController _publicationStatusListController = MultiSelectController();

  @override
  void initState() {
    super.initState();
    mangas = getManga();
    _searchController.clear();
  }

  Future<MangaList> getManga([String? title, int? offset]) async {
    UrlBuilder urlBuilder = UrlBuilder('manga');

    List<String> includes = ['cover_art', 'artist', 'author'];
    urlBuilder.addArrayParam('includes[]', includes);
    if (availableTranslatedLanguage.isNotEmpty) urlBuilder.addArrayParam('availableTranslatedLanguage[]', availableTranslatedLanguage);
    if (contentRatingList.isNotEmpty) urlBuilder.addArrayParam('contentRating[]', contentRatingList);
    if (magazineDemographicList.isNotEmpty) urlBuilder.addArrayParam('publicationDemographic[]', magazineDemographicList);
    if (publicationStatusList.isNotEmpty) urlBuilder.addArrayParam('status[]', publicationStatusList);

    if (title != null && title.isNotEmpty) {
      pageTitle = 'Search Result';
      urlBuilder.addParam('title', title);
    } else {
      pageTitle = 'Latest Updates';
    }

    if (offset != null && offset != 0) urlBuilder.addParam('offset', '$offset');

    var url = urlBuilder.build();
    debugPrint(url.toString());
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return MangaList.fromJson(convert.jsonDecode(response.body));
    } else {
      throw Exception('Failed to load manga images, ${response.statusCode}');
    }
  }

  Future<MangaList> nextPage(var offset) {
    debugPrint(offset.toString());
    offset = offset + 10;
    debugPrint(offset.toString());
    return getManga(_searchTitle, offset);
  }

  Future<MangaList> previousPage(var offset) {
    debugPrint(offset.toString());
    offset = offset - 10;
    debugPrint(offset.toString());
    if (offset < 0) return getManga(_searchTitle, 0);
    return getManga(_searchTitle, offset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
        title: Text(pageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
          ),
        ],
      )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 12.0,
              bottom: 8.0,
              left: 0.0,
              right: 0.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search manga...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
              ),
              onChanged: (title) {
                setState(() {
                  _searchTitle = title;
                  mangas = getManga(_searchTitle);
                });
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              bool? settingsChanged = await _settingDialogBuilder(context);
              if (settingsChanged != null && settingsChanged) {
                setState(() {
                  magazineDemographicList = selectedDemographics.map((item) => item.value as String).toList();
                  availableTranslatedLanguage = selectedLanguages.map((item) => item.value as String).toList();
                  contentRatingList = selectedRatings.map((item) => item.value as String).toList();
                  publicationStatusList = selectedPublications.map((item) => item.value as String).toList();
                  mangas = getManga(_searchTitle);
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: Container(
              width: 400,
              height: 55,
              padding: const EdgeInsets.all(10),
              child: const Center(
                child: Text(
                  "Open Filters",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
                  return Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                                        child: Image.network(
                                          'https://uploads.mangadex.org/covers/${manga.id}/${manga.getCoverId()?.attributes?.fileName}.256.jpg',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        manga.attributes?.title?.titles['en'] ??
                                            (manga.attributes?.title?.titles.isNotEmpty == true
                                                ? manga.attributes?.title?.titles.values.first
                                                : '')
                                            ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: snapshot.data!.offset! > 0
                                  ? () {
                                setState(() {
                                  mangas = previousPage(snapshot.data!.offset!);
                                });
                              }
                                  : null,
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              label: const Text(
                                'Previous',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: snapshot.data!.offset! + 11 < snapshot.data!.total!
                                  ? () {
                                setState(() {
                                  mangas = nextPage(snapshot.data!.offset!);
                                });
                              }
                                  : null,
                              icon: const Icon(Icons.arrow_forward, color: Colors.white),
                              label: const Text(
                                'Next',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _settingDialogBuilder(BuildContext context) {
    Language languages = Language();
    ContentRating contentRating = ContentRating();
    PublicationDemographic demographic = PublicationDemographic();
    ReadingStatus readingStatus = ReadingStatus();

    return showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Filters'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Include Languages: "),
                    MultiSelectDropDown<dynamic>(
                      searchEnabled: true,
                      controller: _availableTranslatedLanguageController,
                      hint: 'Languages',
                      onOptionSelected: (options) {
                        selectedLanguages = options.cast<ValueItem>();
                        debugPrint(availableTranslatedLanguage.toString());
                      },
                      options: languages.toValueItems(),
                      selectionType: SelectionType.multi,
                      chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                      optionTextStyle: const TextStyle(fontSize: 16),
                      selectedOptionIcon: const Icon(Icons.check_circle),
                    ),
                    const Text("Content Rating: "),
                    MultiSelectDropDown<dynamic>(
                      hint: 'Content Rating',
                      controller: _contentRatingListController,
                      onOptionSelected: (options) {
                        selectedRatings = options.cast<ValueItem>();
                        debugPrint(selectedRatings.toString());
                      },
                      options: contentRating.toValueItems(),
                      selectionType: SelectionType.multi,
                      chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                      optionTextStyle: const TextStyle(fontSize: 16),
                      selectedOptionIcon: const Icon(Icons.check_circle),
                    ),
                    const Text("Magazine Demographic: "),
                    MultiSelectDropDown<dynamic>(
                      hint: 'Magazine Demographic',
                      controller: _magazineDemographicListController,
                      onOptionSelected: (options) {
                        selectedDemographics = options.cast<ValueItem>();
                        debugPrint(selectedDemographics.toString());
                      },
                      options: demographic.toValueItems(),
                      selectionType: SelectionType.multi,
                      chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                      optionTextStyle: const TextStyle(fontSize: 16),
                      selectedOptionIcon: const Icon(Icons.check_circle),
                    ),
                    const Text("Publication Status: "),
                    MultiSelectDropDown<dynamic>(
                      hint: 'Publication Status',
                      controller: _publicationStatusListController,
                      onOptionSelected: (options) {
                        selectedPublications = options.cast<ValueItem>();
                        debugPrint(selectedPublications.toString());
                      },
                      options: readingStatus.toValueItems(),
                      selectionType: SelectionType.multi,
                      chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                      optionTextStyle: const TextStyle(fontSize: 16),
                      selectedOptionIcon: const Icon(Icons.check_circle),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
