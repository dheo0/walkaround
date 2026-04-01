import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/map/providers/map_provider.dart';
import '../models/route_model.dart';
import '../providers/route_provider.dart';
import '../../../shared/widgets/route_card.dart';

class RouteListScreen extends ConsumerStatefulWidget {
  const RouteListScreen({super.key});

  @override
  ConsumerState<RouteListScreen> createState() => _RouteListScreenState();
}

class _RouteListScreenState extends ConsumerState<RouteListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('산책 코스'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '주변 코스'),
            Tab(text: '북마크'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _NearbyRoutesList(),
          _BookmarkedRoutesList(),
        ],
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
}

class _NearbyRoutesList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(currentLocationProvider);

    return locationAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('위치 오류: $err')),
      data: (location) {
        final routesAsync = ref.watch(nearbyRoutesProvider((
          lat: location.latitude,
          lng: location.longitude,
          radiusKm: 5.0,
        )));

        return routesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('오류: $err')),
          data: (routes) => routes.isEmpty
              ? const Center(child: Text('주변 5km 내 산책 코스가 없습니다.'))
              : RefreshIndicator(
                  onRefresh: () async => ref.refresh(nearbyRoutesProvider((
                    lat: location.latitude,
                    lng: location.longitude,
                    radiusKm: 5.0,
                  ))),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: routes.length,
                    itemBuilder: (context, i) => RouteCard(
                      route: routes[i],
                      onTap: () => context.go('/routes/${routes[i].id}'),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _BookmarkedRoutesList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(myBookmarksProvider);

    return bookmarksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('오류: $err')),
      data: (routes) => routes.isEmpty
          ? const Center(child: Text('북마크한 코스가 없습니다.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: routes.length,
              itemBuilder: (context, i) => RouteCard(
                route: routes[i],
                onTap: () => context.go('/routes/${routes[i].id}'),
              ),
            ),
    );
  }
}
