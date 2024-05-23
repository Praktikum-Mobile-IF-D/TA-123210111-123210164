import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:ta_123210111_123210164/model/chapter_image.dart';
import 'package:ta_123210111_123210164/model/url_builder.dart';

class ChapterReadPage extends StatefulWidget {
  final String chapterId;
  ChapterReadPage({required this.chapterId});

  @override
  State<ChapterReadPage> createState() => _ChapterReadPageState();
}

class _ChapterReadPageState extends State<ChapterReadPage> {
  Future<ChapterImage>? circuits;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    circuits = fetchCircuits();
  }

  Future<ChapterImage> fetchCircuits() async {
    UrlBuilder urlBuilder = UrlBuilder('at-home/server/${widget.chapterId}');
    var url = urlBuilder.build();
    // var url = Uri.parse('https://api.mangadex.org/at-home/server/a54c491c-8e4c-4e97-8873-5b79e59da210');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return ChapterImage.fromJson(convert.jsonDecode(response.body));
    } else {
      throw Exception('Failed to load manga images');
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
      body: FutureBuilder<ChapterImage>(
        future: circuits,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.chapter == null || snapshot.data!.chapter!.data == null) {
            return const Center(child: Text('No data available'));
          } else {
            // var imageUrl = snapshot.data!.baseUrl! + '/data/' + snapshot.data!.chapter!.hash! + '/' + snapshot.data!.chapter!.data![index];
            var images = snapshot.data!.chapter!.dataSaver!;
            // todo: option data saver
            var image = snapshot.data!.baseUrl! + '/data-saver/' + snapshot.data!.chapter!.hash! + '/' + images[_currentIndex];
            return Column(
              children: [
                Expanded(
                  child: Image.network(image),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _currentIndex > 0
                          ? () {
                        setState(() {
                          _currentIndex--;
                        });
                      }
                          : null,
                      child: Text('Previous'),
                    ),
                    ElevatedButton(
                      onPressed: _currentIndex < images.length - 1
                          ? () {
                        setState(() {
                          _currentIndex++;
                        });
                      }
                          : null,
                      child: Text('Next'),
                    ),
                  ],
                ),
              ],
            );
            // return ListView.builder(
            //   itemCount: snapshot.data!.chapter!.data!.length,
            //   itemBuilder: (context, index) {
            //     var imageUrl = snapshot.data!.baseUrl! + '/data/' + snapshot.data!.chapter!.hash! + '/' + snapshot.data!.chapter!.data![index];
            //     return Card(
            //       elevation: 2,
            //       margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            //       child: Padding(
            //         padding: const EdgeInsets.all(10),
            //         child: ListTile(
            //           title: Image.network(imageUrl),
            //           trailing: const Icon(Icons.keyboard_arrow_right),
            //         ),
            //       ),
            //     );
            //   },
            // );
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
}