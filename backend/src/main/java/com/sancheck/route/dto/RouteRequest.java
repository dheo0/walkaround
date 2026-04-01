package com.sancheck.route.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import lombok.Getter;

import java.util.List;

@Getter
public class RouteRequest {

    @NotBlank
    private String name;

    private String description;

    private Double distanceKm;

    private Integer durationMin;

    private String difficulty;  // easy, medium, hard

    private Boolean isPublic = true;

    @NotEmpty
    @Valid
    private List<WaypointDto> waypoints;
}
