package com.peertutor.repository;

import com.peertutor.entity.AvailabilitySlot;
import com.peertutor.enums.Mode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;

public interface SlotRepository extends JpaRepository<AvailabilitySlot, Long> {

    @Query("SELECT s FROM AvailabilitySlot s WHERE s.tutor.id = :tutorId AND s.endTime > :now ORDER BY s.startTime ASC")
    List<AvailabilitySlot> findActiveSlotsForTutor(@Param("tutorId") Long tutorId, @Param("now") LocalDateTime now);

    @Query("SELECT s FROM AvailabilitySlot s WHERE s.tutor.id = :tutorId AND s.booked = false AND s.startTime > :now ORDER BY s.startTime ASC")
    List<AvailabilitySlot> findOpenFutureSlotsForTutor(@Param("tutorId") Long tutorId, @Param("now") LocalDateTime now);

    @Query("""
        SELECT sl FROM AvailabilitySlot sl
        WHERE sl.tutor.id IN :tutorIds
          AND sl.booked = false AND sl.startTime > :now
          AND (:mode IS NULL OR sl.mode = :mode)
          AND (:from IS NULL OR sl.startTime >= :from)
          AND (:to IS NULL OR sl.startTime < :to)
        ORDER BY sl.startTime ASC
        """)
    List<AvailabilitySlot> findMatchingSlotsForTutors(
        @Param("tutorIds") Collection<Long> tutorIds,
        @Param("mode") Mode mode,
        @Param("from") LocalDateTime from,
        @Param("to") LocalDateTime to,
        @Param("now") LocalDateTime now
    );
    @org.springframework.data.jpa.repository.EntityGraph(attributePaths = {"tutor", "tutor.user", "tutor.subjects"})
    java.util.Optional<AvailabilitySlot> findDetailedById(Long id);
}
