import 'package:http/http.dart' as http;
import 'dart:convert';

class Api {
  static const String baseUrl = "http://10.0.2.2:3000"; // NestJS backend URL

  static Future<http.Response> post(String path, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = {'Content-Type': 'application/json'};
    return await http.post(url, headers: headers, body: jsonEncode(data));
  }

  static Future<http.Response> get(String path) async {
    final url = Uri.parse('$baseUrl$path');
    return await http.get(url);
  }
}
