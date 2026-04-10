class Video {
  final String title;
  final String description;
  final String views;
  final String url;

  Video({
    required this.title,
    required this.description,
    required this.views,
    required this.url,
  });

  factory Video.fromMap(Map<String, String> map) {
    return Video(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      views: map['views'] ?? '',
      url: map['url'] ?? '',
    );
  }
}
