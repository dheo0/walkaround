package com.sancheck.route.repository;

import com.sancheck.route.entity.Route;
import com.sancheck.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface RouteRepository extends JpaRepository<Route, UUID> {

    List<Route> findByCreator(User creator);

    List<Route> findByIsPublicTrue();

    /**
     * 주어진 좌표 반경 내의 공개 경로 조회.
     * 첫 번째 waypoint 기준으로 중심점을 계산합니다.
     * 1도 위도 ≈ 111km 를 기준으로 근사 계산합니다.
     */
    @Query("""
        SELECT DISTINCT r FROM Route r
        JOIN r.waypoints w
        WHERE r.isPublic = true
          AND w.sequenceOrder = 0
          AND (6371 * acos(
                cos(radians(:lat)) * cos(radians(w.latitude)) *
                cos(radians(w.longitude) - radians(:lng)) +
                sin(radians(:lat)) * sin(radians(w.latitude))
              )) <= :radiusKm
        ORDER BY r.createdAt DESC
        """)
    List<Route> findNearbyRoutes(
            @Param("lat") double lat,
            @Param("lng") double lng,
            @Param("radiusKm") double radiusKm
    );
}
