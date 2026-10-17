package com.peertutor.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;

import java.util.List;

/** PUT /api/tutors/me request body — §6.4 endpoint 9 */
public record TutorProfileRequest(
    @Size(max = 500, message = "bio must not exceed 500 characters")
    String bio,

    String department,

    Integer yearOfStudy,

    @NotEmpty(message = "at least one subject is required")
    List<Long> subjectIds
) {}
