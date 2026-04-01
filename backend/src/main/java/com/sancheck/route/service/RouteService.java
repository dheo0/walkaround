package com.sancheck.route.service;

import com.sancheck.route.dto.RouteRequest;
import com.sancheck.route.dto.RouteResponse;
import com.sancheck.route.entity.Bookmark;
import com.sancheck.route.entity.Route;
import com.sancheck.route.entity.RouteWaypoint;
import com.sancheck.route.repository.BookmarkRepository;
import com.sancheck.route.repository.RouteRepository;
import com.sancheck.user.entity.User;
import com.sancheck.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicInteger;

@Service
@RequiredArgsConstructor
public class RouteService {

    private final RouteRepository routeRepository;
    private final BookmarkRepository bookmarkRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public List<RouteResponse> getNearbyRoutes(double lat, double lng, double radiusKm) {
        return routeRepository.findNearbyRoutes(lat, lng, radiusKm).stream()
                .map(RouteResponse::from)
                .toList();
    }

    @Transactional(readOnly = true)
    public RouteResponse getRoute(UUID routeId) {
        Route route = findRouteOrThrow(routeId);
        return RouteResponse.from(route);
    }

    @Transactional
    public RouteResponse createRoute(RouteRequest request, UUID userId) {
        User creator = findUserOrThrow(userId);

        Route route = Route.builder()
                .name(request.getName())
                .description(request.getDescription())
                .distanceKm(request.getDistanceKm())
                .durationMin(request.getDurationMin())
                .difficulty(request.getDifficulty())
                .isPublic(request.getIsPublic() != null ? request.getIsPublic() : true)
                .isCustom(true)
                .source("user")
                .creator(creator)
                .build();

        AtomicInteger order = new AtomicInteger(0);
        request.getWaypoints().forEach(wp -> {
            RouteWaypoint waypoint = RouteWaypoint.builder()
                    .route(route)
                    .latitude(wp.getLatitude())
                    .longitude(wp.getLongitude())
                    .sequenceOrder(order.getAndIncrement())
                    .pointName(wp.getPointName())
                    .build();
            route.getWaypoints().add(waypoint);
        });

        return RouteResponse.from(routeRepository.save(route));
    }

    @Transactional
    public RouteResponse updateRoute(UUID routeId, RouteRequest request, UUID userId) {
        Route route = findRouteOrThrow(routeId);
        if (!route.isOwnedBy(userId)) {
            throw new AccessDeniedException("본인이 만든 경로만 수정할 수 있습니다.");
        }
        route.update(request.getName(), request.getDescription(),
                request.getDistanceKm(), request.getDurationMin(), request.getDifficulty());
        return RouteResponse.from(route);
    }

    @Transactional
    public void deleteRoute(UUID routeId, UUID userId) {
        Route route = findRouteOrThrow(routeId);
        if (!route.isOwnedBy(userId)) {
            throw new AccessDeniedException("본인이 만든 경로만 삭제할 수 있습니다.");
        }
        routeRepository.delete(route);
    }

    @Transactional(readOnly = true)
    public List<RouteResponse> getMyRoutes(UUID userId) {
        User user = findUserOrThrow(userId);
        return routeRepository.findByCreator(user).stream()
                .map(RouteResponse::from)
                .toList();
    }

    @Transactional
    public void addBookmark(UUID routeId, UUID userId) {
        User user = findUserOrThrow(userId);
        Route route = findRouteOrThrow(routeId);
        if (!bookmarkRepository.existsByUserAndRoute(user, route)) {
            bookmarkRepository.save(Bookmark.builder().user(user).route(route).build());
        }
    }

    @Transactional
    public void removeBookmark(UUID routeId, UUID userId) {
        User user = findUserOrThrow(userId);
        Route route = findRouteOrThrow(routeId);
        bookmarkRepository.findByUserAndRoute(user, route)
                .ifPresent(bookmarkRepository::delete);
    }

    @Transactional(readOnly = true)
    public List<RouteResponse> getMyBookmarks(UUID userId) {
        User user = findUserOrThrow(userId);
        return bookmarkRepository.findByUser(user).stream()
                .map(b -> RouteResponse.from(b.getRoute()))
                .toList();
    }

    private Route findRouteOrThrow(UUID routeId) {
        return routeRepository.findById(routeId)
                .orElseThrow(() -> new NoSuchElementException("경로를 찾을 수 없습니다: " + routeId));
    }

    private User findUserOrThrow(UUID userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new NoSuchElementException("사용자를 찾을 수 없습니다: " + userId));
    }
}
