List<T> listFromJson<T>(List<dynamic>? json, T Function(Map<String, dynamic>) fromJson) {
  return json?.map((e) => fromJson(e)).toList() ?? [];
}