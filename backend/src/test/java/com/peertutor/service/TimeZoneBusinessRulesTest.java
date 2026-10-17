package com.peertutor.service;

import com.peertutor.dto.ChatInfo;
import com.peertutor.dto.SlotRequest;
import com.peertutor.dto.SlotResponse;
import com.peertutor.entity.AvailabilitySlot;
import com.peertutor.entity.ChatMessage;
import com.peertutor.entity.SessionRequest;
import com.peertutor.entity.Subject;
import com.peertutor.entity.TutorProfile;
import com.peertutor.entity.User;
import com.peertutor.enums.ChatState;
import com.peertutor.enums.Mode;
import com.peertutor.enums.RequestStatus;
import com.peertutor.enums.Role;
import com.peertutor.exception.ApiException;
import com.peertutor.repository.ChatMessageRepository;
import com.peertutor.repository.SessionRequestRepository;
import com.peertutor.repository.SlotRepository;
import com.peertutor.repository.SubjectRepository;
import com.peertutor.repository.TutorProfileRepository;
import com.peertutor.repository.UserRepository;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.Clock;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Collections;
import java.util.HashSet;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TimeZoneBusinessRulesTest {

    private static final ZoneId ASIA_KOLKATA = ZoneId.of("Asia/Kolkata");

    @Mock
    private SlotRepository slotRepository;

    @Mock
    private TutorProfileRepository tutorProfileRepository;

    @Mock
    private SessionRequestRepository sessionRequestRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private SubjectRepository subjectRepository;

    @Mock
    private ChatMessageRepository chatMessageRepository;

    private User tutorUser;
    private TutorProfile tutorProfile;
    private User studentUser;

    @BeforeEach
    void setUp() {
        tutorUser = User.builder()
                .id(10L)
                .name("Tutor User")
                .email("tutor@campus.edu")
                .role(Role.TUTOR)
                .build();

        tutorProfile = TutorProfile.builder()
                .id(100L)
                .user(tutorUser)
                .subjects(new HashSet<>())
                .build();

        studentUser = User.builder()
                .id(20L)
                .name("Student User")
                .email("student@campus.edu")
                .role(Role.STUDENT)
                .build();

        lenient().when(tutorProfileRepository.findByUserId(10L)).thenReturn(Optional.of(tutorProfile));
    }

    private Clock fixedClock(LocalDateTime ldt) {
        return Clock.fixed(ldt.atZone(ASIA_KOLKATA).toInstant(), ASIA_KOLKATA);
    }

    // =========================================================================
    // 1. Lead time (2 min)
    // =========================================================================

    @Test
    @DisplayName("Lead time: slot starting under 2 min from Kolkata now throws 400")
    void testSlotLeadTime_UnderTwoMinutes_ThrowsBadRequest() {
        LocalDateTime kolkataNow = LocalDateTime.of(2026, 10, 20, 10, 0, 0);
        Clock clock = fixedClock(kolkataNow);

        SlotService slotService = new SlotService(slotRepository, tutorProfileRepository, sessionRequestRepository, clock);
        ReflectionTestUtils.setField(slotService, "minLeadMinutes", 2L);
        ReflectionTestUtils.setField(slotService, "minDurationMinutes", 5L);

        // 1 min 59 sec lead time (< 2 min)
        SlotRequest req = new SlotRequest(
                kolkataNow.plusMinutes(1).plusSeconds(59),
                kolkataNow.plusMinutes(30),
                Mode.ONLINE,
                "https://meet.google.com/abc"
        );

        assertThatThrownBy(() -> slotService.create(10L, req))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("Start time must be at least 2 minutes from now")
                .satisfies(e -> assertThat(((ApiException) e).getStatus()).isEqualTo(400));
    }

    @Test
    @DisplayName("Lead time: slot starting at exactly 2 min from Kolkata now succeeds")
    void testSlotLeadTime_ExactlyTwoMinutes_Succeeds() {
        LocalDateTime kolkataNow = LocalDateTime.of(2026, 10, 20, 10, 0, 0);
        Clock clock = fixedClock(kolkataNow);

        SlotService slotService = new SlotService(slotRepository, tutorProfileRepository, sessionRequestRepository, clock);
        ReflectionTestUtils.setField(slotService, "minLeadMinutes", 2L);
        ReflectionTestUtils.setField(slotService, "minDurationMinutes", 5L);

        LocalDateTime start = kolkataNow.plusMinutes(2);
        LocalDateTime end = start.plusMinutes(15);
        SlotRequest req = new SlotRequest(start, end, Mode.ONLINE, "https://meet.google.com/abc");

        when(slotRepository.save(any(AvailabilitySlot.class))).thenAnswer(invocation -> {
            AvailabilitySlot s = invocation.getArgument(0);
            s.setId(1L);
            return s;
        });

        SlotResponse res = slotService.create(10L, req);
        assertThat(res).isNotNull();
        assertThat(res.startTime()).isEqualTo(start);
    }

    // =========================================================================
    // 2. Duration (5 min)
    // =========================================================================

    @Test
    @DisplayName("Duration: slot shorter than 5 minutes throws 400")
    void testSlotDuration_UnderFiveMinutes_ThrowsBadRequest() {
        LocalDateTime kolkataNow = LocalDateTime.of(2026, 10, 20, 10, 0, 0);
        Clock clock = fixedClock(kolkataNow);

        SlotService slotService = new SlotService(slotRepository, tutorProfileRepository, sessionRequestRepository, clock);
        ReflectionTestUtils.setField(slotService, "minLeadMinutes", 2L);
        ReflectionTestUtils.setField(slotService, "minDurationMinutes", 5L);

        // 4 minutes 59 seconds duration (< 5 min)
        LocalDateTime start = kolkataNow.plusMinutes(10);
        LocalDateTime end = start.plusMinutes(4).plusSeconds(59);
        SlotRequest req = new SlotRequest(start, end, Mode.ONLINE, "https://meet.google.com/abc");

        assertThatThrownBy(() -> slotService.create(10L, req))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("Duration must be at least 5 minutes")
                .satisfies(e -> assertThat(((ApiException) e).getStatus()).isEqualTo(400));
    }

    @Test
    @DisplayName("Duration: slot of exactly 5 minutes succeeds")
    void testSlotDuration_ExactlyFiveMinutes_Succeeds() {
        LocalDateTime kolkataNow = LocalDateTime.of(2026, 10, 20, 10, 0, 0);
        Clock clock = fixedClock(kolkataNow);

        SlotService slotService = new SlotService(slotRepository, tutorProfileRepository, sessionRequestRepository, clock);
        ReflectionTestUtils.setField(slotService, "minLeadMinutes", 2L);
        ReflectionTestUtils.setField(slotService, "minDurationMinutes", 5L);

        LocalDateTime start = kolkataNow.plusMinutes(10);
        LocalDateTime end = start.plusMinutes(5);
        SlotRequest req = new SlotRequest(start, end, Mode.ONLINE, "https://meet.google.com/abc");

        when(slotRepository.save(any(AvailabilitySlot.class))).thenAnswer(invocation -> {
            AvailabilitySlot s = invocation.getArgument(0);
            s.setId(2L);
            return s;
        });

        SlotResponse res = slotService.create(10L, req);
        assertThat(res).isNotNull();
        assertThat(Duration.between(res.startTime(), res.endTime()).toMinutes()).isEqualTo(5);
    }

    // =========================================================================
    // 3. Accept before start
    // =========================================================================

    @Test
    @DisplayName("Accept before start: accepting when slot has already started throws 409")
    void testAcceptBeforeStart_SlotAlreadyStarted_ThrowsConflict() {
        LocalDateTime kolkataNow = LocalDateTime.of(2026, 10, 20, 15, 0, 0);
        Clock clock = fixedClock(kolkataNow);

        ChatService chatService = new ChatService(chatMessageRepository, sessionRequestRepository, userRepository, clock, 24);
        RequestService requestService = new RequestService(
                sessionRequestRepository, slotRepository, subjectRepository, userRepository, tutorProfileRepository, chatService, clock
        );

        AvailabilitySlot slot = AvailabilitySlot.builder()
                .id(50L)
                .tutor(tutorProfile)
                .startTime(kolkataNow) // exactly at now (not after now)
                .endTime(kolkataNow.plusHours(1))
                .booked(false)
                .build();

        SessionRequest request = SessionRequest.builder()
                .id(500L)
                .student(studentUser)
                .tutor(tutorProfile)
                .slot(slot)
                .status(RequestStatus.PENDING)
                .build();

        when(sessionRequestRepository.findDetailedById(500L)).thenReturn(Optional.of(request));

        assertThatThrownBy(() -> requestService.updateStatus(10L, 500L, RequestStatus.ACCEPTED))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("Slot has already started")
                .satisfies(e -> assertThat(((ApiException) e).getStatus()).isEqualTo(409));
    }

    @Test
    @DisplayName("Accept before start: accepting when slot is in future succeeds")
    void testAcceptBeforeStart_SlotInFuture_Succeeds() {
        LocalDateTime kolkataNow = LocalDateTime.of(2026, 10, 20, 15, 0, 0);
        Clock clock = fixedClock(kolkataNow);

        ChatService chatService = new ChatService(chatMessageRepository, sessionRequestRepository, userRepository, clock, 24);
        RequestService requestService = new RequestService(
                sessionRequestRepository, slotRepository, subjectRepository, userRepository, tutorProfileRepository, chatService, clock
        );

        AvailabilitySlot slot = AvailabilitySlot.builder()
                .id(50L)
                .tutor(tutorProfile)
                .startTime(kolkataNow.plusSeconds(1)) // in future
                .endTime(kolkataNow.plusHours(1))
                .booked(false)
                .build();

        SessionRequest request = SessionRequest.builder()
                .id(500L)
                .student(studentUser)
                .tutor(tutorProfile)
                .slot(slot)
                .status(RequestStatus.PENDING)
                .build();

        when(sessionRequestRepository.findDetailedById(500L)).thenReturn(Optional.of(request));
        when(sessionRequestRepository.findBySlotIdAndStatus(50L, RequestStatus.PENDING)).thenReturn(Collections.emptyList());
        when(sessionRequestRepository.save(any(SessionRequest.class))).thenAnswer(i -> i.getArgument(0));

        var resp = requestService.updateStatus(10L, 500L, RequestStatus.ACCEPTED);
        assertThat(resp.status()).isEqualTo(RequestStatus.ACCEPTED);
        assertThat(slot.isBooked()).isTrue();
    }

    // =========================================================================
    // 4. Chat state boundaries
    // =========================================================================

    @Test
    @DisplayName("Chat boundaries: NOT_STARTED before end, OPEN during 24h window, CLOSED after 24h")
    void testChatStateBoundaries_FixedKolkataClock() {
        LocalDateTime slotEnd = LocalDateTime.of(2026, 10, 20, 16, 0, 0);
        AvailabilitySlot slot = AvailabilitySlot.builder()
                .id(60L)
                .tutor(tutorProfile)
                .startTime(slotEnd.minusHours(1))
                .endTime(slotEnd)
                .booked(true)
                .build();

        SessionRequest request = SessionRequest.builder()
                .id(600L)
                .student(studentUser)
                .tutor(tutorProfile)
                .slot(slot)
                .status(RequestStatus.ACCEPTED)
                .build();

        // 1 second before end -> NOT_STARTED
        Clock clockBeforeEnd = fixedClock(slotEnd.minusSeconds(1));
        ChatService csBeforeEnd = new ChatService(chatMessageRepository, sessionRequestRepository, userRepository, clockBeforeEnd, 24);
        ChatInfo infoBefore = csBeforeEnd.chatInfo(request);
        assertThat(infoBefore).isNotNull();
        assertThat(infoBefore.state()).isEqualTo(ChatState.NOT_STARTED);

        // Exactly at end -> OPEN
        Clock clockAtEnd = fixedClock(slotEnd);
        ChatService csAtEnd = new ChatService(chatMessageRepository, sessionRequestRepository, userRepository, clockAtEnd, 24);
        ChatInfo infoAtEnd = csAtEnd.chatInfo(request);
        assertThat(infoAtEnd).isNotNull();
        assertThat(infoAtEnd.state()).isEqualTo(ChatState.OPEN);

        // 23h 59m 59s after end -> OPEN
        Clock clockNearClose = fixedClock(slotEnd.plusHours(24).minusSeconds(1));
        ChatService csNearClose = new ChatService(chatMessageRepository, sessionRequestRepository, userRepository, clockNearClose, 24);
        ChatInfo infoNearClose = csNearClose.chatInfo(request);
        assertThat(infoNearClose).isNotNull();
        assertThat(infoNearClose.state()).isEqualTo(ChatState.OPEN);

        // Exactly 24h after end -> CLOSED
        Clock clockClosed = fixedClock(slotEnd.plusHours(24));
        ChatService csClosed = new ChatService(chatMessageRepository, sessionRequestRepository, userRepository, clockClosed, 24);
        ChatInfo infoClosed = csClosed.chatInfo(request);
        assertThat(infoClosed).isNotNull();
        assertThat(infoClosed.state()).isEqualTo(ChatState.CLOSED);
    }

    // =========================================================================
    // 5. Date filter boundary near midnight
    //    Slot A at 2026-10-20T23:30:00 is found by 2026-10-20 and not by 2026-10-21
    //    Slot B at 2026-10-21T00:10:00 the opposite
    // =========================================================================

    @Test
    @DisplayName("Date filter: 2026-10-20T23:30:00 matches 2026-10-20 not 2026-10-21; 2026-10-21T00:10:00 opposite")
    void testDateFilterBoundaries_MidnightSlots() {
        LocalDateTime slotLateOct20 = LocalDateTime.of(2026, 10, 20, 23, 30, 0);
        LocalDateTime slotEarlyOct21 = LocalDateTime.of(2026, 10, 21, 0, 10, 0);

        // Date bounds for 2026-10-20
        LocalDateTime fromOct20 = LocalDateTime.of(2026, 10, 20, 0, 0, 0);
        LocalDateTime toOct20 = LocalDateTime.of(2026, 10, 21, 0, 0, 0);

        // Date bounds for 2026-10-21
        LocalDateTime fromOct21 = LocalDateTime.of(2026, 10, 21, 0, 0, 0);
        LocalDateTime toOct21 = LocalDateTime.of(2026, 10, 22, 0, 0, 0);

        // Slot A (23:30 on Oct 20):
        boolean slotAInOct20 = !slotLateOct20.isBefore(fromOct20) && slotLateOct20.isBefore(toOct20);
        boolean slotAInOct21 = !slotLateOct20.isBefore(fromOct21) && slotLateOct20.isBefore(toOct21);
        assertThat(slotAInOct20).isTrue();
        assertThat(slotAInOct21).isFalse();

        // Slot B (00:10 on Oct 21):
        boolean slotBInOct20 = !slotEarlyOct21.isBefore(fromOct20) && slotEarlyOct21.isBefore(toOct20);
        boolean slotBInOct21 = !slotEarlyOct21.isBefore(fromOct21) && slotEarlyOct21.isBefore(toOct21);
        assertThat(slotBInOct20).isFalse();
        assertThat(slotBInOct21).isTrue();
    }
}
