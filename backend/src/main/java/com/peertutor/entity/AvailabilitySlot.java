package com.peertutor.entity;

import com.peertutor.enums.Mode;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
    name = "availability_slots",
    indexes = {
        // §5: CREATE INDEX idx_slots_tutor_start ON availability_slots(tutor_id, start_time)
        @Index(name = "idx_slots_tutor_start", columnList = "tutor_id, start_time")
    }
)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class AvailabilitySlot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // §5: tutor_id BIGINT NOT NULL REFERENCES tutor_profiles(id) ON DELETE CASCADE
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tutor_id", nullable = false)
    private TutorProfile tutor;

    // §5: start_time TIMESTAMP NOT NULL
    @Column(nullable = false)
    private LocalDateTime startTime;

    // §5: end_time TIMESTAMP NOT NULL
    @Column(nullable = false)
    private LocalDateTime endTime;

    // §5: mode VARCHAR(10) NOT NULL
    @Enumerated(EnumType.STRING)
    @Column(length = 10, nullable = false)
    private Mode mode;

    // §5: location_or_link VARCHAR(255)
    @Column(length = 255)
    private String locationOrLink;

    // §5: booked BOOLEAN NOT NULL DEFAULT FALSE
    @Builder.Default
    @Column(nullable = false)
    private boolean booked = false;

    // §5: version BIGINT DEFAULT 0 — optimistic locking for accept race
    @Version
    private Long version;
}
