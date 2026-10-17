package com.peertutor.service;

import com.peertutor.dto.ChatInfo;
import com.peertutor.dto.MessageResponse;
import com.peertutor.entity.*;
import com.peertutor.enums.ChatState;
import com.peertutor.enums.Mode;
import com.peertutor.enums.RequestStatus;
import com.peertutor.enums.Role;
import com.peertutor.exception.ApiException;
import com.peertutor.repository.ChatMessageRepository;
import com.peertutor.repository.SessionRequestRepository;
import com.peertutor.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Clock;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ChatServiceTest {

    private static final ZoneId KOLKATA = ZoneId.of("Asia/Kolkata");

    @Mock
    private ChatMessageRepository messageRepo;

    @Mock
    private SessionRequestRepository requestRepo;

    @Mock
    private UserRepository userRepo;

    private User student;
    private User tutorUser;
    private TutorProfile tutorProfile;
    private AvailabilitySlot slot;
    private SessionRequest acceptedRequest;
    private LocalDateTime slotEnd;

    @BeforeEach
    void setUp() {
        student = User.builder()
                .id(1L)
                .name("Aarav Sharma")
                .email("aarav@campus.edu")
                .role(Role.STUDENT)
                .build();

        tutorUser = User.builder()
                .id(12L)
                .name("Priya Verma")
                .email("priya@campus.edu")
                .role(Role.TUTOR)
                .build();

        tutorProfile = TutorProfile.builder()
                .id(7L)
                .user(tutorUser)
                .build();

        slotEnd = LocalDateTime.of(2026, 10, 20, 16, 0, 0);

        slot = AvailabilitySlot.builder()
                .id(31L)
                .tutor(tutorProfile)
                .startTime(slotEnd.minusHours(1))
                .endTime(slotEnd)
                .mode(Mode.ONLINE)
                .locationOrLink("https://meet.google.com/test")
                .booked(true)
                .build();

        acceptedRequest = SessionRequest.builder()
                .id(55L)
                .student(student)
                .tutor(tutorProfile)
                .slot(slot)
                .status(RequestStatus.ACCEPTED)
                .createdAt(slotEnd.minusDays(1))
                .build();
    }

    private Clock createFixedClock(LocalDateTime ldt) {
        return Clock.fixed(ldt.atZone(KOLKATA).toInstant(), KOLKATA);
    }

    private ChatService createServiceWithClock(LocalDateTime ldt) {
        return new ChatService(messageRepo, requestRepo, userRepo, createFixedClock(ldt), 24);
    }

    // 1. State calculation before the end -> NOT_STARTED
    @Test
    void testStateBeforeEndTime_isNotStarted() {
        LocalDateTime now = slotEnd.minusSeconds(1); // 2026-10-20T15:59:59
        ChatService service = createServiceWithClock(now);

        ChatInfo info = service.chatInfo(acceptedRequest);

        assertThat(info).isNotNull();
        assertThat(info.state()).isEqualTo(ChatState.NOT_STARTED);
        assertThat(info.opensAt()).isEqualTo(slotEnd);
        assertThat(info.closesAt()).isEqualTo(slotEnd.plusHours(24));
    }

    // 2. State calculation exactly at the end -> OPEN
    @Test
    void testStateExactlyAtEndTime_isOpen() {
        LocalDateTime now = slotEnd; // 2026-10-20T16:00:00
        ChatService service = createServiceWithClock(now);

        ChatInfo info = service.chatInfo(acceptedRequest);

        assertThat(info).isNotNull();
        assertThat(info.state()).isEqualTo(ChatState.OPEN);
        assertThat(info.opensAt()).isEqualTo(slotEnd);
        assertThat(info.closesAt()).isEqualTo(slotEnd.plusHours(24));
    }

    // 3. State calculation 23h59m after the end -> OPEN
    @Test
    void testStateTwentyThreeHoursFiftyNineMinutesAfterEndTime_isOpen() {
        LocalDateTime now = slotEnd.plusHours(23).plusMinutes(59); // 2026-10-21T15:59:00
        ChatService service = createServiceWithClock(now);

        ChatInfo info = service.chatInfo(acceptedRequest);

        assertThat(info).isNotNull();
        assertThat(info.state()).isEqualTo(ChatState.OPEN);
        assertThat(info.opensAt()).isEqualTo(slotEnd);
        assertThat(info.closesAt()).isEqualTo(slotEnd.plusHours(24));
    }

    // 4. State calculation exactly at 24h -> CLOSED
    @Test
    void testStateExactlyAtTwentyFourHours_isClosed() {
        LocalDateTime now = slotEnd.plusHours(24); // 2026-10-21T16:00:00
        ChatService service = createServiceWithClock(now);

        ChatInfo info = service.chatInfo(acceptedRequest);

        assertThat(info).isNotNull();
        assertThat(info.state()).isEqualTo(ChatState.CLOSED);
        assertThat(info.opensAt()).isEqualTo(slotEnd);
        assertThat(info.closesAt()).isEqualTo(slotEnd.plusHours(24));
    }

    // 5. State calculation after 24h -> CLOSED
    @Test
    void testStateAfterTwentyFourHours_isClosed() {
        LocalDateTime now = slotEnd.plusHours(24).plusSeconds(1); // 2026-10-21T16:00:01
        ChatService service = createServiceWithClock(now);

        ChatInfo info = service.chatInfo(acceptedRequest);

        assertThat(info).isNotNull();
        assertThat(info.state()).isEqualTo(ChatState.CLOSED);
    }

    // 6. Non-accepted request returns null chatInfo
    @Test
    void testNonAcceptedRequest_returnsNullChatInfo() {
        acceptedRequest.setStatus(RequestStatus.PENDING);
        ChatService service = createServiceWithClock(slotEnd.plusHours(1));

        ChatInfo info = service.chatInfo(acceptedRequest);

        assertThat(info).isNull();
    }

    // 7. Non-participant gets 403
    @Test
    void testNonParticipant_throws403() {
        ChatService service = createServiceWithClock(slotEnd.plusHours(1));
        when(requestRepo.findDetailedById(55L)).thenReturn(Optional.of(acceptedRequest));

        Long thirdPartyUserId = 999L;
        assertThatThrownBy(() -> service.requireParticipant(thirdPartyUserId, 55L))
                .isInstanceOf(ApiException.class)
                .satisfies(ex -> {
                    ApiException apiEx = (ApiException) ex;
                    assertThat(apiEx.getStatus()).isEqualTo(403);
                    assertThat(apiEx.getMessage()).isEqualTo("Not your chat");
                });
    }

    // 8. Non-accepted request participant check gets 409
    @Test
    void testNonAcceptedRequestParticipantCheck_throws409() {
        acceptedRequest.setStatus(RequestStatus.PENDING);
        ChatService service = createServiceWithClock(slotEnd.plusHours(1));
        when(requestRepo.findDetailedById(55L)).thenReturn(Optional.of(acceptedRequest));

        assertThatThrownBy(() -> service.requireParticipant(1L, 55L))
                .isInstanceOf(ApiException.class)
                .satisfies(ex -> {
                    ApiException apiEx = (ApiException) ex;
                    assertThat(apiEx.getStatus()).isEqualTo(409);
                    assertThat(apiEx.getMessage()).isEqualTo("Chat is only available for accepted sessions");
                });
    }

    // 9. Send rejected in NOT_STARTED with 409
    @Test
    void testSendWhenNotStarted_throws409() {
        LocalDateTime beforeEnd = slotEnd.minusMinutes(10);
        ChatService service = createServiceWithClock(beforeEnd);
        when(requestRepo.findDetailedById(55L)).thenReturn(Optional.of(acceptedRequest));

        assertThatThrownBy(() -> service.send(1L, 55L, "Hello"))
                .isInstanceOf(ApiException.class)
                .satisfies(ex -> {
                    ApiException apiEx = (ApiException) ex;
                    assertThat(apiEx.getStatus()).isEqualTo(409);
                    assertThat(apiEx.getMessage()).isEqualTo("Chat opens after the session ends");
                });
    }

    // 10. Send rejected in CLOSED with 409
    @Test
    void testSendWhenClosed_throws409() {
        LocalDateTime afterWindow = slotEnd.plusHours(25);
        ChatService service = createServiceWithClock(afterWindow);
        when(requestRepo.findDetailedById(55L)).thenReturn(Optional.of(acceptedRequest));

        assertThatThrownBy(() -> service.send(1L, 55L, "Hello"))
                .isInstanceOf(ApiException.class)
                .satisfies(ex -> {
                    ApiException apiEx = (ApiException) ex;
                    assertThat(apiEx.getStatus()).isEqualTo(409);
                    assertThat(apiEx.getMessage()).isEqualTo("Chat closed 24 hours after the session ended");
                });
    }

    // 11. Send succeeds in OPEN state
    @Test
    void testSendWhenOpen_succeeds() {
        LocalDateTime duringOpen = slotEnd.plusHours(2);
        ChatService service = createServiceWithClock(duringOpen);
        when(requestRepo.findDetailedById(55L)).thenReturn(Optional.of(acceptedRequest));
        when(userRepo.findById(1L)).thenReturn(Optional.of(student));

        ChatMessage savedMessage = ChatMessage.builder()
                .id(101L)
                .request(acceptedRequest)
                .sender(student)
                .content("Can you explain why BFS uses a queue?")
                .sentAt(duringOpen)
                .build();
        when(messageRepo.save(any(ChatMessage.class))).thenReturn(savedMessage);

        MessageResponse response = service.send(1L, 55L, "  Can you explain why BFS uses a queue?  ");

        assertThat(response).isNotNull();
        assertThat(response.id()).isEqualTo(101L);
        assertThat(response.senderId()).isEqualTo(1L);
        assertThat(response.senderName()).isEqualTo("Aarav Sharma");
        assertThat(response.content()).isEqualTo("Can you explain why BFS uses a queue?");
        assertThat(response.sentAt()).isEqualTo(duringOpen);
    }
}
