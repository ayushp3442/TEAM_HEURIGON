package com.peertutor.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Request body for POST /api/requests/{id}/messages — Architecture.md §6.8 endpoint 20 */
public record SendMessageRequest(
    @NotBlank(message = "content must not be blank")
    @Size(max = 1000, message = "content must not exceed 1000 characters")
    String content
) {}
