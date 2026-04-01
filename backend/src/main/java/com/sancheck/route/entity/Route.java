package com.sancheck.route.entity;

import com.sancheck.user.entity.User;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "routes")
@EntityListeners(AuditingEntityListener.class)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class Route {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @Column(nullable = false)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "distance_km")
    private Double distanceKm;

    @Column(name = "duration_min")
    private Integer durationMin;

    @Column(length = 10)
    private String difficulty;  // easy, medium, hard

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "creator_id")
    private User creator;

    @Column(name = "is_public")
    @Builder.Default
    private Boolean isPublic = true;

    @Column(name = "is_custom")
    @Builder.Default
    private Boolean isCustom = false;

    // 'public_data' or 'user'
    @Builder.Default
    private String source = "user";

    @Column(name = "thumbnail_url")
    private String thumbnailUrl;

    @OneToMany(mappedBy = "route", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("sequenceOrder ASC")
    @Builder.Default
    private List<RouteWaypoint> waypoints = new ArrayList<>();

    @CreatedDate
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public void update(String name, String description, Double distanceKm,
                       Integer durationMin, String difficulty) {
        this.name = name;
        this.description = description;
        this.distanceKm = distanceKm;
        this.durationMin = durationMin;
        this.difficulty = difficulty;
    }

    public boolean isOwnedBy(UUID userId) {
        return creator != null && creator.getId().equals(userId);
    }
}
