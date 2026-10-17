package com.peertutor.entity;

import com.peertutor.enums.RequestStatus;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
    name = "session_requests",
    // §5: UNIQUE (student_id, slot_id)
    uniqueConstraints = {
        @UniqueConstraint(name = "uq_student_slot", columnNames = {"student_id", "slot_id"})
    },
    // §5: idx_req_tutor_status, idx_req_student
    indexes = {
        @Index(name = "idx_req_tutor_status", columnList = "tutor_id, status"),
        @Index(name = "idx_req_student",      columnList = "student_id")
    }
)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class SessionRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // §5: student_id BIGINT NOT NULL REFERENCES users(id)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id", nullable = false)
    private User student;

    // §5: tutor_id BIGINT NOT NULL REFERENCES tutor_profiles(id)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tutor_id", nullable = false)
    private TutorProfile tutor;

    // §5: slot_id BIGINT NOT NULL REFERENCES availability_slots(id) ON DELETE CASCADE
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "slot_id", nullable = false)
    private AvailabilitySlot slot;

    // §5: subject_id BIGINT NOT NULL REFERENCES subjects(id)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "subject_id", nullable = false)
    private Subject subject;

    // §5: message VARCHAR(300)
    @Column(length = 300)
    private String message;

    // §5: status VARCHAR(10) NOT NULL DEFAULT 'PENDING'
    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(length = 10, nullable = false)
    private RequestStatus status = RequestStatus.PENDING;

    @Column(updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
        if (status == null) status = RequestStatus.PENDING;
    }
}
