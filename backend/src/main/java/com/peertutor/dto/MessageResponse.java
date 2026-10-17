package com.peertutor.dto;

import com.peertutor.entity.ChatMessage;
import java.time.LocalDateTime;

/** Chat message DTO matching Architecture.md §6.8 endpoints 19 and 20 */
public record MessageResponse(
    Long id,
    Long senderId,
    String senderName,
    String content,
    LocalDateTime sentAt
) {
    public static MessageResponse from(ChatMessage m) {
        if (m == null) return null;
        return new MessageResponse(
            m.getId(),
            m.getSender() != null ? m.getSender().getId() : null,
            m.getSender() != null ? m.getSender().getName() : null,
            m.getContent(),
            m.getSentAt()
        );
    }
}
