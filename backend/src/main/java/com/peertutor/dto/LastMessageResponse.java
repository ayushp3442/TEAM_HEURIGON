package com.peertutor.dto;

import com.peertutor.entity.ChatMessage;
import java.time.LocalDateTime;

/** Last message summary inside GET /api/chats item — Architecture.md §6.8 endpoint 18 */
public record LastMessageResponse(
    String content,
    LocalDateTime sentAt,
    Long senderId
) {
    public static LastMessageResponse from(ChatMessage m) {
        if (m == null) return null;
        return new LastMessageResponse(
            m.getContent(),
            m.getSentAt(),
            m.getSender() != null ? m.getSender().getId() : null
        );
    }
}
