package com.peertutor.service;

import com.peertutor.entity.AvailabilitySlot;
import com.peertutor.entity.TutorProfile;
import com.peertutor.entity.User;
import com.peertutor.enums.Mode;
import com.peertutor.enums.Role;
import com.peertutor.repository.SlotRepository;
import com.peertutor.repository.TutorProfileRepository;
import com.peertutor.repository.UserRepository;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@Transactional
class TimeZoneRoundTripTest {

    @Autowired
    private SlotRepository slotRepository;

    @Autowired
    private TutorProfileRepository tutorProfileRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private EntityManager entityManager;

    @Test
    @DisplayName("Round-trip test: saving 2026-10-20T15:00:00 returns exactly 2026-10-20T15:00:00 and DB column has 2026-10-20 15:00:00")
    void testSlotRoundTripAndDatabaseColumn() {
        // Create user and tutor profile
        User tutorUser = userRepository.save(User.builder()
                .name("RoundTrip Tutor")
                .email("tz_roundtrip_" + System.currentTimeMillis() + "@campus.edu")
                .passwordHash("hashedpassword123")
                .role(Role.TUTOR)
                .build());

        TutorProfile profile = tutorProfileRepository.save(TutorProfile.builder()
                .user(tutorUser)
                .bio("Bio")
                .department("CS")
                .yearOfStudy(3)
                .build());

        LocalDateTime start = LocalDateTime.of(2026, 10, 20, 15, 0, 0);
        LocalDateTime end = LocalDateTime.of(2026, 10, 20, 16, 0, 0);

        AvailabilitySlot slot = AvailabilitySlot.builder()
                .tutor(profile)
                .startTime(start)
                .endTime(end)
                .mode(Mode.ONLINE)
                .locationOrLink("https://meet.google.com/test-tz")
                .booked(false)
                .build();

        AvailabilitySlot saved = slotRepository.save(slot);

        // Flush and clear Hibernate cache so we read directly from PostgreSQL
        entityManager.flush();
        entityManager.clear();

        // 1. Read back via Hibernate repository
        AvailabilitySlot retrieved = slotRepository.findById(saved.getId()).orElseThrow();
        assertThat(retrieved.getStartTime()).isEqualTo(LocalDateTime.of(2026, 10, 20, 15, 0, 0));
        assertThat(retrieved.getEndTime()).isEqualTo(LocalDateTime.of(2026, 10, 20, 16, 0, 0));

        // 2. Query raw database column value via JDBC
        String rawStartTime = jdbcTemplate.queryForObject(
                "SELECT start_time::text FROM availability_slots WHERE id = ?",
                String.class,
                saved.getId()
        );

        assertThat(rawStartTime).isEqualTo("2026-10-20 15:00:00");
    }
}
