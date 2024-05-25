class RandomManga {
  final String id;
  final String title;
  final String description;
  final List<String> tags;

  RandomManga({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
  });

  factory RandomManga.fromJson(Map<String, dynamic> json) {
    var attributes = json['attributes'];
    var title = attributes['title']['en'] ?? 'No title';
    var description = attributes['description'].isNotEmpty
        ? attributes['description']['en'] ?? 'No description'
        : 'No description';
    var tags = (attributes['tags'] as List)
        .map((tag) => tag['attributes']['name']['en'] as String)
        .toList();

    return RandomManga(
      id: json['id'],
      title: title,
      description: description,
      tags: tags,
    );
  }
}
