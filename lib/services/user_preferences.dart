import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const _keyFirstName = 'user_first_name';
  static const _keyLastName = 'user_last_name';
  static const _keyEmail = 'user_email';
  static const _keyAge = 'user_age';
  static const _keyGender = 'user_gender';

  static Future<void> saveProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String age,
    required String gender,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFirstName, firstName);
    await prefs.setString(_keyLastName, lastName);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyAge, age);
    await prefs.setString(_keyGender, gender);
  }

  static Future<Map<String, String>> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'firstName': prefs.getString(_keyFirstName) ?? '',
      'lastName': prefs.getString(_keyLastName) ?? '',
      'email': prefs.getString(_keyEmail) ?? '',
      'age': prefs.getString(_keyAge) ?? '',
      'gender': prefs.getString(_keyGender) ?? 'Erkek',
    };
  }

  static Future<String> getGender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyGender) ?? 'Erkek';
  }
}
