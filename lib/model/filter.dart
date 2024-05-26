import 'package:multi_dropdown/models/value_item.dart';

class ContentRating {
  final Map<String, String> contentRatings = {
    'safe': 'safe',
    'suggestive': 'suggestive',
    'erotica': 'erotica',
    'pornographic': 'pornographic'
  };

  List<ValueItem> toValueItems() {
    return contentRatings.entries.map((e) => ValueItem(label: e.value, value: e.key)).toList();
  }
}

class PublicationDemographic {
  final Map<String, String> demographics = {
    'shounen': 'shounen',
    'shoujo': 'shoujo',
    'josei': 'josei',
    'seinen': 'seinen',
    'none': 'none'
  };
  List<ValueItem> toValueItems() {
    return demographics.entries.map((e) => ValueItem(label: e.value, value: e.key)).toList();
  }
}

class ReadingStatus {
  final Map<String, String> contentRatings = {
    'ongoing': 'ongoing',
    'completed': 'completed',
    'hiatus': 'hiatus',
    'cancelled': 'cancelled'
  };
  List<ValueItem> toValueItems() {
    return contentRatings.entries.map((e) => ValueItem(label: e.value, value: e.key)).toList();
  }
}