import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../features/map/providers/map_provider.dart';
import '../models/route_model.dart';
import '../providers/route_provider.dart';

class RouteCreateScreen extends ConsumerStatefulWidget {
  const RouteCreateScreen({super.key});

  @override
  ConsumerState<RouteCreateScreen> createState() => _RouteCreateScreenState();
}

class _RouteCreateScreenState extends ConsumerState<RouteCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final List<LatLng> _waypoints = [];
  String _difficulty = 'easy';
  bool _isPublic = true;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(currentLocationProvider);
    final createState = ref.watch(routeCreateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('경로 만들기'),
        actions: [
          TextButton(
            onPressed: createState.isLoading ? null : _save,
            child: createState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    '저장',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 지도 영역 (탭으로 waypoint 추가)
          Expanded(
            flex: 3,
            child: locationAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('$err')),
              data: (location) => Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition:
                        CameraPosition(target: location, zoom: 15),
                    myLocationEnabled: true,
                    polylines: _waypoints.length >= 2
                        ? {
                            Polyline(
                              polylineId: const PolylineId('route'),
                              points: _waypoints,
                              color: const Color(0xFF4CAF50),
                              width: 4,
                            ),
                          }
                        : {},
                    markers: _waypoints
                        .asMap()
                        .entries
                        .map((e) => Marker(
                              markerId: MarkerId('wp_${e.key}'),
                              position: e.value,
                              infoWindow:
                                  InfoWindow(title: '지점 ${e.key + 1}'),
                            ))
                        .toSet(),
                    onTap: (latLng) {
                      setState(() => _waypoints.add(latLng));
                    },
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.touch_app,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              '지도를 탭하여 경로 포인트 추가 (${_waypoints.length}개)',
                              style: const TextStyle(fontSize: 13),
                            ),
                            const Spacer(),
                            if (_waypoints.isNotEmpty)
                              TextButton(
                                onPressed: () =>
                                    setState(() => _waypoints.removeLast()),
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.red),
                                child: const Text('되돌리기'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 폼 영역
          Expanded(
            flex: 2,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '경로 이름 *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? '이름을 입력해주세요' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: '설명 (선택)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('난이도: '),
                        ...[
                          ('easy', '쉬움'),
                          ('medium', '보통'),
                          ('hard', '어려움')
                        ].map((e) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: ChoiceChip(
                                label: Text(e.$2),
                                selected: _difficulty == e.$1,
                                onSelected: (_) =>
                                    setState(() => _difficulty = e.$1),
                                selectedColor: const Color(0xFF4CAF50),
                                labelStyle: TextStyle(
                                  color: _difficulty == e.$1
                                      ? Colors.white
                                      : null,
                                ),
                              ),
                            )),
                        const Spacer(),
                        const Text('공개'),
                        Switch(
                          value: _isPublic,
                          onChanged: (v) => setState(() => _isPublic = v),
                          activeColor: const Color(0xFF4CAF50),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_waypoints.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 2개의 경로 포인트를 추가해주세요.')),
      );
      return;
    }

    final waypoints = _waypoints
        .asMap()
        .entries
        .map((e) => RouteWaypointModel(
              latitude: e.value.latitude,
              longitude: e.value.longitude,
              sequenceOrder: e.key,
            ))
        .toList();

    final result = await ref.read(routeCreateProvider.notifier).createRoute(
          name: _nameController.text.trim(),
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          difficulty: _difficulty,
          isPublic: _isPublic,
          waypoints: waypoints,
        );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('경로가 저장되었습니다.')),
      );
      context.go('/routes/${result.id}');
    }
  }
}
