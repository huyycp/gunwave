import 'package:gunwave/data/models/map_model.dart';
import 'package:gunwave/data/models/quiz_model.dart';
import 'package:gunwave/data/models/user_model.dart';
import 'package:gunwave/utils/list_utils.dart';

class RoomModel {
  RoomModel({
    required this.id,
    required this.mapId,
    required this.userId,
    required this.name,
    required this.private,
    required this.createdAt,
    required this.map,
    required this.user,
    this.quizzes = const [],
  });

  final String id;
  
  final String mapId;

  /// Creator id
  final String userId;

  final String name;

  final bool private;

  final DateTime? createdAt;

  final MapModel? map;

  final UserModel? user;

  final List<QuizModel> quizzes;

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id']?.toString() ?? '',
      mapId: json['map_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      private: json['private'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      map: json['maps'] != null ? MapModel.fromJson(json['maps']) : null,
      user: json['users'] != null ? UserModel.fromJson(json['users']) : null,
      quizzes: listFromJson(json['quizzes'], (js) => QuizModel.fromJson(js)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'map_id': mapId,
      'user_id': userId,
      'name': name,
      'private': private,
      'created_at': createdAt?.toIso8601String() ?? '',
      'maps': map?.toJson(),
      'user': user?.toJson(),
      'quizzes': quizzes.map((e) => e.toJson()).toList(),
    };
  }
}