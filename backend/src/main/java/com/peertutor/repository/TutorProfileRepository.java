package com.peertutor.repository;

import com.peertutor.entity.TutorProfile;
import com.peertutor.enums.Mode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface TutorProfileRepository extends JpaRepository<TutorProfile, Long> {

    Optional<TutorProfile> findByUserId(Long userId);

    @Query("SELECT t FROM TutorProfile t JOIN FETCH t.user LEFT JOIN FETCH t.subjects WHERE t.user.id = :userId")
    Optional<TutorProfile> findByUserIdWithDetails(@Param("userId") Long userId);

    @Query("SELECT t FROM TutorProfile t JOIN FETCH t.user LEFT JOIN FETCH t.subjects WHERE t.id = :id")
    Optional<TutorProfile> findByIdWithDetails(@Param("id") Long id);

    // Tutor discovery search query (§4.7, §6.4)
    @Query("""
        SELECT DISTINCT t FROM TutorProfile t
        JOIN FETCH t.user u
        LEFT JOIN FETCH t.subjects s
        WHERE (:excludeUserId IS NULL OR u.id <> :excludeUserId)
          AND (:subjectId IS NULL OR EXISTS (SELECT 1 FROM t.subjects sub WHERE sub.id = :subjectId))
          AND EXISTS (
            SELECT sl.id FROM AvailabilitySlot sl
            WHERE sl.tutor = t AND sl.booked = false AND sl.startTime > :now
              AND (:mode IS NULL OR sl.mode = :mode)
              AND (:from IS NULL OR sl.startTime >= :from)
              AND (:to IS NULL OR sl.startTime < :to))
        """)
    List<TutorProfile> search(
        @Param("subjectId") Long subjectId,
        @Param("mode") Mode mode,
        @Param("from") LocalDateTime from,
        @Param("to") LocalDateTime to,
        @Param("now") LocalDateTime now,
        @Param("excludeUserId") Long excludeUserId
    );
}
