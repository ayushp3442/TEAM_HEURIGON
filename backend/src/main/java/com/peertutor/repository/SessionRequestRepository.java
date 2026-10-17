package com.peertutor.repository;

import com.peertutor.entity.SessionRequest;
import com.peertutor.enums.RequestStatus;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface SessionRequestRepository extends JpaRepository<SessionRequest, Long> {

    List<SessionRequest> findBySlotIdAndStatus(Long slotId, RequestStatus status);

    long countBySlotIdAndStatus(Long slotId, RequestStatus status);

    boolean existsByStudentIdAndSlotId(Long studentId, Long slotId);

    @EntityGraph(attributePaths = {"student", "tutor", "tutor.user", "subject", "slot"})
    List<SessionRequest> findByStudentIdOrderByCreatedAtDesc(Long studentId);

    @EntityGraph(attributePaths = {"student", "tutor", "tutor.user", "subject", "slot"})
    List<SessionRequest> findByStudentIdAndStatusOrderByCreatedAtDesc(Long studentId, RequestStatus status);

    @EntityGraph(attributePaths = {"student", "tutor", "tutor.user", "subject", "slot"})
    List<SessionRequest> findByTutorIdOrderByCreatedAtDesc(Long tutorId);

    @EntityGraph(attributePaths = {"student", "tutor", "tutor.user", "subject", "slot"})
    List<SessionRequest> findByTutorIdAndStatusOrderByCreatedAtDesc(Long tutorId, RequestStatus status);

    @EntityGraph(attributePaths = {"student", "tutor", "tutor.user", "subject", "slot"})
    Optional<SessionRequest> findDetailedById(Long id);

    @EntityGraph(attributePaths = {"student", "tutor", "tutor.user", "subject", "slot"})
    @org.springframework.data.jpa.repository.Query("""
        SELECT r FROM SessionRequest r
        WHERE r.status = :status
          AND (r.student.id = :userId OR r.tutor.user.id = :userId)
    """)
    List<SessionRequest> findAcceptedForUser(@org.springframework.data.repository.query.Param("userId") Long userId,
                                            @org.springframework.data.repository.query.Param("status") RequestStatus status);

    @org.springframework.data.jpa.repository.Query("""
        SELECT r.slot.id, COUNT(r.id)
        FROM SessionRequest r
        WHERE r.slot.id IN :slotIds AND r.status = :status
        GROUP BY r.slot.id
    """)
    List<Object[]> countBySlotIdsAndStatus(@org.springframework.data.repository.query.Param("slotIds") java.util.Collection<Long> slotIds,
                                          @org.springframework.data.repository.query.Param("status") RequestStatus status);
}


