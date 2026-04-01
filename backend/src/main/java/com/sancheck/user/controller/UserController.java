package com.sancheck.user.controller;

import com.sancheck.route.dto.RouteResponse;
import com.sancheck.route.service.RouteService;
import com.sancheck.user.dto.UserResponse;
import com.sancheck.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final RouteService routeService;

    @GetMapping("/me")
    public ResponseEntity<UserResponse> getMyProfile(@AuthenticationPrincipal UUID userId) {
        return ResponseEntity.ok(userService.getUser(userId));
    }

    @GetMapping("/me/routes")
    public ResponseEntity<List<RouteResponse>> getMyRoutes(@AuthenticationPrincipal UUID userId) {
        return ResponseEntity.ok(routeService.getMyRoutes(userId));
    }

    @GetMapping("/me/bookmarks")
    public ResponseEntity<List<RouteResponse>> getMyBookmarks(@AuthenticationPrincipal UUID userId) {
        return ResponseEntity.ok(routeService.getMyBookmarks(userId));
    }

    @PostMapping("/me/bookmarks/{routeId}")
    public ResponseEntity<Void> addBookmark(
            @PathVariable UUID routeId,
            @AuthenticationPrincipal UUID userId) {
        routeService.addBookmark(routeId, userId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/me/bookmarks/{routeId}")
    public ResponseEntity<Void> removeBookmark(
            @PathVariable UUID routeId,
            @AuthenticationPrincipal UUID userId) {
        routeService.removeBookmark(routeId, userId);
        return ResponseEntity.noContent().build();
    }
}
