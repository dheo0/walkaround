import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/route_model.dart';
import '../providers/route_provider.dart';
import '../data/route_repository.dart';

class RouteDetailScreen extends ConsumerWidget {
  final String routeId;

  const RouteDetailScreen({super.key, required this.routeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeAsync = ref.watch(routeDetailProvider(routeId));

    return Scaffold(
      body: routeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('오류: $err')),
        data: (route) => _RouteDetailContent(route: route),
      ),
    );
  }
}

class _RouteDetailContent extends ConsumerStatefulWidget {
  final RouteModel route;

  const _RouteDetailContent({required this.route});

  @override
  ConsumerState<_RouteDetailContent> createState() =>
      _RouteDetailContentState();
}

class _RouteDetailContentState extends ConsumerState<_RouteDetailContent> {
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    final route = widget.route;
    final waypoints = route.waypoints;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(route.name),
            background: waypoints.isNotEmpty
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        waypoints.first.latitude,
                        waypoints.first.longitude,
                      ),
                      zoom: 14,
                    ),
                    polylines: {
                      Polyline(
                        polylineId: PolylineId(route.id),
                        points: waypoints
                            .map((w) => LatLng(w.latitude, w.longitude))
                            .toList(),
                        color: const Color(0xFF4CAF50),
                        width: 4,
                      ),
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('start'),
                        position: LatLng(
                          waypoints.first.latitude,
                          waypoints.first.longitude,
                        ),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen),
                      ),
                    },
                    zoomControlsEnabled: false,
                    scrollGesturesEnabled: false,
                  )
                : Container(color: Colors.grey[200]),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                color: _isBookmarked ? const Color(0xFF4CAF50) : null,
              ),
              onPressed: _toggleBookmark,
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 통계 카드들
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.straighten,
                      label: route.distanceLabel,
                      sublabel: '거리',
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      icon: Icons.timer,
                      label: route.durationLabel,
                      sublabel: '소요 시간',
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      icon: Icons.terrain,
                      label: route.difficultyLabel,
                      sublabel: '난이도',
                    ),
                  ],
                ),
                if (route.description != null) ...[
                  const SizedBox(height: 24),
                  const Text(
                    '코스 설명',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    route.description!,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                ],
                if (route.creator != null) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        route.creator!.name ?? '알 수 없음',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      if (route.isCustom)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '커스텀',
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleBookmark() async {
    try {
      final repo = ref.read(routeRepositoryProvider);
      if (_isBookmarked) {
        await repo.removeBookmark(widget.route.id);
      } else {
        await repo.addBookmark(widget.route.id);
      }
      setState(() => _isBookmarked = !_isBookmarked);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    }
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F9F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF4CAF50), size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              sublabel,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
