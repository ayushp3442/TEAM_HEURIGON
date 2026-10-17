package com.peertutor.dto;

import com.peertutor.entity.TutorProfile;

import java.util.Comparator;
import java.util.List;

/** Tutor profile response — §6.4 endpoint 6 & 8 */
public record TutorProfileResponse(
    Long id,
    Long userId,
    String name,
    String bio,
    String department,
    Integer yearOfStudy,
    List<SubjectResponse> subjects
) {
    public static TutorProfileResponse from(TutorProfile profile) {
        List<SubjectResponse> subjectResponses = profile.getSubjects() == null
            ? List.of()
            : profile.getSubjects().stream()
                .map(SubjectResponse::from)
                .sorted(Comparator.comparing(SubjectResponse::id))
                .toList();

        return new TutorProfileResponse(
            profile.getId(),
            profile.getUser() != null ? profile.getUser().getId() : null,
            profile.getUser() != null ? profile.getUser().getName() : null,
            profile.getBio(),
            profile.getDepartment(),
            profile.getYearOfStudy(),
            subjectResponses
        );
    }
}
