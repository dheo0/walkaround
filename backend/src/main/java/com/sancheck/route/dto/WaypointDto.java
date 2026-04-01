package com.sancheck.route.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class WaypointDto {

    @NotNull
    private Double latitude;

    @NotNull
    private Double longitude;

    private String pointName;
}
