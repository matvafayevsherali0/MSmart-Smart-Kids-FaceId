import 'dart:convert';

String getFullNameFromJson(String jsonStr) {
  final Map<String, dynamic> data = jsonDecode(jsonStr);

  final String lastname = data['lastname'] ?? '';
  final String firstname = data['firstname'] ?? '';

  return "$lastname $firstname".trim();
}
