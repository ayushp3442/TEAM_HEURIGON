package com.peertutor.dto;

import com.peertutor.entity.AvailabilitySlot;
import com.peertutor.enums.Mode;

import java.time.LocalDateTime;

/** Availability slot item for GET /api/slots/mine with requestCount — §6.5 endpoint 11 */
public record MySlotResponse(
    Long id,
    LocalDateTime startTime,
    LocalDateTime endTime,
    Mode mode,
    String locationOrLink,
    boolean booked,
    long requestCount
) {
    public static MySlotResponse from(AvailabilitySlot slot, long requestCount) {
        return new MySlotResponse(
            slot.getId(),
            slot.getStartTime(),
            slot.getEndTime(),
            slot.getMode(),
            slot.getLocationOrLink(),
            slot.isBooked(),
            requestCount
        );
    }
}
