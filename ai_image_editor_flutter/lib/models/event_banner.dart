class EventBanner {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String actionUrl;
  final bool isActive;
  final int priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventBanner({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.actionUrl,
    required this.isActive,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventBanner.fromJson(Map<String, dynamic> json) {
    return EventBanner(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      actionUrl: json['action_url'] ?? json['actionUrl'] ?? '',
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      priority: int.tryParse(json['priority'].toString()) ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'isActive': isActive,
      'priority': priority.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}