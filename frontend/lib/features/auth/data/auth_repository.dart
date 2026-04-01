import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.read(dioClientProvider),
    storage: ref.read(secureStorageProvider),
  );
});

class AuthUser {
  final String id;
  final String email;
  final String? name;
  final String? profileImageUrl;

  const AuthUser({
    required this.id,
    required this.email,
    this.name,
    this.profileImageUrl,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String?,
        profileImageUrl: json['profileImageUrl'] as String?,
      );
}

class AuthRepository {
  final Dio _dio;
  final SecureStorageService _storage;
  final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  AuthRepository({required Dio dio, required SecureStorageService storage})
      : _dio = dio,
        _storage = storage;

  Future<AuthUser?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) throw Exception('Google ID Token을 가져올 수 없습니다.');

    final response = await _dio.post('/api/auth/social-login', data: {
      'provider': 'google',
      'idToken': idToken,
    });

    final data = response.data as Map<String, dynamic>;
    await _storage.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );

    return AuthUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> signOut() async {
    await Future.wait([
      _googleSignIn.signOut(),
      _storage.clearTokens(),
    ]);
  }

  Future<AuthUser?> getCurrentUser() async {
    if (!await _storage.hasToken()) return null;
    try {
      final response = await _dio.get('/api/users/me');
      return AuthUser.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      await _storage.clearTokens();
      return null;
    }
  }
}
