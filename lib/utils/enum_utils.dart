T enumFromString<T>(Iterable<T> values, String? value, T defaultValue) {
  try {
    return values.firstWhere(
            (type) => (type as Enum).name.toLowerCase() == value?.toLowerCase());
  } catch (e) {
    return defaultValue;
  }
}

String enumToString<T>(T value) {
  return (value as Enum).name;
}