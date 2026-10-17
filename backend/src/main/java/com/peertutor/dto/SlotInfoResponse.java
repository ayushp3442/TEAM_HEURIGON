package com.peertutor.dto;

import com.peertutor.entity.AvailabilitySlot;
import com.peertutor.enums.Mode;

import java.time.LocalDateTime;

/** Slot info inside request response — §6.6 */
public record SlotInfoResponse(
    Long id,
    LocalDateTime startTime,
    LocalDateTime endTime,
    Mode mode,
    String locationOrLink
) {
    public static SlotInfoResponse from(AvailabilitySlot slot) {
        return new SlotInfoResponse(
            slot.getId(),
            slot.getStartTime(),
            slot.getEndTime(),
            slot.getMode(),
            slot.getLocationOrLink()
        );
    }
}
