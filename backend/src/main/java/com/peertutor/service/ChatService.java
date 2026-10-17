package com.peertutor.service;

import com.peertutor.dto.*;
import com.peertutor.entity.ChatMessage;
import com.peertutor.entity.SessionRequest;
import com.peertutor.entity.User;
import com.peertutor.enums.ChatState;
import com.peertutor.enums.RequestStatus;
import com.peertutor.exception.ApiException;
import com.peertutor.repository.ChatMessageRepository;
import com.peertutor.repository.SessionRequestRepository;
import com.peertutor.repository.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Post-session chat service — Architecture.md §4.10 and §6.8.
 */
@Service
public class ChatService {

    private final ChatMessageRepository messageRepo;
    private final SessionRequestRepository requestRepo;
    private final UserRepository userRepo;
    private final Clock clock;
    private final int windowHours;

    public ChatService(
            ChatMessageRepository messageRepo,
            SessionRequestRepository requestRepo,
            UserRepository userRepo,
            Clock clock,
            @Value("${app.chat.window-hours:24}") int windowHours) {
        this.messageRepo = messageRepo;
        this.requestRepo = requestRepo;
        this.userRepo = userRepo;
        this.clock = clock;
        this.windowHours = windowHours;
    }

    /**
     * Compute chatInfo for a session request.
     * null unless ACCEPTED; state NOT_STARTED (now < slot.endTime),
     * OPEN (slot.endTime <= now < slot.endTime + 24h), CLOSED (after that).
     */
    public ChatInfo chatInfo(SessionRequest r) {
        if (r == null || r.getStatus() != RequestStatus.ACCEPTED) {
            return null;
        }

        LocalDateTime opensAt = r.getSlot().getEndTime();
        LocalDateTime closesAt = opensAt.plusHours(windowHours);
        LocalDateTime now = LocalDateTime.now(clock);

        ChatState state;
        if (now.isBefore(opensAt)) {
            state = ChatState.NOT_STARTED;
        } else if (now.isBefore(closesAt)) {
            state = ChatState.OPEN;
        } else {
            state = ChatState.CLOSED;
        }

        return new ChatInfo(state, opensAt, closesAt);
    }

    /**
     * Validate participant ownership and that request is ACCEPTED.
     */
    public SessionRequest requireParticipant(Long userId, Long requestId) {
        SessionRequest r = requestRepo.findDetailedById(requestId)
                .orElseThrow(() -> new ApiException(404, "Request not found"));

        boolean isStudent = r.getStudent() != null && r.getStudent().getId().equals(userId);
        boolean isTutor = r.getTutor() != null && r.getTutor().getUser() != null
                && r.getTutor().getUser().getId().equals(userId);

        if (!isStudent && !isTutor) {
            throw new ApiException(403, "Not your chat");
        }

        if (r.getStatus() != RequestStatus.ACCEPTED) {
            throw new ApiException(409, "Chat is only available for accepted sessions");
        }

        return r;
    }

    /**
     * Endpoint 20: POST /api/requests/{id}/messages
     */
    @Transactional
    public MessageResponse send(Long userId, Long requestId, String content) {
        if (content == null || content.trim().isEmpty()) {
            throw new ApiException(400, "content must not be blank");
        }

        String trimmed = content.trim();
        if (trimmed.length() > 1000) {
            throw new ApiException(400, "content must not exceed 1000 characters");
        }

        SessionRequest r = requireParticipant(userId, requestId);
        ChatInfo info = chatInfo(r);

        if (info.state() == ChatState.NOT_STARTED) {
            throw new ApiException(409, "Chat opens after the session ends");
        }
        if (info.state() == ChatState.CLOSED) {
            throw new ApiException(409, "Chat closed 24 hours after the session ended");
        }

        User sender = userRepo.findById(userId)
                .orElseThrow(() -> new ApiException(404, "User not found"));

        ChatMessage message = ChatMessage.builder()
                .request(r)
                .sender(sender)
                .content(trimmed)
                .sentAt(LocalDateTime.now(clock))
                .build();

        ChatMessage saved = messageRepo.save(message);
        return MessageResponse.from(saved);
    }

    /**
     * Endpoint 19: GET /api/requests/{id}/messages?afterId=0
     */
    @Transactional(readOnly = true)
    public MessagesListResponse getMessages(Long userId, Long requestId, Long afterId) {
        SessionRequest r = requireParticipant(userId, requestId);
        ChatInfo info = chatInfo(r);

        Long minId = (afterId == null) ? 0L : afterId;
        List<ChatMessage> list = messageRepo.findByRequestIdAndIdGreaterThanOrderByIdAsc(requestId, minId);
        List<MessageResponse> messageResponses = list.stream().map(MessageResponse::from).toList();

        return new MessagesListResponse(info, messageResponses);
    }

    /**
     * Endpoint 18: GET /api/chats
     * All chats of current user (their ACCEPTED requests), sorted OPEN first, then NOT_STARTED, then CLOSED.
     */
    @Transactional(readOnly = true)
    public List<ChatListItemResponse> listChats(Long userId) {
        List<SessionRequest> requests = requestRepo.findAcceptedForUser(userId, RequestStatus.ACCEPTED);
        if (requests.isEmpty()) {
            return List.of();
        }

        List<Long> reqIds = requests.stream().map(SessionRequest::getId).toList();
        List<ChatMessage> latestMessages = messageRepo.findLatestByRequestIds(reqIds);
        Map<Long, ChatMessage> latestByReqId = latestMessages.stream()
                .collect(Collectors.toMap(m -> m.getRequest().getId(), m -> m, (m1, m2) -> m1));

        List<ChatListItemResponse> items = new ArrayList<>();
        for (SessionRequest r : requests) {
            ChatInfo info = chatInfo(r);
            boolean isStudent = r.getStudent() != null && r.getStudent().getId().equals(userId);
            UserSummaryResponse otherUser = isStudent
                    ? new UserSummaryResponse(r.getTutor().getUser().getId(), r.getTutor().getUser().getName())
                    : new UserSummaryResponse(r.getStudent().getId(), r.getStudent().getName());

            SubjectResponse subject = SubjectResponse.from(r.getSubject());
            ChatSlotResponse slot = new ChatSlotResponse(r.getSlot().getStartTime(), r.getSlot().getEndTime());
            ChatMessage lastMsg = latestByReqId.get(r.getId());
            LastMessageResponse lastMsgResp = LastMessageResponse.from(lastMsg);

            items.add(new ChatListItemResponse(
                    r.getId(),
                    otherUser,
                    subject,
                    slot,
                    info,
                    lastMsgResp
            ));
        }

        items.sort(Comparator
                .comparingInt((ChatListItemResponse item) -> rankState(item.chat().state()))
                .thenComparing(item -> item.slot().startTime())
        );

        return items;
    }

    private int rankState(ChatState state) {
        return switch (state) {
            case OPEN -> 0;
            case NOT_STARTED -> 1;
            case CLOSED -> 2;
        };
    }
}
