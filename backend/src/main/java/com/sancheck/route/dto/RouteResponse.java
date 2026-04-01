package com.sancheck.route.dto;

import com.sancheck.route.entity.Route;
import com.sancheck.route.entity.RouteWaypoint;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Getter
@Builder
public class RouteResponse {

    private UUID id;
    private String name;
    private String description;
    private Double distanceKm;
    private Integer durationMin;
    private String difficulty;
    private Boolean isPublic;
    private Boolean isCustom;
    private String source;
    private String thumbnailUrl;
    private CreatorInfo creator;
    private List<WaypointInfo> waypoints;
    private LocalDateTime createdAt;

    @Getter
    @Builder
    public static class CreatorInfo {
        private UUID id;
        private String name;
        private String profileImageUrl;
    }

    @Getter
    @Builder
    public static class WaypointInfo {
        private Double latitude;
        private Double longitude;
        private Integer sequenceOrder;
        private String pointName;
    }

    public static RouteResponse from(Route route) {
        return RouteResponse.builder()
                .id(route.getId())
                .name(route.getName())
                .description(route.getDescription())
                .distanceKm(route.getDistanceKm())
                .durationMin(route.getDurationMin())
                .difficulty(route.getDifficulty())
                .isPublic(route.getIsPublic())
                .isCustom(route.getIsCustom())
                .source(route.getSource())
                .thumbnailUrl(route.getThumbnailUrl())
                .creator(route.getCreator() == null ? null : CreatorInfo.builder()
                        .id(route.getCreator().getId())
                        .name(route.getCreator().getName())
                        .profileImageUrl(route.getCreator().getProfileImageUrl())
                        .build())
                .waypoints(route.getWaypoints().stream()
                        .map(w -> WaypointInfo.builder()
                                .latitude(w.getLatitude())
                                .longitude(w.getLongitude())
                                .sequenceOrder(w.getSequenceOrder())
                                .pointName(w.getPointName())
                                .build())
                        .toList())
                .createdAt(route.getCreatedAt())
                .build();
    }
}
