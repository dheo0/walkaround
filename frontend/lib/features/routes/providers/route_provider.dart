import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/route_repository.dart';
import '../models/route_model.dart';

// 주변 경로 목록 (위도, 경도, 반경)
final nearbyRoutesProvider = FutureProvider.family<List<RouteModel>,
    ({double lat, double lng, double radiusKm})>((ref, params) async {
  return ref.read(routeRepositoryProvider).getNearbyRoutes(
        lat: params.lat,
        lng: params.lng,
        radiusKm: params.radiusKm,
      );
});

// 경로 상세
final routeDetailProvider =
    FutureProvider.family<RouteModel, String>((ref, routeId) async {
  return ref.read(routeRepositoryProvider).getRoute(routeId);
});

// 내 경로 목록
final myRoutesProvider = FutureProvider<List<RouteModel>>((ref) async {
  return ref.read(routeRepositoryProvider).getMyRoutes();
});

// 내 북마크 목록
final myBookmarksProvider = FutureProvider<List<RouteModel>>((ref) async {
  return ref.read(routeRepositoryProvider).getMyBookmarks();
});

// 경로 생성 상태 관리
class RouteCreateNotifier extends StateNotifier<AsyncValue<void>> {
  final RouteRepository _repository;

  RouteCreateNotifier(this._repository) : super(const AsyncData(null));

  Future<RouteModel?> createRoute({
    required String name,
    String? description,
    double? distanceKm,
    int? durationMin,
    String? difficulty,
    bool isPublic = true,
    required List<RouteWaypointModel> waypoints,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await _repository.createRoute(
        name: name,
        description: description,
        distanceKm: distanceKm,
        durationMin: durationMin,
        difficulty: difficulty,
        isPublic: isPublic,
        waypoints: waypoints,
      );
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final routeCreateProvider =
    StateNotifierProvider<RouteCreateNotifier, AsyncValue<void>>((ref) {
  return RouteCreateNotifier(ref.read(routeRepositoryProvider));
});
