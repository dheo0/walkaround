import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../models/route_model.dart';

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return RouteRepository(dio: ref.read(dioClientProvider));
});

class RouteRepository {
  final Dio _dio;

  RouteRepository({required Dio dio}) : _dio = dio;

  Future<List<RouteModel>> getNearbyRoutes({
    required double lat,
    required double lng,
    double radiusKm = 5.0,
  }) async {
    final response = await _dio.get(
      '/api/routes/nearby',
      queryParameters: {'lat': lat, 'lng': lng, 'radius': radiusKm},
    );
    return (response.data as List<dynamic>)
        .map((e) => RouteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RouteModel> getRoute(String routeId) async {
    final response = await _dio.get('/api/routes/$routeId');
    return RouteModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RouteModel> createRoute({
    required String name,
    String? description,
    double? distanceKm,
    int? durationMin,
    String? difficulty,
    bool isPublic = true,
    required List<RouteWaypointModel> waypoints,
  }) async {
    final response = await _dio.post('/api/routes', data: {
      'name': name,
      'description': description,
      'distanceKm': distanceKm,
      'durationMin': durationMin,
      'difficulty': difficulty,
      'isPublic': isPublic,
      'waypoints': waypoints.map((w) => w.toJson()).toList(),
    });
    return RouteModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteRoute(String routeId) async {
    await _dio.delete('/api/routes/$routeId');
  }

  Future<List<RouteModel>> getMyRoutes() async {
    final response = await _dio.get('/api/users/me/routes');
    return (response.data as List<dynamic>)
        .map((e) => RouteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RouteModel>> getMyBookmarks() async {
    final response = await _dio.get('/api/users/me/bookmarks');
    return (response.data as List<dynamic>)
        .map((e) => RouteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addBookmark(String routeId) async {
    await _dio.post('/api/users/me/bookmarks/$routeId');
  }

  Future<void> removeBookmark(String routeId) async {
    await _dio.delete('/api/users/me/bookmarks/$routeId');
  }
}
