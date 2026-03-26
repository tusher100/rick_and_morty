class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String originName;
  final String locationName;
  final String image;
  final bool isFavorite;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.originName,
    required this.locationName,
    required this.image,
    this.isFavorite = false,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      species: json['species'],
      type: json['type'] ?? '',
      gender: json['gender'],
      originName: json['origin']['name'],
      locationName: json['location']['name'],
      image: json['image'],
    );
  }

  // Merges API data with local edit overrides
  Character mergeWithEdits(Map<String, dynamic>? edits) {
    if (edits == null) return this;
    return Character(
      id: id,
      name: edits['name'] ?? name,
      status: edits['status'] ?? status,
      species: edits['species'] ?? species,
      type: edits['type'] ?? type,
      gender: edits['gender'] ?? gender,
      originName: edits['originName'] ?? originName,
      locationName: edits['locationName'] ?? locationName,
      image: image, // Image isn't editable based on requirements
      isFavorite: isFavorite,
    );
  }

  Character copyWith({bool? isFavorite}) {
    return Character(
      id: id,
      name: name,
      status: status,
      species: species,
      type: type,
      gender: gender,
      originName: originName,
      locationName: locationName,
      image: image,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}