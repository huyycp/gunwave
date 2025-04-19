extension UriExtensions on Uri {
  Map<String, dynamic> toJson() {
    return {
      'scheme': scheme,
      'host': host,
      'path': path,
      'pathSegments': pathSegments,
    };
  }
}