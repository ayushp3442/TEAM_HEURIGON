package com.peertutor.dto;

import com.peertutor.enums.Mode;

import java.time.LocalDateTime;

/** Next slot item inside tutor card — §6.4 endpoint 5 */
public record NextSlotResponse(
    LocalDateTime startTime,
    Mode mode
) {}
