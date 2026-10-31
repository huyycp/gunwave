import 'package:flutter/services.dart';
import 'package:gunwave/utils/extensions/object_ex.dart';
import 'package:string_validator/string_validator.dart' as validator;
import 'package:intl/intl.dart';

extension StringEx on String? {
  bool get isNullOrEmpty => isNull || this!.isEmpty;

  String get capitalize => isNullOrEmpty ? '' : this![0].toUpperCase() + (this!.length > 1 ? this!.substring(1) : '');

  String get toReadable {
    if (isNullOrEmpty) return '';
    // Handle camel case
    String str = this!.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}'
    ).toLowerCase();
    // Handle snake case
    str = str.replaceAll('_', ' ');
    return str;
  }

  String truncate({int maxLength = 15}) {
    if (isNullOrEmpty) {
      return '';
    }
    String omission = '...';
    int partitionLength = (maxLength - omission.length) ~/ 2;
    String head = this!.substring(0, partitionLength + (maxLength + 1) % 2);
    String tail = this!.substring(this!.length - partitionLength);
    return head + omission + tail;
  }

  String? isValidLength(int maxLength, [int minLength = 0]) {
    if (isNullOrEmpty || this!.length > maxLength || this!.length < minLength) return 'String has invalid length';
    return null; 
  }

  String? isValidRange({int? max, int? min}) {
    if (isNullOrEmpty || (max != null && int.parse(this!) > max) || (min != null && int.parse(this!) < min)) return 'Number has invalid range';
    return null;
  }

  String? get isEmpty => isNullOrEmpty ? 'Cannot be empty' : null;
  String? get isEmail => isNullOrEmpty || !validator.isEmail(this!) ? 'Email is invalid' : null;
  String? get isUrl => isNullOrEmpty || !validator.isURL(this!) ? 'This is not a valid URL' : null;
  String? get isValidTime => isNullOrEmpty || !DateFormat('MM/dd/yyyy HH:mm').parse(this!).isAfter(DateTime.now().add(const Duration(minutes: 5))) ? 'Invalid duetime' : null;
}

class CommaToDotFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(',', '.');
    return newValue.copyWith(text: newText, selection: newValue.selection);
  }
}