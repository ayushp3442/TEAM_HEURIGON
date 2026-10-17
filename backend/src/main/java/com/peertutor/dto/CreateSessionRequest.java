package com.peertutor.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/** POST /api/requests request body — §6.6 endpoint 13 */
public record CreateSessionRequest(
    @NotNull(message = "slotId is required")
    Long slotId,

    @NotNull(message = "subjectId is required")
    Long subjectId,

    @Size(max = 300, message = "message must not exceed 300 characters")
    String message
) {}
