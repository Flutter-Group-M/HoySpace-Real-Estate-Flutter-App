class Space {
  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final List<String> images;
  final List<String> amenities;
  final String category;
  final String hostId;
  final String hostName;
  final String hostImage;

  Space({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.images,
    required this.amenities,
    required this.category,
    required this.hostId,
    required this.hostName,
    required this.hostImage,
  });

  factory Space.fromJson(Map<String, dynamic> json) {
    // Host might be populated (Map) or just ID (String) depending on endpoint, 
    // but we updated getSpaces to populate.
    // Safety check just in case.
    String hId = "";
    String hName = "Host";
    String hImage = "";

    if (json['host'] != null) {
      if (json['host'] is Map) {
        hId = json['host']['_id']?.toString() ?? "";
        hName = json['host']['name'] ?? "Host";
        hImage = json['host']['image'] ?? "";
      } else if (json['host'] is String) {
        hId = json['host'];
      }
    }

    return Space(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? 'Unknown Space',
      description: json['description'] ?? 'No description available',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      location: json['location'] ?? 'Unknown Location',
      images: List<String>.from(json['images'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      category: json['category'] ?? 'Other',
      hostId: hId,
      hostName: hName,
      hostImage: hImage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'images': images,
      'amenities': amenities,
      'category': category,
    };
  }
}
