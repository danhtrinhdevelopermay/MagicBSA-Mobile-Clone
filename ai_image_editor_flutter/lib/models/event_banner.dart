class EventBanner {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String actionUrl;
  final bool isActive;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventBanner({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.actionUrl,
    required this.isActive,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventBanner.fromJson(Map<String, dynamic> json) {
    return EventBanner(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      actionUrl: json['actionUrl'],
      isActive: json['isActive'] ?? true,
      order: int.tryParse(json['order'].toString()) ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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
      'order': order.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}