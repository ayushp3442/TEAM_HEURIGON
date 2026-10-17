package com.peertutor.dto;

/** Item in GET /api/chats list — Architecture.md §6.8 endpoint 18 */
public record ChatListItemResponse(
    Long requestId,
    UserSummaryResponse otherUser,
    SubjectResponse subject,
    ChatSlotResponse slot,
    ChatInfo chat,
    LastMessageResponse lastMessage
) {}
