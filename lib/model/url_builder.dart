class UrlBuilder {
  String baseUrl;
  final String subUrl;
  Map<String, dynamic> _params = {};

  UrlBuilder(this.subUrl, {this.baseUrl = "https://api.mangadex.org/"});

  UrlBuilder addParam(String key, String value) {
    _params[key] = value;
    return this;
  }

  UrlBuilder addParams(Map<String, String> params) {
    _params.addAll(params);
    return this;
  }

  UrlBuilder addArrayParam(String key, List<String> values) {
    _params[key] = values;
    return this;
  }

  Uri build() {
    Map<String, String> stringParams = {};
    _params.forEach((key, value) {
      if (value is List<String>) {
        stringParams[key] = value.join(',');
      } else {
        stringParams[key] = value.toString();
      }
    });

    return Uri.parse(baseUrl + subUrl).replace(queryParameters: stringParams);
  }

  void reset() {
    _params = {};
  }
}
