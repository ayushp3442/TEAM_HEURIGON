package com.peertutor.dto;

import java.util.List;

/** Response for GET /api/requests/{id}/messages — Architecture.md §6.8 endpoint 19 */
public record MessagesListResponse(
    ChatInfo chat,
    List<MessageResponse> messages
) {}
