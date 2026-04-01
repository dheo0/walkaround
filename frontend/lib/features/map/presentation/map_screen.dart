import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../routes/models/route_model.dart';
import '../../routes/providers/route_provider.dart';
import '../providers/map_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(currentLocationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '산책',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: '경로 목록',
            onPressed: () => context.go('/routes'),
          ),
        ],
      ),
      body: locationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(err.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(currentLocationProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (location) {
          // 위치 로드 후 주변 경로 가져오기
          final nearbyAsync = ref.watch(nearbyRoutesProvider((
            lat: location.latitude,
            lng: location.longitude,
            radiusKm: 5.0,
          )));

          nearbyAsync.whenData((routes) => _buildMapOverlays(routes));

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: location,
                  zoom: 15,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                polylines: _polylines,
                markers: _markers,
                onMapCreated: (controller) => _mapController = controller,
              ),
              if (nearbyAsync.isLoading)
                const Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('주변 경로 탐색 중...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/routes/new'),
        icon: const Icon(Icons.add),
        label: const Text('경로 만들기'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
    );
  }

  void _buildMapOverlays(List<RouteModel> routes) {
    final polylines = <Polyline>{};
    final markers = <Marker>{};

    for (final route in routes) {
      if (route.waypoints.isEmpty) continue;

      // Polyline 경로 선
      polylines.add(Polyline(
        polylineId: PolylineId(route.id),
        points: route.waypoints
            .map((w) => LatLng(w.latitude, w.longitude))
            .toList(),
        color: const Color(0xFF4CAF50),
        width: 4,
      ));

      // 시작점 마커
      final start = route.waypoints.first;
      markers.add(Marker(
        markerId: MarkerId(route.id),
        position: LatLng(start.latitude, start.longitude),
        infoWindow: InfoWindow(
          title: route.name,
          snippet: '${route.distanceLabel} · ${route.durationLabel}',
          onTap: () => context.go('/routes/${route.id}'),
        ),
      ));
    }

    if (mounted) {
      setState(() {
        _polylines = polylines;
        _markers = markers;
      });
    }
  }
}
