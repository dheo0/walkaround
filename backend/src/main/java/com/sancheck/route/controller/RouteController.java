package com.sancheck.route.controller;

import com.sancheck.route.dto.RouteRequest;
import com.sancheck.route.dto.RouteResponse;
import com.sancheck.route.service.RouteService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/routes")
@RequiredArgsConstructor
public class RouteController {

    private final RouteService routeService;

    /** 주변 경로 조회 (인증 불필요) */
    @GetMapping("/nearby")
    public ResponseEntity<List<RouteResponse>> getNearbyRoutes(
            @RequestParam double lat,
            @RequestParam double lng,
            @RequestParam(defaultValue = "5.0") double radius) {
        return ResponseEntity.ok(routeService.getNearbyRoutes(lat, lng, radius));
    }

    /** 경로 상세 조회 (인증 불필요) */
    @GetMapping("/{id}")
    public ResponseEntity<RouteResponse> getRoute(@PathVariable UUID id) {
        return ResponseEntity.ok(routeService.getRoute(id));
    }

    /** 커스텀 경로 생성 */
    @PostMapping
    public ResponseEntity<RouteResponse> createRoute(
            @Valid @RequestBody RouteRequest request,
            @AuthenticationPrincipal UUID userId) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(routeService.createRoute(request, userId));
    }

    /** 경로 수정 (본인만) */
    @PutMapping("/{id}")
    public ResponseEntity<RouteResponse> updateRoute(
            @PathVariable UUID id,
            @Valid @RequestBody RouteRequest request,
            @AuthenticationPrincipal UUID userId) {
        return ResponseEntity.ok(routeService.updateRoute(id, request, userId));
    }

    /** 경로 삭제 (본인만) */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteRoute(
            @PathVariable UUID id,
            @AuthenticationPrincipal UUID userId) {
        routeService.deleteRoute(id, userId);
        return ResponseEntity.noContent().build();
    }
}
