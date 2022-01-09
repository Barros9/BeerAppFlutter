class Beer {
  final int id;
  final String name;
  final String tagline;
  final String description;
  final String? imageUrl;

  Beer({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.imageUrl,
  });

  factory Beer.fromJson(Map<String, dynamic> json) {
    return Beer(
      id: json['id'],
      name: json['name'],
      tagline: json['tagline'],
      description: json['description'],
      imageUrl: json['image_url'],
    );
  }
}
