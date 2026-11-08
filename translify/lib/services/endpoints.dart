class Endpoints {
  static const String base = "http://10.0.2.2:8000";
  static Uri me = Uri.parse("$base/me");

  static Uri signUp = Uri.parse("$base/signup");

  static Uri login = Uri.parse("$base/login");

  static Uri speechTranslate = Uri.parse("$base/translate/speech-to-text");

  static Uri imageTranslate = Uri.parse("$base/translate/image-to-text");

  static Uri userHistory = Uri.parse("$base/history");
}
