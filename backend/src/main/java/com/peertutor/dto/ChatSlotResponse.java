package com.peertutor.dto;

import java.time.LocalDateTime;

/** Slot timing inside GET /api/chats item — Architecture.md §6.8 endpoint 18 */
public record ChatSlotResponse(
    LocalDateTime startTime,
    LocalDateTime endTime
) {}
