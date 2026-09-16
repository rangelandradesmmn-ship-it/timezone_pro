class Country {
  final int? id;
  final String countryName;
  final String cityName;
  final String timezone;
  final String utcOffset;
  final String flagCode; // ISO 3166-1 alpha-2 code
  final bool isFavorite;

  Country({
    this.id,
    required this.countryName,
    required this.cityName,
    required this.timezone,
    required this.utcOffset,
    required this.flagCode,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'country_name': countryName,
      'city_name': cityName,
      'timezone': timezone,
      'utc_offset': utcOffset,
      'flag_code': flagCode,
      'favorite': isFavorite ? 1 : 0,
    };
  }

  factory Country.fromMap(Map<String, dynamic> map) {
    return Country(
      id: map['id'],
      countryName: map['country_name'],
      cityName: map['city_name'],
      timezone: map['timezone'],
      utcOffset: map['utc_offset'],
      flagCode: map['flag_code'],
      isFavorite: map['favorite'] == 1,
    );
  }

  Country copyWith({
    int? id,
    String? countryName,
    String? cityName,
    String? timezone,
    String? utcOffset,
    String? flagCode,
    bool? isFavorite,
  }) {
    return Country(
      id: id ?? this.id,
      countryName: countryName ?? this.countryName,
      cityName: cityName ?? this.cityName,
      timezone: timezone ?? this.timezone,
      utcOffset: utcOffset ?? this.utcOffset,
      flagCode: flagCode ?? this.flagCode,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

