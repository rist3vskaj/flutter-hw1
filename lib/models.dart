class CatBreed {
  CatBreed({
    required this.id,
    required this.name,
    required this.origin,
    required this.description,
    required this.temperament,
    required this.lifeSpan,
    required this.intelligence,
    required this.energyLevel,
    required this.affectionLevel,
  });

  final String id;
  final String name;
  final String origin;
  final String description;
  final String temperament;
  final String lifeSpan;
  final int intelligence;
  final int energyLevel;
  final int affectionLevel;

  factory CatBreed.fromJson(Map<String, dynamic> json) {
    return CatBreed(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      origin: json['origin'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
      temperament: json['temperament'] as String? ?? '',
      lifeSpan: json['life_span'] as String? ?? '',
      intelligence: json['intelligence'] as int? ?? 0,
      energyLevel: json['energy_level'] as int? ?? 0,
      affectionLevel: json['affection_level'] as int? ?? 0,
    );
  }
}

class CatImage {
  CatImage({
    required this.id,
    required this.url,
    required this.width,
    required this.height,
    required this.breed,
  });

  final String id;
  final String url;
  final int width;
  final int height;
  final CatBreed? breed;

  factory CatImage.fromJson(Map<String, dynamic> json) {
    final breedsJson = json['breeds'] as List<dynamic>? ?? <dynamic>[];
    final CatBreed? breed = breedsJson.isNotEmpty
        ? CatBreed.fromJson(breedsJson.first as Map<String, dynamic>)
        : null;
    return CatImage(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
      breed: breed,
    );
  }
}
