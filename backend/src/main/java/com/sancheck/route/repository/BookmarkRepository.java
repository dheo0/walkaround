package com.sancheck.route.repository;

import com.sancheck.route.entity.Bookmark;
import com.sancheck.route.entity.Route;
import com.sancheck.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface BookmarkRepository extends JpaRepository<Bookmark, UUID> {
    List<Bookmark> findByUser(User user);
    Optional<Bookmark> findByUserAndRoute(User user, Route route);
    boolean existsByUserAndRoute(User user, Route route);
}
