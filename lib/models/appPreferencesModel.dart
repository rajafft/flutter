class AppPreferences {
  List categories;
  // List countries;
  List languages;
  List<Country> countries;
  List reportReasons;

  AppPreferences({
    required this.categories,
    required this.languages,
    required this.countries,
    required this.reportReasons
  });

  factory AppPreferences.fromJson(Map<String?, dynamic> json) {
    var jsonCountries = json['countries2'] as List;
    List<Country> countries = [];
    for (var jsonCountry in jsonCountries) {
      countries.add(Country.fromJson(jsonCountry));
    }
    return AppPreferences(
      categories: json['categories'] ?? [],
      languages: json['languages'] ?? [],
      countries: countries,
      reportReasons: json['report_reasons'] ?? []
    );
  }
}

class Country {
  final String name;
  final List cities;

  Country({required this.name, required this.cities});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      cities: json['countries'],
      name: json['name'],
    );
  }
}
