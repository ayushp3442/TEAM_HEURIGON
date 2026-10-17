package com.peertutor.dto;

import com.peertutor.enums.Mode;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDateTime;

/** POST /api/slots request body — §6.5 endpoint 10 */
public record SlotRequest(
    @NotNull(message = "startTime is required")
    LocalDateTime startTime,

    @NotNull(message = "endTime is required")
    LocalDateTime endTime,

    @NotNull(message = "mode is required")
    Mode mode,

    @NotBlank(message = "locationOrLink is required")
    String locationOrLink
) {}
