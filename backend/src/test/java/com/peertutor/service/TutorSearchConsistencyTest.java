package com.peertutor.service;

import com.peertutor.dto.NextSlotResponse;
import com.peertutor.dto.TutorCardResponse;
import com.peertutor.entity.AvailabilitySlot;
import com.peertutor.entity.Subject;
import com.peertutor.entity.TutorProfile;
import com.peertutor.entity.User;
import com.peertutor.enums.Mode;
import com.peertutor.enums.Role;
import com.peertutor.repository.SlotRepository;
import com.peertutor.repository.SubjectRepository;
import com.peertutor.repository.TutorProfileRepository;
import com.peertutor.repository.UserRepository;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@Transactional
class TutorSearchConsistencyTest {

    @Autowired
    private TutorService tutorService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TutorProfileRepository tutorProfileRepository;

    @Autowired
    private SlotRepository slotRepository;

    @Autowired
    private SubjectRepository subjectRepository;

    @Autowired
    private EntityManager entityManager;

    private TutorProfile tutorProfile;
    private LocalDateTime day1;
    private LocalDateTime day2;

    @BeforeEach
    void setUp() {
        // Fetch or create subject
        Subject subject = subjectRepository.findAll().stream().findFirst().orElseGet(() ->
                subjectRepository.save(new Subject(null, "Test Computer Science")));

        // Create tutor user
        User tutorUser = userRepository.save(User.builder()
                .name("Consistency Tutor")
                .email("consistency_tutor_" + System.currentTimeMillis() + "@campus.edu")
                .passwordHash("password123")
                .role(Role.TUTOR)
                .build());

        Set<Subject> subjects = new HashSet<>();
        subjects.add(subject);

        tutorProfile = tutorProfileRepository.save(TutorProfile.builder()
                .user(tutorUser)
                .bio("CS Tutor for Consistency Test")
                .department("CSE")
                .yearOfStudy(3)
                .subjects(subjects)
                .build());

        // Campus future dates (relative to campus clock)
        day1 = LocalDateTime.of(2026, 11, 10, 0, 0, 0);
        day2 = LocalDateTime.of(2026, 11, 11, 0, 0, 0);

        // Slot 1: Day 1 at 10:00 (ONLINE)
        slotRepository.save(AvailabilitySlot.builder()
                .tutor(tutorProfile)
                .startTime(day1.withHour(10))
                .endTime(day1.withHour(11))
                .mode(Mode.ONLINE)
                .locationOrLink("https://meet.google.com/online-1")
                .booked(false)
                .build());

        // Slot 2: Day 1 at 16:00 (ON_CAMPUS)
        slotRepository.save(AvailabilitySlot.builder()
                .tutor(tutorProfile)
                .startTime(day1.withHour(16))
                .endTime(day1.withHour(17))
                .mode(Mode.ON_CAMPUS)
                .locationOrLink("Lab 301")
                .booked(false)
                .build());

        // Slot 3: Day 2 at 14:00 (ONLINE)
        slotRepository.save(AvailabilitySlot.builder()
                .tutor(tutorProfile)
                .startTime(day2.withHour(14))
                .endTime(day2.withHour(15))
                .mode(Mode.ONLINE)
                .locationOrLink("https://meet.google.com/online-2")
                .booked(false)
                .build());

        entityManager.flush();
        entityManager.clear();
    }

    @Test
    @DisplayName("mode=ONLINE: openSlotCount is 2, nextSlot is earliest ONLINE slot (Day 1 10:00)")
    void testFilterByModeOnline() {
        List<TutorCardResponse> results = tutorService.searchTutors(null, null, "ONLINE", null);

        TutorCardResponse card = results.stream()
                .filter(r -> r.id().equals(tutorProfile.getId()))
                .findFirst()
                .orElseThrow(() -> new AssertionError("Tutor not found in search results"));

        assertThat(card.openSlotCount()).isEqualTo(2);
        assertThat(card.nextSlot()).isNotNull();
        assertThat(card.nextSlot().mode()).isEqualTo(Mode.ONLINE);
        assertThat(card.nextSlot().startTime()).isEqualTo(day1.withHour(10));
    }

    @Test
    @DisplayName("mode=ON_CAMPUS: openSlotCount is 1, nextSlot is the ON_CAMPUS slot (Day 1 16:00)")
    void testFilterByModeOnCampus() {
        List<TutorCardResponse> results = tutorService.searchTutors(null, null, "ON_CAMPUS", null);

        TutorCardResponse card = results.stream()
                .filter(r -> r.id().equals(tutorProfile.getId()))
                .findFirst()
                .orElseThrow(() -> new AssertionError("Tutor not found in search results"));

        assertThat(card.openSlotCount()).isEqualTo(1);
        assertThat(card.nextSlot()).isNotNull();
        assertThat(card.nextSlot().mode()).isEqualTo(Mode.ON_CAMPUS);
        assertThat(card.nextSlot().startTime()).isEqualTo(day1.withHour(16));
    }

    @Test
    @DisplayName("No filter: openSlotCount is 3 (all open future slots), nextSlot is earliest of all (Day 1 10:00)")
    void testNoFilterAllSlots() {
        List<TutorCardResponse> results = tutorService.searchTutors(null, null, null, null);

        TutorCardResponse card = results.stream()
                .filter(r -> r.id().equals(tutorProfile.getId()))
                .findFirst()
                .orElseThrow(() -> new AssertionError("Tutor not found in search results"));

        assertThat(card.openSlotCount()).isEqualTo(3);
        assertThat(card.nextSlot()).isNotNull();
        assertThat(card.nextSlot().startTime()).isEqualTo(day1.withHour(10));
    }

    @Test
    @DisplayName("date filter: with date=Day 2, nextSlot is on that date (Day 2 14:00) and openSlotCount is 1")
    void testFilterByDate() {
        List<TutorCardResponse> results = tutorService.searchTutors(null, null, null, "2026-11-11");

        TutorCardResponse card = results.stream()
                .filter(r -> r.id().equals(tutorProfile.getId()))
                .findFirst()
                .orElseThrow(() -> new AssertionError("Tutor not found in search results"));

        assertThat(card.openSlotCount()).isEqualTo(1);
        assertThat(card.nextSlot()).isNotNull();
        assertThat(card.nextSlot().startTime()).isEqualTo(day2.withHour(14));
        assertThat(card.nextSlot().mode()).isEqualTo(Mode.ONLINE);
    }
}
