package com.peertutor.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** POST /api/subjects request body — §6.3 endpoint 21 */
public record SubjectRequest(
    @NotBlank(message = "name is required")
    @Size(min = 2, max = 60, message = "name must be between 2 and 60 characters")
    String name
) {}
