import 'package:gunwave/utils/common_functions.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.authId,
    required this.gold,
  });

  final String id;

  final String name;
  
  // Refers to supabase user id
  final String authId;

  int gold;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    authId: json['auth_id']?.toString() ?? '',
    gold: intFromJson(json['gold']),
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'auth_id': authId,
    'gold': gold,
  };
}