class UrlBuilder {
  String baseUrl = "https://api.mangadex.org/";
  final String subUrl;
  Map<String, dynamic> _params = {};

  UrlBuilder(this.subUrl);

  // Method to add a parameter to the URL
  UrlBuilder addParam(String key, String value) {
    _params[key] = value;
    return this;
  }

  // Method to add multiple parameters to the URL
  UrlBuilder addParams(Map<String, String> params) {
    _params.addAll(params);
    return this;
  }

  UrlBuilder addArrayParam(String key, List<String> values) {
    _params[key] = values;
    return this;
  }

  // Method to build the final URL
  Uri build() {
    Uri uri = Uri.parse(baseUrl+subUrl).replace(queryParameters: _params);
    return uri;
  }

  // Method to reset parameters
  void reset() {
    _params = {};
  }
}
