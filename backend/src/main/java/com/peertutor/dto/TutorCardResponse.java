package com.peertutor.dto;

import java.util.List;

/** Tutor card response for GET /api/tutors — §6.4 endpoint 5 */
public record TutorCardResponse(
    Long id,
    String name,
    String bio,
    String department,
    Integer yearOfStudy,
    List<SubjectResponse> subjects,
    long openSlotCount,
    NextSlotResponse nextSlot
) {}
