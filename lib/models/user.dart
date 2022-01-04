class AppUser {
  String? uid;
  String? name;
  String? phoneNumber;
  String? imageUrl;
  String? email;
  int? rate;
  UserPreferences? preferences;

  AppUser({
    this.imageUrl,
    this.uid,
    this.name,
    this.phoneNumber,
    this.rate,
    this.email,
    this.preferences,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      imageUrl: json['image_url'],
      name: json['name'],
      phoneNumber: json['phone'],
      rate: json['rating'],
      uid: json['uid'],
      email: json['email'],
      preferences: UserPreferences.fromJson(json['preferences']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image_url': this.imageUrl,
      'name': this.name,
      'phone': this.phoneNumber,
      'rating': this.rate,
      'uid': this.uid,
      'email': this.email,
      'preferences': this.preferences?.toMap(),
    };
  }
}

class UserPreferences {
  List categories = [];
  String? country;
  String? city;
  String? language;
  bool? yardNotification;
  bool? chatNotification;

  UserPreferences({
    required this.categories,
    this.country,
    this.language,
    this.chatNotification,
    this.yardNotification,
    this.city,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
        categories: json['categories'],
        country: json['country'],
        city: json['city'],
        language: json['language'],
        chatNotification: json['chatNotification'],
        yardNotification: json['yardNotification']);
  }

  changeLanguage(String language) {
    this.language = language;
  }

  changeCountry(String country) {
    this.country = country;
    this.city = null;
  }

  chooseCategories(List newCategories) {
    this.categories = newCategories;
  }

  toggleYardNotification(bool value) {
    this.yardNotification = value;
  }

  toggleChatNotification(bool value) {
    this.chatNotification = value;
  }

  toggleCategory(String category) {
    if (categories.contains(category)) {
      categories.remove(category);
    } else {
      categories.add(category);
    }
  }

  changeCity(String cityName){
    this.city=cityName;
  }

  Map<String, dynamic> toMap() {
    return {
      'categories': this.categories,
      'country': this.country,
      'city': this.city,
      'language': this.language,
      'yardNotification': this.yardNotification ?? true,
      'chatNotification': this.chatNotification ?? true,
    };
  }

  String? categoriesStringTitle() {
    if (this.categories.isEmpty) {
      return null;
    } else if (categories.length == 1) {
      return categories.first.toString();
    } else {
      return '${categories.first},..';
    }
  }
}
