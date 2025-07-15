// lib/data/models/group_model.dart
class GroupModel {
  final String id;
  final String name;
  final bool isGroup;
  final List<String> participants;
  final String? image;
  final String? description;
  final String? createdBy;
  final List<String> admins;

  GroupModel({
    required this.id,
    required this.name,
    required this.isGroup,
    required this.participants,
    this.image,
    this.description,
    this.createdBy,
    this.admins = const [],
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['_id'],
      name: json['name'] ?? '',
      isGroup: json['isGroup'] ?? true,
      participants: (json['participants'] as List).map((p) {
        if (p is String) return p;
        if (p is Map && p.containsKey('_id')) return p['_id'];
        return '';
      }).where((id) => id.isNotEmpty).cast<String>().toList(),
      image: json['image'],
      description: json['description'],
      createdBy: json['createdBy'] is String ? json['createdBy'] : json['createdBy']?['_id'],
      admins: (json['admins'] as List).map((a) {
        if (a is String) return a;
        if (a is Map && a.containsKey('_id')) return a['_id'];
        return '';
      }).where((id) => id.isNotEmpty).cast<String>().toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'isGroup': isGroup,
        'participants': participants,
        'image': image,
        'description': description,
        'createdBy': createdBy,
        'admins': admins,
      };
}
