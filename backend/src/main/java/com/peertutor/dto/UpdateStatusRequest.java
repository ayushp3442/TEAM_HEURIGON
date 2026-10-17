package com.peertutor.dto;

import com.peertutor.enums.RequestStatus;
import jakarta.validation.constraints.NotNull;

/** PATCH /api/requests/{id}/status request body — §6.6 endpoint 17 */
public record UpdateStatusRequest(
    @NotNull(message = "status is required")
    RequestStatus status
) {}
