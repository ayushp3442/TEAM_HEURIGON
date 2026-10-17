package com.peertutor.dto;

import com.peertutor.entity.SessionRequest;
import com.peertutor.enums.RequestStatus;

import java.time.LocalDateTime;

/** Session request response matching §6.6 contract */
public record RequestResponse(
    Long id,
    RequestStatus status,
    String message,
    LocalDateTime createdAt,
    UserSummaryResponse student,
    UserSummaryResponse tutor,
    SubjectResponse subject,
    SlotInfoResponse slot,
    ChatInfo chat
) {
    public static RequestResponse from(SessionRequest r, ChatInfo chat) {
        UserSummaryResponse student = r.getStudent() != null
            ? new UserSummaryResponse(r.getStudent().getId(), r.getStudent().getName())
            : null;

        UserSummaryResponse tutor = (r.getTutor() != null && r.getTutor().getUser() != null)
            ? new UserSummaryResponse(r.getTutor().getId(), r.getTutor().getUser().getName())
            : null;

        SubjectResponse subject = r.getSubject() != null
            ? SubjectResponse.from(r.getSubject())
            : null;

        SlotInfoResponse slot = r.getSlot() != null
            ? SlotInfoResponse.from(r.getSlot())
            : null;

        return new RequestResponse(
            r.getId(),
            r.getStatus(),
            r.getMessage(),
            r.getCreatedAt(),
            student,
            tutor,
            subject,
            slot,
            chat
        );
    }

    public static RequestResponse from(SessionRequest r) {
        return from(r, null);
    }
}
