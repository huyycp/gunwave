import 'dart:math';

enum ImageSize {
  x1MB,
  x5MB,
  x10MB,
  x20MB,
}

extension CapacityCalculator on ImageSize {
  static final Map<String, int> UNIT_DICT= {
    'BYTE': 1,
    'KB': pow(2, 10).toInt(),
    'MB': pow(2, 20).toInt(),
    'GB': pow(2, 30).toInt(),
  };

  int toByte() {
    int value = int.parse(RegExp(r'\d+').firstMatch(name)?.group(0) ?? '0');
    String unit = RegExp(r'[A-Z]+').firstMatch(name)?.group(0) ?? '';
    return (value * UNIT_DICT[unit]! / UNIT_DICT['BYTE']!).floor();
  }

  int toKB() {
    int value = int.parse(RegExp(r'\d+').firstMatch(name)?.group(0) ?? '0');
    String unit = RegExp(r'[A-Z]+').firstMatch(name)?.group(0) ?? '';
    return (value * UNIT_DICT[unit]! / UNIT_DICT['KB']!).floor();
  }

  int toMB() {
    int value = int.parse(RegExp(r'\d+').firstMatch(name)?.group(0) ?? '0');
    String unit = RegExp(r'[A-Z]+').firstMatch(name)?.group(0) ?? '';
    return (value * UNIT_DICT[unit]! / UNIT_DICT['MB']!).floor();
  }

  int toGB() {
    int value = int.parse(RegExp(r'\d+').firstMatch(name)?.group(0) ?? '0');
    String unit = RegExp(r'[A-Z]+').firstMatch(name)?.group(0) ?? '';
    return (value * UNIT_DICT[unit]! / UNIT_DICT['GB']!).floor();
  }
}