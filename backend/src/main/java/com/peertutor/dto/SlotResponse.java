package com.peertutor.dto;

import com.peertutor.entity.AvailabilitySlot;
import com.peertutor.enums.Mode;

import java.time.LocalDateTime;

/** Availability slot item — §6.4 endpoint 7 and §6.5 endpoint 10 */
public record SlotResponse(
    Long id,
    LocalDateTime startTime,
    LocalDateTime endTime,
    Mode mode,
    String locationOrLink,
    boolean booked
) {
    public static SlotResponse from(AvailabilitySlot slot) {
        return new SlotResponse(
            slot.getId(),
            slot.getStartTime(),
            slot.getEndTime(),
            slot.getMode(),
            slot.getLocationOrLink(),
            slot.isBooked()
        );
    }
}
