import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'family_member.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? _defaultBaseUrl();

  final String baseUrl;

  static String _defaultBaseUrl() {
    const configuredUrl = String.fromEnvironment('API_BASE_URL');
    if (configuredUrl.isNotEmpty) return configuredUrl;
    return kIsWeb
        ? 'http://127.0.0.1/api-test/public'
        : 'http://10.0.2.2/api-test/public';
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<Map<String, dynamic>> _decode(http.Response response) async {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'Réponse invalide du serveur (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json;
    }

    final errors = json['errors'];
    if (errors is Map && errors.isNotEmpty) {
      throw ApiException(
        errors.values.first.toString(),
        statusCode: response.statusCode,
      );
    }
    throw ApiException(
      json['message']?.toString() ?? 'Erreur HTTP ${response.statusCode}.',
      statusCode: response.statusCode,
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      _uri('/accounts/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      _uri('/accounts/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _decode(response);
  }

  Future<List<FamilyMember>> getFamilyMembers() async {
    final response = await http.get(_uri('/famille-membres'));
    final json = await _decode(response);
    final data = json['data'];
    if (data is! List) return <FamilyMember>[];
    return data
        .whereType<Map>()
        .map((item) => FamilyMember.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<FamilyMember> createFamilyMember(
    FamilyMember member, {
    XFile? image,
  }) async {
    final request = http.MultipartRequest('POST', _uri('/famille-membres'));
    member.toJson().forEach((key, value) {
      request.fields[key] = value.toString();
    });
    await _attachImage(request, image);
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final json = await _decode(response);
    return FamilyMember.fromJson(
      Map<String, dynamic>.from(json['data'] as Map),
    );
  }

  Future<FamilyMember> updateFamilyMember(
    FamilyMember member, {
    XFile? image,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      _uri('/famille-membres/${member.id}'),
    );
    member.toJson().forEach((key, value) {
      request.fields[key] = value.toString();
    });
    await _attachImage(request, image);
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final json = await _decode(response);
    return FamilyMember.fromJson(
      Map<String, dynamic>.from(json['data'] as Map),
    );
  }

  Future<void> deleteFamilyMember(int id) async {
    final response = await http.delete(_uri('/famille-membres/$id'));
    await _decode(response);
  }

  Future<void> _attachImage(
    http.MultipartRequest request,
    XFile? image,
  ) async {
    if (image == null) return;
    if (kIsWeb) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          await image.readAsBytes(),
          filename: image.name,
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );
    }
  }
}
