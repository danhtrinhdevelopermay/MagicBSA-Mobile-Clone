class VideoJob {
  final String id;
  final String userEmail;
  final String userName;
  final String? phoneNumber;
  final String originalImageUrl;
  final String videoStyle;
  final String duration;
  final String? description;
  final String? resultVideoUrl;
  final String status; // pending, processing, completed, failed
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  VideoJob({
    required this.id,
    required this.userEmail,
    required this.userName,
    this.phoneNumber,
    required this.originalImageUrl,
    required this.videoStyle,
    required this.duration,
    this.description,
    this.resultVideoUrl,
    required this.status,
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VideoJob.fromJson(Map<String, dynamic> json) {
    return VideoJob(
      id: json['id'],
      userEmail: json['userEmail'],
      userName: json['userName'],
      phoneNumber: json['phoneNumber'],
      originalImageUrl: json['originalImageUrl'],
      videoStyle: json['videoStyle'],
      duration: json['duration'],
      description: json['description'],
      resultVideoUrl: json['resultVideoUrl'],
      status: json['status'],
      adminNotes: json['adminNotes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userEmail': userEmail,
      'userName': userName,
      'phoneNumber': phoneNumber,
      'originalImageUrl': originalImageUrl,
      'videoStyle': videoStyle,
      'duration': duration,
      'description': description,
      'resultVideoUrl': resultVideoUrl,
      'status': status,
      'adminNotes': adminNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}